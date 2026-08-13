import AppKit
import SwiftUI

@MainActor
final class DropZoneController {
    var onDrop: ((URL) -> Void)?

    private let viewModel = DropZoneViewModel()
    private var panel: DropZonePanel?

    private var pollTimer: Timer?
    private var lastDragChangeCount: Int = 0
    private var isShowing: Bool = false
    private var showStartedAt: Date?

    private var globalMouseUpMonitor: Any?
    private var localMouseUpMonitor: Any?
    private var hideWorkItem: DispatchWorkItem?

    private var panelSize: CGSize { DropZoneView.expandedSize }
    private let dragPasteboard = NSPasteboard(name: .drag)
    private let pollInterval: TimeInterval = 0.04
    private let showTimeout: TimeInterval = 8.0
    private let slideAnimationDuration: TimeInterval = 0.42

    func start() {
        lastDragChangeCount = dragPasteboard.changeCount
        buildPanelIfNeeded()

        let timer = Timer(timeInterval: pollInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
        timer.tolerance = 0.015
        RunLoop.main.add(timer, forMode: .common)
        pollTimer = timer
    }

    func stop() {
        pollTimer?.invalidate()
        pollTimer = nil
        removeMouseMonitors()
        hideWorkItem?.cancel()
        hideWorkItem = nil
        panel?.orderOut(nil)
        panel = nil
    }

    // MARK: - Panel

    private func buildPanelIfNeeded() {
        guard panel == nil else { return }
        let initialRect = NSRect(origin: .zero, size: panelSize)
        let panel = DropZonePanel(contentRect: initialRect)

        let view = DropZoneView(viewModel: viewModel) { [weak self] url in
            self?.handleDrop(url: url)
        }
        let hosting = NSHostingView(rootView: view)
        hosting.frame = initialRect
        panel.contentView = hosting

        self.panel = panel
    }

    // MARK: - Polling loop

    private func tick() {
        let current = dragPasteboard.changeCount

        if current != lastDragChangeCount {
            lastDragChangeCount = current
            if !isShowing, dragPasteboardHasFileURL() {
                show()
            }
        }

        if isShowing, let startedAt = showStartedAt,
           Date().timeIntervalSince(startedAt) > showTimeout {
            hide()
        }
    }

    private func dragPasteboardHasFileURL() -> Bool {
        let options: [NSPasteboard.ReadingOptionKey: Any] = [.urlReadingFileURLsOnly: true]
        return dragPasteboard.canReadObject(forClasses: [NSURL.self], options: options)
    }

    // MARK: - Show / hide

    private func show() {
        buildPanelIfNeeded()
        guard let panel, let screen = preferredScreen() else { return }

        hideWorkItem?.cancel()
        hideWorkItem = nil

        let notch = notchSize(for: screen)
        viewModel.notchSize = notch

        // Center horizontally on the screen; align the top of the panel with the top of
        // the screen so the collapsed pill appears tucked into the notch area.
        let origin = CGPoint(
            x: screen.frame.midX - panelSize.width / 2,
            y: screen.frame.maxY - panelSize.height
        )
        let frame = NSRect(origin: origin, size: panelSize)
        panel.setFrame(frame, display: false)

        viewModel.isHighlighted = true
        viewModel.isVisible = false

        panel.orderFrontRegardless()

        DispatchQueue.main.async { [weak self] in
            self?.viewModel.isVisible = true
        }

        installMouseMonitors()
        isShowing = true
        showStartedAt = Date()
    }

    private func hide() {
        guard isShowing else { return }
        isShowing = false
        showStartedAt = nil

        removeMouseMonitors()
        viewModel.isVisible = false
        viewModel.isHighlighted = false

        let work = DispatchWorkItem { [weak self] in
            self?.panel?.orderOut(nil)
        }
        hideWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + slideAnimationDuration, execute: work)
    }

    // MARK: - Geometry

    /// Returns the size of the collapsed (notch-shaped) drop target for the given screen.
    /// On notched Macs this matches the physical notch width and the menubar height.
    /// On non-notch Macs this is a fake pill of similar dimensions.
    private func notchSize(for screen: NSScreen) -> CGSize {
        let topInset = screen.safeAreaInsets.top
        if topInset > 0 {
            let leftArea = screen.auxiliaryTopLeftArea ?? .zero
            let rightArea = screen.auxiliaryTopRightArea ?? .zero
            let gap = rightArea.minX - leftArea.maxX
            if gap > 100 {
                return CGSize(width: gap, height: topInset)
            }
        }
        return CGSize(width: 200, height: 28)
    }

    private func preferredScreen() -> NSScreen? {
        let mouse = NSEvent.mouseLocation
        if let screen = NSScreen.screens.first(where: { $0.frame.contains(mouse) }) {
            return screen
        }
        return NSScreen.main ?? NSScreen.screens.first
    }

    // MARK: - Drop

    private func handleDrop(url: URL) {
        onDrop?(url)
        hide()
    }

    // MARK: - Mouse monitors

    private func installMouseMonitors() {
        if globalMouseUpMonitor == nil {
            globalMouseUpMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseUp]) { [weak self] _ in
                self?.scheduleHideFromMouseUp()
            }
        }
        if localMouseUpMonitor == nil {
            localMouseUpMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseUp]) { [weak self] event in
                self?.scheduleHideFromMouseUp()
                return event
            }
        }
    }

    private func removeMouseMonitors() {
        if let monitor = globalMouseUpMonitor {
            NSEvent.removeMonitor(monitor)
            globalMouseUpMonitor = nil
        }
        if let monitor = localMouseUpMonitor {
            NSEvent.removeMonitor(monitor)
            localMouseUpMonitor = nil
        }
    }

    private func scheduleHideFromMouseUp() {
        // Defer by a runloop tick so a successful performDragOperation gets a chance to fire first.
        DispatchQueue.main.async { [weak self] in
            guard let self, self.isShowing else { return }
            self.hide()
        }
    }
}
