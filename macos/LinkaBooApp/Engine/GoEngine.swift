import AppKit
import Foundation

/// Thread-safe accumulator for subprocess stderr. Used so we can tail the last
/// N lines into the user-facing failure message without copying the full stream.
actor StderrBuffer {
    private var buffer = ""
    private let maxBytes = 8192

    func append(_ chunk: String) {
        buffer += chunk
        if buffer.count > maxBytes {
            buffer = String(buffer.suffix(maxBytes))
        }
    }

    func tail(lines: Int) -> String {
        let all = buffer.split(whereSeparator: \.isNewline)
        return all.suffix(lines).joined(separator: "\n")
    }
}

struct CLIEvent: Decodable, Sendable {
    let type: String
    let code: String?
    let link: String?
    let message: String?
    let file_name: String?
    let file_count: Int?
    let ok: Bool?
    let sent_bytes: Int64?
    let total_bytes: Int64?
    let percent: Double?
}

enum TransferKind: String, Equatable, Sendable {
    case send
    case receive
}

enum TransferState: Equatable, Hashable, Sendable {
    case idle
    case starting(kind: TransferKind, title: String)
    case waitingForRecipient(code: String, link: String, itemName: String?)
    case waitingForSender(code: String)
    case transferring(kind: TransferKind, itemName: String?, percent: Double, sentBytes: Int64, totalBytes: Int64)
    case complete(kind: TransferKind, message: String)
    case failed(message: String)
}

@MainActor
class GoEngine: ObservableObject {
    @Published var state: TransferState = .idle

    let history: TransferHistoryStore

