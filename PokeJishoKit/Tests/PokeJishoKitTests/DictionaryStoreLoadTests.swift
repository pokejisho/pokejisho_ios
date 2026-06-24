import Testing
@testable import PokeJishoKit

@Test func loadsAll4340Entries() throws {
    let store = try DictionaryStore.loadBundled()
    #expect(store.entries.count == 4340)
}

@Test func containsKnownPokemon() throws {
    let store = try DictionaryStore.loadBundled()
    #expect(store.entries.contains { $0.english == "Pikachu" && $0.type == .pokemon })
}
