import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController {
    private var windowController: NSWindowController?

    var onQuit: () -> Void = { NSApp.terminate(nil) }
    var onTestStates: (() -> Void)?

    func show() {
        if let controller = windowController {
            controller.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let rootView = SettingsView(onQuit: onQuit, onTestStates: onTestStates)
        let hosting = NSHostingController(rootView: rootView)

        let window = NSWindow(contentViewController: hosting)
        window.title = "LinkaBoo Settings"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.isReleasedWhenClosed = false
        window.center()

        let controller = NSWindowController(window: window)
        windowController = controller
        controller.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