    private var process: Process?
    private var activeKind: TransferKind?
    private var activeItemName: String?
    private var activeRecord: TransferRecord?
    private let codePattern = try! NSRegularExpression(pattern: #"^\d+-\w+-\w+$"#)

    init(history: TransferHistoryStore = .shared) {
        self.history = history
    }

    /// Path to the linkaboo CLI binary.
    /// The Xcode build script copies it into the app bundle's Resources.
    private nonisolated var binaryPath: String? {
        Bundle.main.url(forResource: "linkaboo", withExtension: nil)?.path
    }

    func send(path: String) {
        let url = URL(fileURLWithPath: path)
        let name = url.lastPathComponent
        guard FileManager.default.fileExists(atPath: path) else {
            state = .failed(message: "File not found: \(name)")
            recordFailure(name: name, kind: .send, reason: "File not found")
            return
        }

        activeItemName = name
        let info = TransferRecordInspector.describe(path: path)
        activeRecord = TransferRecord(
            kind: .send,
            itemName: name,
            itemPath: path,
            byteSize: info.byteSize,
            itemCount: info.itemCount,
            isFolder: info.isFolder,
            status: .pending
        )
        if let record = activeRecord {
            history.upsert(record)
        }

        startTransfer(
            kind: .send,
            initialState: .starting(kind: .send, title: "Creating secure link…"),
            arguments: ["send", path, "--json"]
        )
    }

    func receive(code: String, destination: String? = nil) {
        let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
        let range = NSRange(location: 0, length: trimmedCode.utf16.count)
        AppLogger.shared.info("receive code='\(trimmedCode)'", category: "engine")
        guard codePattern.firstMatch(in: trimmedCode, options: [], range: range) != nil else {
            AppLogger.shared.error("receive rejected: code='\(trimmedCode)' did not match /^\\d+-\\w+-\\w+$/", category: "engine")
            state = .failed(message: "That LinkaBoo code doesn't look valid.")
            return
        }

        activeItemName = nil
        let destPath = destination ?? ReceiveDestination.current.path
        // Ensure the destination directory exists so the CLI doesn't fail on a stale preference
        try? FileManager.default.createDirectory(
            at: URL(fileURLWithPath: destPath),
            withIntermediateDirectories: true
        )

        activeRecord = TransferRecord(
            kind: .receive,
            itemName: "Incoming transfer",
            itemPath: destPath,
            status: .pending
        )
        if let record = activeRecord {
            history.upsert(record)
        }

        startTransfer(
            kind: .receive,
            initialState: .waitingForSender(code: trimmedCode),
            arguments: ["receive", trimmedCode, "--dest", destPath, "--json"]
        )
    }

    func cancel() {
        guard let proc = process else { return }
        proc.terminate()
        // Don't block the main thread — the detached Task will clean up
        process = nil
        state = .idle
        if var record = activeRecord, !record.status.isTerminal {
            record.status = .canceled
            history.upsert(record)
        }
        activeRecord = nil
    }

    func reset() {
        cancel()
        activeKind = nil
        activeItemName = nil
        activeRecord = nil
        state = .idle
    }

    private func recordFailure(name: String, kind: TransferKind, reason: String) {
        let kindValue: TransferRecordKind = (kind == .send) ? .send : .receive
        let record = TransferRecord(
            kind: kindValue,
            itemName: name,
            status: .failed(reason: reason)
        )
        history.upsert(record)
    }

    private func startTransfer(kind: TransferKind, initialState: TransferState, arguments: [String]) {
        if let existing = process, existing.isRunning {
            existing.terminate()
            existing.waitUntilExit()
        }
        process = nil

        guard let binary = binaryPath, FileManager.default.fileExists(atPath: binary) else {
            let msg = "Go binary not found. Run 'task go:build' and rebuild the Xcode project."
            state = .failed(message: msg)
            if var record = activeRecord {
                record.status = .failed(reason: msg)
                history.upsert(record)
                activeRecord = nil
            }
            return
        }

        activeKind = kind
        state = initialState

        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: binary)
        proc.arguments = arguments

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        proc.standardOutput = stdoutPipe
        proc.standardError = stderrPipe

        self.process = proc

        let stdoutHandle = stdoutPipe.fileHandleForReading
        let stderrHandle = stderrPipe.fileHandleForReading

        AppLogger.shared.info("launching \(binary) \(arguments.joined(separator: " "))", category: "engine")

        Task.detached {
            do {
                try proc.run()
            } catch {
                let msg = error.localizedDescription
                AppLogger.shared.error("failed to launch process: \(msg)", category: "engine")
                await MainActor.run { [weak self] in
                    self?.state = .failed(message: "Failed to launch: \(msg)")
                    self?.process = nil
                    self?.activeKind = nil
                }
                try? stdoutHandle.close()
                try? stderrHandle.close()
                return
            }

            // Drain stderr concurrently and capture it for diagnostics.
            let stderrBuffer = StderrBuffer()
            let stderrTask = Task.detached {
                while true {
                    let chunk = stderrHandle.availableData
                    if chunk.isEmpty { break }
                    if let text = String(data: chunk, encoding: .utf8) {
                        await stderrBuffer.append(text)
                        for line in text.split(whereSeparator: \.isNewline) where !line.isEmpty {
                            AppLogger.shared.warning("stderr: \(line)", category: "engine")
                        }
                    }
                }
                try? stderrHandle.close()
            }

            let decoder = JSONDecoder()
            var buffer = Data()

            while true {
                let chunk = stdoutHandle.availableData
                if chunk.isEmpty { break }
                buffer.append(chunk)

                while let newlineIndex = buffer.firstIndex(of: UInt8(ascii: "\n")) {
                    let lineData = Data(buffer[buffer.startIndex..<newlineIndex])
                    buffer = Data(buffer[buffer.index(after: newlineIndex)...])

                    guard !lineData.isEmpty else { continue }

                    if let rawLine = String(data: lineData, encoding: .utf8) {
                        AppLogger.shared.debug("stdout: \(rawLine)", category: "engine")
                    }

                    guard let event = try? decoder.decode(CLIEvent.self, from: lineData) else {
                        AppLogger.shared.warning("failed to decode event line", category: "engine")
                        continue
                    }

                    await MainActor.run { [weak self] in
                        self?.handleEvent(event)
                    }
                }
            }

            try? stdoutHandle.close()
            _ = await stderrTask.value
            proc.waitUntilExit()

            let exitCode = proc.terminationStatus
            let reason = proc.terminationReason
            let stderrTail = await stderrBuffer.tail(lines: 20)

            AppLogger.shared.info(
                "process exited code=\(exitCode) reason=\(reason == .exit ? "exit" : "signal")",
                category: "engine"
            )

            await MainActor.run { [weak self] in
                guard let self else { return }
                defer { self.process = nil }

                // Already have a specific error set from an "error" event — keep it.
                if case .failed = self.state, exitCode != 0 { return }

                // User-initiated cancel via .terminate() → SIGTERM, or Ctrl+C → SIGINT
                if reason == .uncaughtSignal && (exitCode == 15 || exitCode == 2) {
                    self.state = .idle
                    return
                }

                if exitCode == 0 && reason == .exit {
                    // Let the complete event handler set the terminal state
                    return
                }

                // Anything else is a failure — surface stderr context.
                let detail = Self.describeTermination(exitCode: exitCode, reason: reason, stderr: stderrTail)
                AppLogger.shared.error("transfer failed: \(detail)", category: "engine")
                self.state = .failed(message: detail)
                if var record = self.activeRecord {
                    record.status = .failed(reason: detail)
                    self.history.upsert(record)
                    self.activeRecord = nil
                }
            }
        }
    }

