import Cocoa
import FinderSync

class FinderSyncExtension: FIFinderSync {

    override init() {
        super.init()
        // Monitor all volumes so the context menu appears everywhere
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/")]
    }

    // MARK: - Context Menu

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        let menu = NSMenu(title: "LinkaBoo")
        let item = NSMenuItem(
            title: "Link-a-Boo",
            action: #selector(sendWithBoo(_:)),
            keyEquivalent: ""
        )
        let icon = NSImage(named: "BooContext-Solid")
        icon?.isTemplate = true
        item.image = icon
        menu.addItem(item)
        return menu
    }

    @objc func sendWithBoo(_ sender: Any?) {
        guard let items = FIFinderSyncController.default().selectedItemURLs(),
              let firstItem = items.first else {
            return
        }

        // Encode the path and open via the main app's URL scheme
        let encodedPath = firstItem.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? firstItem.path
        if let url = URL(string: "linkaboo://send?path=\(encodedPath)") {
            NSWorkspace.shared.open(url)
        }
    }
}
