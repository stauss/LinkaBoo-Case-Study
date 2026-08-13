import Cocoa

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NotificationManager.shared.requestPermission()
        statusBarController = StatusBarController()
    }

    func applicationWillTerminate(_ notification: Notification) {
        statusBarController?.cleanup()
    }

    // Handle linkaboo:// URL scheme (from Finder extension and landing page deep links)
    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first, url.scheme == "linkaboo" else {
            AppLogger.shared.warning("ignoring open urls: \(urls.map { $0.absoluteString })", category: "urlhandler")
            return
        }
        AppLogger.shared.info("open \(url.absoluteString)", category: "urlhandler")

        switch url.host {
        case "send":
            // linkaboo://send?path=/encoded/path
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let pathItem = components.queryItems?.first(where: { $0.name == "path" }),
               let path = pathItem.value {
                statusBarController?.sendFile(atPath: path)
            }
        case "receive":
            // linkaboo://receive/7-crossword-clockwork
            let code = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            AppLogger.shared.info("receive code='\(code)'", category: "urlhandler")
            if !code.isEmpty {
                statusBarController?.receiveTransfer(code: code)
            }
        default:
            AppLogger.shared.warning("unknown url host '\(url.host ?? "nil")'", category: "urlhandler")
        }
    }
}
