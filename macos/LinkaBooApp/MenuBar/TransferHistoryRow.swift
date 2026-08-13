import SwiftUI

struct TransferHistoryRow: View {
    let record: TransferRecord
    var onShowInFinder: (() -> Void)? = nil
    var onCancel: (() -> Void)? = nil

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 10) {
            iconView
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.itemName)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            statusTrailing
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovered ? Color.white.opacity(0.08) : Color.clear)
        )
        .onHover { isHovered = $0 }
    }

    // MARK: - Icon

    @ViewBuilder
    private var iconView: some View {
        let symbol: String = {
            if record.isFolder { return "folder.fill" }
            return "doc.fill"
        }()
        Image(systemName: symbol)
            .resizable()
            .scaledToFit()
            .foregroundStyle(.secondary)
            .padding(4)
    }

    // MARK: - Subtitle

    private var subtitle: String {
        let type = TransferRecordInspector.typeLabel(name: record.itemName, isFolder: record.isFolder)
        var parts: [String] = [type]
        if record.isFolder, let count = record.itemCount {
            parts.append("\(count) Files")
        }
        if let bytes = record.byteSize, bytes > 0 {
            parts.append(formatBytes(bytes))
        }
        return parts.joined(separator: " • ")
    }

    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = [.useAll]
        return formatter.string(fromByteCount: bytes).lowercased()
    }

    // MARK: - Trailing status

    @ViewBuilder
    private var statusTrailing: some View {
        switch record.status {
        case .pending:
            inProgressTrailing(label: "Starting…")
        case .inProgress(let percent):
            inProgressTrailing(label: "\(Int(percent.rounded()))% Complete")
        case .complete:
            completeTrailing
        case .failed(let reason):
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.circle")
                Text("Error")
            }
            .font(.system(size: 11))
            .foregroundColor(.secondary)
            .help(reason)
        case .canceled:
            Text("Canceled")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private func inProgressTrailing(label: String) -> some View {
        if isHovered, let onCancel {
            Button(action: onCancel) {
                Text("Cancel")
                    .font(.system(size: 11, weight: .medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.12))
                    )
            }
            .buttonStyle(.plain)
        } else {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private var completeTrailing: some View {
        if !fileExists {
            HStack(spacing: 4) {
                Image(systemName: "doc.badge.ellipsis")
                Text("File Missing")
            }
            .font(.system(size: 11))
            .foregroundColor(.secondary)
        } else if isHovered {
            Button(action: { onShowInFinder?() }) {
                Text("Show In Finder")
                    .font(.system(size: 11, weight: .medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.12))
                    )
            }
            .buttonStyle(.plain)
        } else if isRecent {
            HStack(spacing: 4) {
                Image(systemName: "checkmark")
                Text("Complete")
            }
            .font(.system(size: 11))
            .foregroundColor(.secondary)
        } else {
            Text(relativeTime)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }

    private var fileExists: Bool {
        guard let path = record.itemPath else { return false }
        return FileManager.default.fileExists(atPath: path)
    }

    private var isRecent: Bool {
        Date().timeIntervalSince(record.updatedAt) < 60 * 60 * 24
    }

    private var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: record.updatedAt, relativeTo: Date())
    }
}