    private static func describeTermination(exitCode: Int32, reason: Process.TerminationReason, stderr: String) -> String {
        let head: String
        if reason == .uncaughtSignal {
            switch exitCode {
            case 9:  head = "Helper was killed by macOS (signal 9). The bundled CLI may be blocked by Gatekeeper or code-signing."
            case 11: head = "Helper crashed (signal 11: segfault)."
            default: head = "Helper terminated by signal \(exitCode)."
            }
        } else {
            head = "Transfer failed (exit code \(exitCode))."
        }
        let trimmed = stderr.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return head
        }
        return "\(head)\n\(trimmed)"
    }

    private func handleEvent(_ event: CLIEvent) {
        let currentKind = activeKind ?? .send
        switch event.type {
        case "code":
            if let code = event.code {
                AppLogger.shared.info("got share code \(code)", category: "engine")
                #if DEBUG
                let link = "http://localhost:3000/r/\(code)"
                #else
                let link = event.link ?? "https://linkaboo.app/r/\(code)"
                #endif
                state = .waitingForRecipient(
                    code: code,
                    link: link,
                    itemName: activeItemName
                )
            }
        case "progress":
            let percent = event.percent ?? 0
            state = .transferring(
                kind: currentKind,
                itemName: activeItemName ?? event.file_name,
                percent: percent,
                sentBytes: event.sent_bytes ?? 0,
                totalBytes: event.total_bytes ?? 0
            )
            if var record = activeRecord {
                if let name = event.file_name, !name.isEmpty, record.itemName == "Incoming transfer" {
                    record.itemName = name
                }
                if record.byteSize == nil, let total = event.total_bytes, total > 0 {
                    record.byteSize = total
                }
                if let count = event.file_count, count > 1 {
                    record.itemCount = count
                    record.isFolder = true
                }
                record.status = .inProgress(percent: percent)
                history.upsert(record)
                activeRecord = record
            }
        case "complete":
            if currentKind == .receive {
                let summary: String
                if let fileCount = event.file_count, fileCount > 1 {
                    summary = "Received \(fileCount) items in Downloads."
                } else if let fileName = event.file_name, !fileName.isEmpty {
                    activeItemName = fileName
                    summary = "Received \(fileName) in Downloads."
                } else {
                    summary = "Receive complete."
                }
                AppLogger.shared.info("receive complete: \(summary)", category: "engine")
                state = .complete(kind: .receive, message: summary)
                if var record = activeRecord {
                    if let name = event.file_name, !name.isEmpty {
                        record.itemName = name
                        if let destDir = record.itemPath {
                            record.itemPath = (destDir as NSString).appendingPathComponent(name)
                        }
                    }
                    if let count = event.file_count, count > 1 {
                        record.itemCount = count
                        record.isFolder = true
                    }
                    if record.byteSize == nil, let total = event.total_bytes {
                        record.byteSize = total
                    }
                    record.status = .complete
                    history.upsert(record)
                    activeRecord = nil
                }
            } else {
                AppLogger.shared.info("send complete", category: "engine")
                state = .complete(kind: .send, message: "LinkaBoo delivered the transfer directly.")
                if var record = activeRecord {
                    record.status = .complete
                    history.upsert(record)
                    activeRecord = nil
                }
            }
        case "error":
            let msg = event.message ?? "Unknown error"
            AppLogger.shared.error("CLI error event: \(msg)", category: "engine")
            state = .failed(message: msg)
            if var record = activeRecord {
                record.status = .failed(reason: msg)
                history.upsert(record)
                activeRecord = nil
            }
        default:
            break
        }
    }
}

extension TransferState: CaseIterable {
    static var allCases: [TransferState] {
        [
            .idle,
            .starting(kind: .send, title: "Starting"),
            .waitingForRecipient(
                code: "7-crossword-clockwork",
                link: "https://linkaboo.app/r/7-crossword-clockwork",
                itemName: "Example.pdf"
            ),
            .waitingForSender(code: "7-crossword-clockwork"),
            .transferring(kind: .send, itemName: "Example.pdf", percent: 42, sentBytes: 42, totalBytes: 100),
            .complete(kind: .send, message: "Done"),
            .failed(message: "Failed")
        ]
    }

    var debugLabel: String {
        switch self {
        case .idle:
            return "Idle (Default)"
        case .starting:
            return "Starting (Downloading)"
        case .waitingForRecipient:
            return "Waiting for Recipient (Downloading)"
        case .waitingForSender:
            return "Waiting for Sender (Downloading)"
        case .transferring:
            return "Transferring"
        case .complete:
            return "Complete (Default)"
        case .failed:
            return "Failed (Alert)"
        }
    }
}

#if DEBUG
extension GoEngine {
    func forceState(_ state: TransferState) {
        self.state = state
    }
}
#endif
