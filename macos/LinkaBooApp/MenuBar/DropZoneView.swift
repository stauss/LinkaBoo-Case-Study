import AppKit
import SwiftUI

@MainActor
final class DropZoneViewModel: ObservableObject {
    @Published var isVisible: Bool = false
    @Published var isHighlighted: Bool = false
    /// The collapsed (at-rest) size of the drop zone, matching the screen's notch (or a
    /// fallback pill on non-notch Macs). The controller computes this and pushes it in
    /// before showing the panel.
    @Published var notchSize: CGSize = CGSize(width: 200, height: 28)
}

struct DropZoneView: View {
    @ObservedObject var viewModel: DropZoneViewModel
    var onDrop: (URL) -> Void

    /// Expanded drop-zone size shown when a drag hovers over the notch.
    static let expandedSize = CGSize(width: 200, height: 120)

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                PartiallyRoundedRectangle(topRadius: currentTopRadius, bottomRadius: currentBottomRadius)
                    .fill(Color.black)
                    .frame(width: currentWidth, height: currentHeight)
                    .shadow(
                        color: .black.opacity(viewModel.isHighlighted ? 0.45 : 0),
                        radius: viewModel.isHighlighted ? 22 : 0,
                        y: 10
                    )

                if viewModel.isHighlighted {
                    VStack(spacing: 0) {
                        // TODO: we should use Text here but I currently don't have access to edit the Figma
                        // Text("Drag. Drop. Depart.")
                        //     .font(.subheadline.weight(.medium))
                        //     .foregroundStyle(.white)
                        //     .padding(.top, 14)

                        Spacer(minLength: 0)

                        Image("DropZoneBackground")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                    }
                    .frame(width: currentWidth, height: currentHeight)
                    .clipShape(PartiallyRoundedRectangle(topRadius: currentTopRadius, bottomRadius: currentBottomRadius))
                    .transition(.opacity)
                }

                DropReceiver(
                    onEnter: { viewModel.isHighlighted = true },
                    onExit: { viewModel.isHighlighted = false },
                    onDrop: { url in
                        viewModel.isHighlighted = false
                        onDrop(url)
                    }
                )
                .frame(width: currentWidth, height: currentHeight)
            }
            .animation(.spring(response: 0.38, dampingFraction: 0.78), value: viewModel.isHighlighted)
            .animation(.easeOut(duration: 0.2), value: viewModel.isVisible)

            Spacer(minLength: 0)
        }
        .frame(width: Self.expandedSize.width, height: Self.expandedSize.height)
        .opacity(viewModel.isVisible ? 1 : 0)
        .ignoresSafeArea()
    }

    private var currentWidth: CGFloat {
        viewModel.isHighlighted ? Self.expandedSize.width : viewModel.notchSize.width
    }

    private var currentHeight: CGFloat {
        viewModel.isHighlighted ? Self.expandedSize.height : viewModel.notchSize.height
    }

    private var currentTopRadius: CGFloat {
        // Square top when expanded; pill ends when collapsed in the notch.
        // if viewModel.isHighlighted { return 0 }
        // return min(viewModel.notchSize.width, viewModel.notchSize.height) / 2

        // Always square at the top so the shape sits flush with the screen edge / notch.
        return 0
    }

    private var currentBottomRadius: CGFloat {
        if viewModel.isHighlighted { return 28 }
        return min(viewModel.notchSize.width, viewModel.notchSize.height) / 2
    }
}

// MARK: - Shape

private struct PartiallyRoundedRectangle: Shape {
    var topRadius: CGFloat
    var bottomRadius: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(topRadius, bottomRadius) }
        set { topRadius = newValue.first; bottomRadius = newValue.second }
    }

    func path(in rect: CGRect) -> Path {
        let maxRadius = min(rect.width, rect.height) / 2
        let tr = max(0, min(topRadius, maxRadius))
        let br = max(0, min(bottomRadius, maxRadius))

        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + tr))
        if tr > 0 {
            path.addArc(
                center: CGPoint(x: rect.minX + tr, y: rect.minY + tr),
                radius: tr,
                startAngle: .degrees(180), endAngle: .degrees(270),
                clockwise: false
            )
        }
        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        if tr > 0 {
            path.addArc(
                center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr),
                radius: tr,
                startAngle: .degrees(270), endAngle: .degrees(0),
                clockwise: false
            )
        }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        if br > 0 {
            path.addArc(
                center: CGPoint(x: rect.maxX - br, y: rect.maxY - br),
                radius: br,
                startAngle: .degrees(0), endAngle: .degrees(90),
                clockwise: false
            )
        }
        path.addLine(to: CGPoint(x: rect.minX + br, y: rect.maxY))
        if br > 0 {
            path.addArc(
                center: CGPoint(x: rect.minX + br, y: rect.maxY - br),
                radius: br,
                startAngle: .degrees(90), endAngle: .degrees(180),
                clockwise: false
            )
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Drop receiver

private struct DropReceiver: NSViewRepresentable {
    var onEnter: () -> Void
    var onExit: () -> Void
    var onDrop: (URL) -> Void

    func makeNSView(context: Context) -> DropReceiverView {
        let view = DropReceiverView()
        view.onEnter = onEnter
        view.onExit = onExit
        view.onDrop = onDrop
        return view
    }

    func updateNSView(_ nsView: DropReceiverView, context: Context) {
        nsView.onEnter = onEnter
        nsView.onExit = onExit
        nsView.onDrop = onDrop
    }
}

final class DropReceiverView: NSView {
    var onEnter: (() -> Void)?
    var onExit: (() -> Void)?
    var onDrop: ((URL) -> Void)?

    override init(frame: NSRect) {
        super.init(frame: frame)
        registerForDraggedTypes([.fileURL])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.fileURL])
    }

    override func draggingEntered(_ sender: any NSDraggingInfo) -> NSDragOperation {
        onEnter?()
        return .copy
    }

    override func draggingExited(_ sender: (any NSDraggingInfo)?) {
        onExit?()
    }

    override func draggingEnded(_ sender: any NSDraggingInfo) {
        onExit?()
    }

    override func performDragOperation(_ sender: any NSDraggingInfo) -> Bool {
        let pb = sender.draggingPasteboard
        let options: [NSPasteboard.ReadingOptionKey: Any] = [.urlReadingFileURLsOnly: true]
        guard let urls = pb.readObjects(forClasses: [NSURL.self], options: options) as? [URL],
              let url = urls.first else {
            return false
        }
        onDrop?(url)
        return true
    }
}
