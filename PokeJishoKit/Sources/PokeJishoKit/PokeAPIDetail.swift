import Foundation

public struct PokeAPIDetail: Sendable, Equatable {
    public let spriteURL: URL?
    public let facts: [Fact]
    public let flavorText: String?

    public init(spriteURL: URL?, facts: [Fact], flavorText: String?) {
        self.spriteURL = spriteURL
        self.facts = facts
        self.flavorText = flavorText
    }

    public struct Fact: Sendable, Equatable, Identifiable {
        public let label: String
        public let value: String
        public var id: String { label }
        public init(_ label: String, _ value: String) { self.label = label; self.value = value }
    }
}
