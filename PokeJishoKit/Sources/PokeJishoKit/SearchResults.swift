public struct SearchResults: Sendable, Equatable {
    public let priority: [DictionaryEntry]
    public let results: [DictionaryEntry]
    public var isEmpty: Bool { priority.isEmpty && results.isEmpty }
    public init(priority: [DictionaryEntry], results: [DictionaryEntry]) {
        self.priority = priority
        self.results = results
    }
}
