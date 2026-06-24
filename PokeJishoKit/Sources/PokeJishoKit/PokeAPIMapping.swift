import Foundation

public enum PokeAPIResource: String, Sendable {
    case pokemon, move, item, ability, nature

    public init?(type: EntryType) {
        switch type {
        case .pokemon: self = .pokemon
        case .move: self = .move
        case .item: self = .item
        case .ability: self = .ability
        case .nature: self = .nature
        case .character, .location: return nil
        }
    }
}

public func pokeAPISlug(for english: String) -> String {
    var s = english.lowercased()
    for ch in ["'", ".", ":", ",", "(", ")"] { s = s.replacingOccurrences(of: ch, with: "") }
    s = s.replacingOccurrences(of: " ", with: "-")
    s = s.replacingOccurrences(of: "--", with: "-")
    return s
}
