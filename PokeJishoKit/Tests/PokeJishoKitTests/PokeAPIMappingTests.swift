import Testing
@testable import PokeJishoKit

@Test func mapsSupportedTypes() {
    #expect(PokeAPIResource(type: .pokemon) == .pokemon)
    #expect(PokeAPIResource(type: .move) == .move)
    #expect(PokeAPIResource(type: .item) == .item)
    #expect(PokeAPIResource(type: .ability) == .ability)
    #expect(PokeAPIResource(type: .nature) == .nature)
}

@Test func unsupportedTypesReturnNil() {
    #expect(PokeAPIResource(type: .character) == nil)
    #expect(PokeAPIResource(type: .location) == nil)
}

@Test func buildsSlug() {
    #expect(pokeAPISlug(for: "Red Apricorn") == "red-apricorn")
    #expect(pokeAPISlug(for: "Mr. Mime") == "mr-mime")
    #expect(pokeAPISlug(for: "Pikachu") == "pikachu")
}
