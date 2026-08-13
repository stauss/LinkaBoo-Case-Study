import AppKit
import UserNotifications

@MainActor
final class NotificationManager {

    static let shared = NotificationManager()
    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    // MARK: - Notification stubs (logic to be implemented)

    /// Called when a file/folder has been successfully shared.
    func notifyShared(fileName: String) {
        // TODO: implement delivery
        // Attachment image: NotificationAttachment-BooShared
    }

    /// Called when a transfer is delivered to the recipient.
    func notifyDelivered(fileName: String) {
        // TODO: implement delivery
        // Attachment image: NotificationAttachment-BooDeliver
    }

    /// Called when the recipient accepts with joy / first-time receive.
    func notifyJoy() {
        // TODO: implement delivery
        // Attachment image: NotificationAttachment-BooJoy
    }

    /// Called when sharing a document type.
    func notifyDocument(fileName: String) {
        // TODO: implement delivery
        // Attachment image: NotificationAttachment-Documents
    }

    /// Called when sharing a folder.
    func notifyFolder(folderName: String) {
        // TODO: implement delivery
        // Attachment image: NotificationAttachment-Folders
    }

    // MARK: - Attachment helper (ready to use when stubs are implemented)

    /// Returns a UNNotificationAttachment for a named PNG in the app bundle.
    /// Note: UNNotificationAttachment requires a file URL, not an asset catalog lookup.
    /// The PNG files must also be present in Copy Bundle Resources for this to work.
    func attachment(named name: String) -> UNNotificationAttachment? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "png") else { return nil }
        return try? UNNotificationAttachment(identifier: name, url: url, options: nil)
    }
}
