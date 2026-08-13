import SwiftUI

struct LinkCopiedToastView: View {
    var onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image("BooContext-Solid-Detailed")
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)

            Text("Link Copied to Clipboard!")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)

            Spacer(minLength: 6)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 20, height: 20)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 10)
        .padding(.trailing, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.75))
        )
        .overlay(
            Capsule()
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.35), radius: 12, x: 0, y: 4)
    }
}
