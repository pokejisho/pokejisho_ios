import Testing
@testable import PokeJishoKit

private func store() -> DictionaryStore {
    DictionaryStore(entries: [
        .init(type: .pokemon, english: "Pikachu", japanese: "ピカチュウ", katakana: "ピカチュウ", romaji: "pikachuu"),
        .init(type: .pokemon, english: "Raichu", japanese: "ライチュウ", katakana: "ライチュウ", romaji: "raichuu"),
        .init(type: .move, english: "Karate Chop", japanese: "からてチョップ", katakana: "カラテチョップ", romaji: "karatechoppu"),
    ])
}

@Test func exactEnglishGoesToPriority() {
    let r = store().search("Pikachu", filter: nil)
    #expect(r.priority.contains { $0.english == "Pikachu" })
    #expect(r.results.contains { $0.english == "Pikachu" } == false)
}

@Test func partialEnglishGoesToResults() {
    let r = store().search("chu", filter: nil)
    #expect(r.priority.isEmpty)
    #expect(r.results.count >= 1)
}

@Test func hiraganaQueryMatchesKatakanaEntry() {
    let r = store().search("ぴかちゅう", filter: nil)
    #expect(r.priority.contains { $0.english == "Pikachu" })
}

@Test func englishMatchIgnoresSpacesAndCase() {
    let r = store().search("karatechop", filter: nil)
    #expect(r.results.contains { $0.english == "Karate Chop" } || r.priority.contains { $0.english == "Karate Chop" })
}

@Test func accentedEIsNormalized() {
    let s = DictionaryStore(entries: [
        .init(type: .pokemon, english: "Flabebe", japanese: "フラベベ", katakana: "フラベベ", romaji: "furabebe")
    ])
    let r = s.search("Flabébé", filter: nil)
    #expect(r.priority.contains { $0.english == "Flabebe" })
}

@Test func filterRestrictsType() {
    let r = store().search("chu", filter: .move)
    #expect(r.priority.isEmpty && r.results.isEmpty)
}
