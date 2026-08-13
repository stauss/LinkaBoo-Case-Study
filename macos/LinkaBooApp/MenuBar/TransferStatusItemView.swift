import AppKit
import SwiftUI

struct TransferStatusItemView: View {
    let state: TransferState

    private var isExpanded: Bool {
        switch state {
        case .transferring, .complete:
            return true
        default:
            return false
        }
    }

    private var progressValue: Double {
        guard case .transferring(_, _, let percent, _, _) = state else {
            return 0
        }
        return max(0, min(percent / 100, 1))
    }

    private var progressLabel: String {
        guard case .transferring(_, _, let percent, _, _) = state else {
            return ""
        }
        return "\(Int(percent.rounded()))%"
    }

    private var statusAssetName: String {
        switch state {
        case .failed:
            return "BooStatus-Alert"
        case .starting,
             .waitingForRecipient,
             .waitingForSender,
             .transferring:
            return "BooStatus-Transfering"
        case .idle,
             .complete:
            return "BooStatus-Default"
        }
    }

    private var statusWidth: CGFloat {
        switch state {
        case .transferring:
            return 132
        case .complete:
            return 240
        default:
            return 24
        }
    }

    var body: some View {
        HStack(spacing: isExpanded ? 10 : 0) {
            statusIcon

            switch state {
            case .transferring:
                progressTrack
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            case .complete(let kind, let message):
                completeBanner(kind: kind, message: message)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            default:
                EmptyView()
            }
        }
        .padding(.horizontal, isExpanded ? 8 : 0)
        .frame(width: statusWidth, height: 22, alignment: .leading)
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: isExpanded)
        .animation(.easeInOut(duration: 0.16), value: progressValue)
        .accessibilityLabel(accessibilityLabel)
    }

    private var statusIcon: some View {
        Group {
            if let image = NSImage(named: statusAssetName) {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.high)
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "tray")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .frame(width: 22, height: 22)
    }

    private var progressTrack: some View {
        HStack(spacing: 10) {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.22))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.29, green: 0.81, blue: 1.0), Color(red: 0.42, green: 0.92, blue: 1.0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, proxy.size.width * progressValue))
                }
            }
            .frame(width: 76, height: 8)

            Text(progressLabel)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
                .frame(width: 30, alignment: .trailing)
        }
    }

    private func completeBanner(kind: TransferKind, message: String) -> some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 0) {
                Text(completedTitle(kind: kind))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Text(message)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.8))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            Spacer(minLength: 0)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color(red: 0.24, green: 0.86, blue: 0.37))
        }
    }

    private func completedTitle(kind: TransferKind) -> String {
        switch state {
        case .complete(_, let message):
            if let stem = completionStem(from: message) {
                return stem
            }
            return kind == .send ? "Transfer complete" : "Receive complete"
        default:
            return kind == .send ? "Transfer complete" : "Receive complete"
        }
    }

    private func completionStem(from message: String) -> String? {
        let markers = ["Successfully transferred", "in Downloads.", "directly."]
        for marker in markers {
            if let range = message.range(of: marker) {
                let prefix = message[..<range.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
                if !prefix.isEmpty {
                    return prefix
                }
            }
        }
        return nil
    }

    private var accessibilityLabel: String {
        switch state {
        case .transferring:
            return "LinkaBoo transfer progress \(progressLabel)"
        case .complete(_, let message):
            return "LinkaBoo \(message)"
        default:
            return "LinkaBoo"
        }
    }
}
