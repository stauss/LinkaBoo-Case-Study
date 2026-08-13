import SwiftUI

struct TransferPopoverView: View {
    @ObservedObject var engine: GoEngine
    @ObservedObject var history: TransferHistoryStore
    var onOpenSettings: () -> Void

    @State private var selectedFileName: String?
    @State private var receiveCode = ""

    var body: some View {
        VStack(spacing: 0) {
            content
            Divider()
            footer
        }
        .frame(width: 340)
    }

    @ViewBuilder
    private var content: some View {
        if history.records.isEmpty {
            emptyView
                .padding(.vertical, 32)
        } else {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 2) {
                    ForEach(history.records) { record in
                        TransferHistoryRow(
                            record: record,
                            onShowInFinder: { showInFinder(record) },
                            onCancel: cancelHandler(for: record)
                        )
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 4)
            }
            .frame(maxHeight: 360)
        }
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.system(size: 28))
                .foregroundStyle(.secondary)
            Text("No recent transfers")
                .font(.system(size: 13, weight: .medium))
            Text("Drop a file on the ghost to send. Open a LinkaBoo link to receive.")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            Button(action: onOpenSettings) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Preferences")

            Spacer()

            Text(versionLabel)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
    }

    private var versionLabel: String {
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0"
        return "LinkaBoo v\(short)"
    }

    // MARK: - Actions

    func startSending(url: URL) {
        selectedFileName = url.lastPathComponent
        receiveCode = ""
        engine.send(path: url.path)
    }

    func startReceiving(code: String) {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        selectedFileName = nil
        receiveCode = trimmed
        engine.receive(code: trimmed)
    }

    private func showInFinder(_ record: TransferRecord) {
        guard let path = record.itemPath else { return }
        let url = URL(fileURLWithPath: path)
        if FileManager.default.fileExists(atPath: path) {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }
    }

    private func cancelHandler(for record: TransferRecord) -> (() -> Void)? {
        guard !record.status.isTerminal else { return nil }
        return { engine.cancel() }
    }
}
