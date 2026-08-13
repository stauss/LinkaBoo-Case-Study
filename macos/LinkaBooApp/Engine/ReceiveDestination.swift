import Foundation

enum ReceiveDestination {
    private static let defaultsKey = "ReceiveDestinationPath"

    static var current: URL {
        get {
            if let path = UserDefaults.standard.string(forKey: defaultsKey) {
                return URL(fileURLWithPath: path)
            }
            return FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
                ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Downloads")
        }
        set {
            UserDefaults.standard.set(newValue.path, forKey: defaultsKey)
        }
    }
}
