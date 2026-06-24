import Testing
@testable import PokeJishoKit

private func store() -> DictionaryStore {
    DictionaryStore(entries: [
        .init(type: .pokemon, english: "Pikachu", japanese: "ピカチュウ", katakana: "ピカチュウ", romaji: "pikachuu"),
        .init(type: .move, english: "Pound", japanese: "はたく", katakana: "ハタク", romaji: "hataku"),
    ])
}

@Test func resolvesIDsToEntriesInOrder() {
    let s = store()
    let pikachu = s.entries.first { $0.english == "Pikachu" }!
    let pound = s.entries.first { $0.english == "Pound" }!
    let result = s.entries(ids: [pound.id, pikachu.id])
    #expect(result.map(\.english) == ["Pound", "Pikachu"])
}

@Test func skipsUnknownIDs() {
    let s = store()
    let result = s.entries(ids: ["nonexistent|Foo|バー"])
    #expect(result.isEmpty)
}
