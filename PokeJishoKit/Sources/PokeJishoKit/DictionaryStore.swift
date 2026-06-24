import Foundation

public final class DictionaryStore: @unchecked Sendable {
    public let entries: [DictionaryEntry]
    private let byID: [String: DictionaryEntry]

    public init(entries: [DictionaryEntry]) {
        self.entries = entries
        self.byID = Dictionary(entries.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
    }

    public static func loadBundled() throws -> DictionaryStore {
        guard let url = Bundle.module.url(forResource: "jisho", withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        let data = try Data(contentsOf: url)
        let entries = try JSONDecoder().decode([DictionaryEntry].self, from: data)
        return DictionaryStore(entries: entries)
    }

    /// Resolves stored entry ids (e.g. favorites) back to entries, skipping unknown ids.
    public func entries(ids: some Sequence<String>) -> [DictionaryEntry] {
        ids.compactMap { byID[$0] }
    }
}
