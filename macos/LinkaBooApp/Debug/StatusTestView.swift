#if DEBUG
import AppKit
import SwiftUI

struct StatusTestView: View {
    @ObservedObject var engine: GoEngine

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Status Testing")
                .font(.headline)
            Divider()
            ForEach(TransferState.allCases, id: \.self) { state in
                Button(action: { engine.forceState(state) }) {
                    HStack {
                        Image(nsImage: stateIcon(state))
                            .resizable()
                            .frame(width: 16, height: 16)
                        Text(state.debugLabel)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .frame(width: 240)
    }

    private func stateIcon(_ state: TransferState) -> NSImage {
        let name: String
        switch state {
        case .idle, .complete:
            name = "BooStatus-Default"
        case .starting,
             .waitingForRecipient,
             .waitingForSender:
            name = "BooStatus-Downloading"
        case .transferring:
            name = "BooStatus-Transfering"
        case .failed:
            name = "BooStatus-Alert"
        }

        let image = NSImage(named: name) ?? NSImage()
        image.isTemplate = false
        image.size = NSSize(width: 16, height: 16)
        return image
    }
}
#endif
