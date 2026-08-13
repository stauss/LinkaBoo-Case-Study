import Foundation
import OSLog

/// Application-wide logger. Writes to OSLog (visible in Console.app, filter by
/// subsystem "app.linkaboo.LinkaBoo") and mirrors every message to a rotating
/// file at ~/Library/Logs/LinkaBoo/linkaboo.log so users can attach it to bug
/// reports without needing Console.app.
///
/// Usage:
///   AppLogger.shared.info("transfer started", category: "engine")
///   AppLogger.shared.error("exit code \(code)", category: "engine")
enum AppLogLevel: String {
    case debug, info, warning, error
}

final class AppLogger: @unchecked Sendable {
    static let shared = AppLogger()

    private let subsystem = "app.linkaboo.LinkaBoo"
    private let fileQueue = DispatchQueue(label: "app.linkaboo.logger.file")
    private let fileURL: URL
    private let isoFormatter: ISO8601DateFormatter
    private var loggers: [String: Logger] = [:]
    private let loggersLock = NSLock()

    /// Max log file size before rotation (1 MB).
    private let maxBytes: Int = 1_048_576

    private init() {
        let logsDir = FileManager.default
            .urls(for: .libraryDirectory, in: .userDomainMask)
            .first?.appendingPathComponent("Logs/LinkaBoo", isDirectory: true)
            ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Logs/LinkaBoo")

        try? FileManager.default.createDirectory(at: logsDir, withIntermediateDirectories: true)
        self.fileURL = logsDir.appendingPathComponent("linkaboo.log")

        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        self.isoFormatter = f

        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        }

        // Log session boundary so multi-run files are easy to eyeball.
        write(level: .info, category: "session", message: "---- LinkaBoo session started ----")
    }

    var logFileURL: URL { fileURL }

    func debug(_ message: String, category: String = "app") {
        write(level: .debug, category: category, message: message)
    }

    func info(_ message: String, category: String = "app") {
        write(level: .info, category: category, message: message)
    }

    func warning(_ message: String, category: String = "app") {
        write(level: .warning, category: category, message: message)
    }

    func error(_ message: String, category: String = "app") {
        write(level: .error, category: category, message: message)
    }

    private func osLogger(for category: String) -> Logger {
        loggersLock.lock()
        defer { loggersLock.unlock() }
        if let existing = loggers[category] { return existing }
        let logger = Logger(subsystem: subsystem, category: category)
        loggers[category] = logger
        return logger
    }

    private func write(level: AppLogLevel, category: String, message: String) {
        let logger = osLogger(for: category)
        switch level {
        case .debug:   logger.debug("\(message, privacy: .public)")
        case .info:    logger.info("\(message, privacy: .public)")
        case .warning: logger.warning("\(message, privacy: .public)")
        case .error:   logger.error("\(message, privacy: .public)")
        }

        let line = "\(isoFormatter.string(from: Date())) [\(level.rawValue.uppercased())] [\(category)] \(message)\n"
        fileQueue.async { [weak self] in
            guard let self else { return }
            self.rotateIfNeeded()
            if let data = line.data(using: .utf8) {
                if let handle = try? FileHandle(forWritingTo: self.fileURL) {
                    defer { try? handle.close() }
                    _ = try? handle.seekToEnd()
                    try? handle.write(contentsOf: data)
                } else {
                    try? data.write(to: self.fileURL, options: .atomic)
                }
            }
        }
    }

    private func rotateIfNeeded() {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
              let size = attrs[.size] as? Int, size > maxBytes else {
            return
        }
        let rotated = fileURL.deletingPathExtension().appendingPathExtension("1.log")
        try? FileManager.default.removeItem(at: rotated)
        try? FileManager.default.moveItem(at: fileURL, to: rotated)
        FileManager.default.createFile(atPath: fileURL.path, contents: nil)
    }
}
