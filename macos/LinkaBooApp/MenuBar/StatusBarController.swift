import Cocoa
import Combine
import SwiftUI

// MARK: - Drag destination overlay for the menubar icon

class DragDestinationView: NSView {
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
        return .copy
    }

    override func performDragOperation(_ sender: any NSDraggingInfo) -> Bool {
        guard let item = sender.draggingPasteboard.pasteboardItems?.first,
              let urlString = item.string(forType: .fileURL),
              let url = URL(string: urlString) else {
            return false
        }
        onDrop?(url)
        return true
    }
}

// MARK: - Status bar controller

@MainActor
class StatusBarController {
    private let statusItem: NSStatusItem
    private let popover: NSPopover
    let engine = GoEngine()
    private let history = TransferHistoryStore.shared
    private let settingsWindow = SettingsWindowController()
    private let linkCopiedToast = LinkCopiedToastController()
    private var lastCopiedShareCode: String?
    private var eventMonitor: Any?
    private var stateCancellable: AnyCancellable?
    private var transferPopoverView: TransferPopoverView?
    private var dropZone: DropZoneController?
    #if DEBUG
    private var debugWindowController: NSWindowController?
    #endif

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        popover = NSPopover()
        popover.behavior = .transient
        popover.animates = true

        setupButton()
        setupDragDestination()
        setupSettingsWindow()
        setupPopover()
        setupEventMonitor()
        setupDropZone()
        observeEngineState()
    }

    private func setupButton() {
        guard let button = statusItem.button else { return }
        button.image = statusImage(for: .idle)
        button.toolTip = "LinkaBoo"
        button.action = #selector(togglePopover)
        button.target = self
    }

    private func setupDragDestination() {
        guard let button = statusItem.button else { return }
        let dragView = DragDestinationView(frame: button.bounds)
        dragView.autoresizingMask = [.width, .height]
        dragView.onDrop = { [weak self] url in
            guard let self else { return }
            self.transferPopoverView?.startSending(url: url)
            self.showPopover()
        }
        button.addSubview(dragView)
    }

    private func setupSettingsWindow() {
        settingsWindow.onQuit = { NSApp.terminate(nil) }
        #if DEBUG
        settingsWindow.onTestStates = { [weak self] in
            self?.showStatusTestWindow()
        }
        #endif
    }

    private func setupPopover() {
        let contentView = TransferPopoverView(
            engine: engine,
            history: history,
            onOpenSettings: { [weak self] in
                self?.popover.close()
                self?.settingsWindow.show()
            }
        )
        self.transferPopoverView = contentView
        popover.contentViewController = NSHostingController(rootView: contentView)
        syncPopoverContentSize()
    }

    private func syncPopoverContentSize() {
        guard let view = popover.contentViewController?.view else { return }
        view.layoutSubtreeIfNeeded()
        let fitting = view.fittingSize
        if fitting.width > 0, fitting.height > 0 {
            popover.contentSize = fitting
        }
    }

    private func setupEventMonitor() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.popover.close()
        }
    }

    private func setupDropZone() {
        let dropZone = DropZoneController()
        dropZone.onDrop = { [weak self] url in
            guard let self else { return }
            self.transferPopoverView?.startSending(url: url)
            self.showPopover()
        }
        dropZone.start()
        self.dropZone = dropZone
    }

    func showPopover() {
        guard let button = statusItem.button else { return }
        if !popover.isShown {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    /// Called from AppDelegate when a linkaboo://send?path= URL is opened.
    func sendFile(atPath path: String) {
        let url = URL(fileURLWithPath: path)
        transferPopoverView?.startSending(url: url)
        showPopover()
    }

    /// Called from AppDelegate when a linkaboo://receive/<code> URL is opened.
    func receiveTransfer(code: String) {
        transferPopoverView?.startReceiving(code: code)
        showPopover()
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.close()
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func observeEngineState() {
        stateCancellable = engine.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] newState in
                guard let self else { return }
                self.statusItem.button?.image = self.statusImage(for: newState)
                self.syncPopoverContentSize()
                self.handleShareLinkIfNeeded(newState)
            }
    }

    private func handleShareLinkIfNeeded(_ state: TransferState) {
        switch state {
        case .waitingForRecipient(let code, let link, _):
            guard code != lastCopiedShareCode else { return }
            lastCopiedShareCode = code
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(link, forType: .string)
            AppLogger.shared.info("copied share link to pasteboard", category: "ui")
            linkCopiedToast.show()
        case .idle, .complete, .failed:
            lastCopiedShareCode = nil
        default:
            break
        }
    }

    private func statusImage(for state: TransferState) -> NSImage? {
        let name: String
        switch state {
        case .idle:
            name = "BooStatus-Default"
        case .starting:
            name = "BooStatus-Downloading"
        case .waitingForRecipient:
            name = "BooStatus-Downloading"
        case .waitingForSender:
            name = "BooStatus-Downloading"
        case .transferring:
            name = "BooStatus-Transfering"
        case .complete:
            name = "BooStatus-Default"
        case .failed:
            name = "BooStatus-Alert"
        }

        let image = NSImage(named: name)
        image?.isTemplate = true
        image?.size = NSSize(width: 18, height: 18)
        return image
    }

    #if DEBUG
    private func showStatusTestWindow() {
        if let window = debugWindowController?.window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let contentView = StatusTestView(engine: engine)
        let controller = NSHostingController(rootView: contentView)
        let window = NSWindow(contentViewController: controller)
        window.title = "LinkaBoo Test States"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.isReleasedWhenClosed = false
        let windowController = NSWindowController(window: window)
        debugWindowController = windowController
        windowController.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    #endif

    func cleanup() {
        dropZone?.stop()
        dropZone = nil
        engine.cancel()
        stateCancellable = nil
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}
