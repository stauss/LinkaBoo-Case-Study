import Combine
import Foundation
import UniformTypeIdentifiers

enum TransferRecordKind: String, Codable {
    case send
    case receive
}

enum TransferRecordStatus: Equatable {
    case pending
    case inProgress(percent: Double)
    case complete
    case failed(reason: String)
    case canceled

    var isTerminal: Bool {
        switch self {
        case .complete, .failed, .canceled: return true
        case .pending, .inProgress: return false
        }
    }
}

extension TransferRecordStatus: Codable {
    private enum Kind: String, Codable {
        case pending, inProgress, complete, failed, canceled
    }

    private enum CodingKeys: String, CodingKey {
        case kind
        case percent
        case reason
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try c.decode(Kind.self, forKey: .kind)
        switch kind {
        case .pending: self = .pending
        case .inProgress:
            self = .inProgress(percent: try c.decodeIfPresent(Double.self, forKey: .percent) ?? 0)
        case .complete: self = .complete
        case .failed:
            self = .failed(reason: try c.decodeIfPresent(String.self, forKey: .reason) ?? "Unknown error")
        case .canceled: self = .canceled
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .pending:
            try c.encode(Kind.pending, forKey: .kind)
        case .inProgress(let percent):
            try c.encode(Kind.inProgress, forKey: .kind)
            try c.encode(percent, forKey: .percent)
        case .complete:
            try c.encode(Kind.complete, forKey: .kind)
        case .failed(let reason):
            try c.encode(Kind.failed, forKey: .kind)
            try c.encode(reason, forKey: .reason)
        case .canceled:
            try c.encode(Kind.canceled, forKey: .kind)
        }
    }
}

struct TransferRecord: Codable, Identifiable, Equatable {
    let id: UUID
    var kind: TransferRecordKind
    var itemName: String
    /// Final path on disk for locating the item ("Show in Finder"). For sends
    /// this is the source path; for receives, the destination path.
    var itemPath: String?
    var byteSize: Int64?
    var itemCount: Int?
    var isFolder: Bool
    var startedAt: Date
    var updatedAt: Date
    var status: TransferRecordStatus

    init(
        id: UUID = UUID(),
        kind: TransferRecordKind,
        itemName: String,
        itemPath: String? = nil,
        byteSize: Int64? = nil,
        itemCount: Int? = nil,
        isFolder: Bool = false,
        startedAt: Date = Date(),
        updatedAt: Date = Date(),
        status: TransferRecordStatus = .pending
    ) {
        self.id = id
        self.kind = kind
        self.itemName = itemName
        self.itemPath = itemPath
        self.byteSize = byteSize
        self.itemCount = itemCount
        self.isFolder = isFolder
        self.startedAt = startedAt
        self.updatedAt = updatedAt
        self.status = status
    }
}

@MainActor
final class TransferHistoryStore: ObservableObject {
    static let shared = TransferHistoryStore()

    @Published private(set) var records: [TransferRecord] = []

    private let fileURL: URL
    private let maxEntries = 200
    private let ioQueue = DispatchQueue(label: "app.linkaboo.history.io")

    init(fileURL: URL? = nil) {
        let url = fileURL ?? TransferHistoryStore.defaultFileURL()
        self.fileURL = url
        load()
    }

    private static func defaultFileURL() -> URL {
        let dir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?.appendingPathComponent("LinkaBoo", isDirectory: true)
            ?? URL(fileURLWithPath: NSHomeDirectory())
                .appendingPathComponent("Library/Application Support/LinkaBoo")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("history.json")
    }

    func upsert(_ record: TransferRecord) {
        var updated = record
        updated.updatedAt = Date()
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = updated
        } else {
            records.insert(updated, at: 0)
        }
        trim()
        scheduleSave()
    }

    func remove(id: UUID) {
        records.removeAll { $0.id == id }
        scheduleSave()
    }

    func clear() {
        records.removeAll()
        scheduleSave()
    }

    private func trim() {
        if records.count > maxEntries {
            records = Array(records.prefix(maxEntries))
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let decoded = try? decoder.decode([TransferRecord].self, from: data) {
            self.records = decoded.sorted { $0.updatedAt > $1.updatedAt }
        }
    }

    private func scheduleSave() {
        let snapshot = records
        let url = fileURL
        ioQueue.async {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            do {
                let data = try encoder.encode(snapshot)
                try data.write(to: url, options: .atomic)
            } catch {
                AppLogger.shared.error("history save failed: \(error.localizedDescription)", category: "history")
            }
        }
    }
}

enum TransferRecordInspector {
    static func describe(path: String) -> (byteSize: Int64?, itemCount: Int?, isFolder: Bool) {
        let url = URL(fileURLWithPath: path)
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDir) else {
            return (nil, nil, false)
        }
        if isDir.boolValue {
            let (bytes, count) = directorySize(url: url)
            return (bytes, count, true)
        }
        if let attrs = try? FileManager.default.attributesOfItem(atPath: path),
           let size = attrs[.size] as? NSNumber {
            return (size.int64Value, nil, false)
        }
        return (nil, nil, false)
    }

    private static func directorySize(url: URL) -> (Int64, Int) {
        var total: Int64 = 0
        var count = 0
        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return (0, 0)
        }
        for case let fileURL as URL in enumerator {
            let values = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
            if values?.isRegularFile == true {
                count += 1
                total += Int64(values?.fileSize ?? 0)
            }
        }
        return (total, count)
    }

    static func typeLabel(name: String, isFolder: Bool) -> String {
        if isFolder { return "Folder" }
        let ext = (name as NSString).pathExtension
        if !ext.isEmpty, let type = UTType(filenameExtension: ext), let desc = type.localizedDescription {
            return desc.capitalized
        }
        return "File"
    }
}
