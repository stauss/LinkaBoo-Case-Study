import AppKit
import SwiftUI

@MainActor
final class LinkCopiedToastController {
    private var panel: NSPanel?
    private var dismissWork: DispatchWorkItem?
    private let autoDismissAfter: TimeInterval = 3.5

    func show() {
        dismissWork?.cancel()

        if panel != nil {
            // Already visible — just restart the auto-dismiss timer.
            scheduleAutoDismiss()
            return
        }

        let rootView = LinkCopiedToastView(onDismiss: { [weak self] in
            self?.dismiss(animated: true)
        })
        let hosting = NSHostingController(rootView: rootView)
        hosting.view.layer?.backgroundColor = NSColor.clear.cgColor

        let newPanel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 52),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        newPanel.isOpaque = false
        newPanel.backgroundColor = .clear
        newPanel.hasShadow = false
        newPanel.level = .statusBar
        newPanel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient, .ignoresCycle]
        newPanel.isMovable = false
        newPanel.isReleasedWhenClosed = false
        newPanel.hidesOnDeactivate = false
        newPanel.contentViewController = hosting

        hosting.view.layoutSubtreeIfNeeded()
        let size = hosting.view.fittingSize
        newPanel.setContentSize(size)

        if let screen = NSScreen.main {
            let origin = NSPoint(
                x: screen.frame.midX - size.width / 2,
                y: screen.visibleFrame.maxY - size.height - 12
            )
            newPanel.setFrameOrigin(origin)
        }

        newPanel.alphaValue = 0
        newPanel.orderFrontRegardless()
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.18
            newPanel.animator().alphaValue = 1
        }

        self.panel = newPanel
        scheduleAutoDismiss()
    }

    func dismiss(animated: Bool = true) {
        dismissWork?.cancel()
        dismissWork = nil
        guard let panel else { return }
        self.panel = nil

        guard animated else {
            panel.orderOut(nil)
            return
        }

        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.18
            panel.animator().alphaValue = 0
        }, completionHandler: {
            panel.orderOut(nil)
        })
    }

    private func scheduleAutoDismiss() {
        dismissWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.dismiss(animated: true)
        }
        dismissWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + autoDismissAfter, execute: work)
    }
}
