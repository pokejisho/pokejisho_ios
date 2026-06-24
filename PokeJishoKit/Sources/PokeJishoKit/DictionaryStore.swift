import Foundation

public final class DictionaryStore: @unchecked Sendable {
    public let entries: [DictionaryEntry]

    public init(entries: [DictionaryEntry]) {
        self.entries = entries
    }

    public static func loadBundled() throws -> DictionaryStore {
        guard let url = Bundle.module.url(forResource: "jisho", withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        let data = try Data(contentsOf: url)
        let entries = try JSONDecoder().decode([DictionaryEntry].self, from: data)
        return DictionaryStore(entries: entries)
    }
}
