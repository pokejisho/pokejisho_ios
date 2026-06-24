import Foundation

extension DictionaryStore {
    public func search(_ query: String, filter: EntryType? = nil) -> SearchResults {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return SearchResults(priority: [], results: []) }

        let normalized = trimmed.replacingOccurrences(of: "é", with: "e")
        let cTerm = normalized.lowercased().replacingOccurrences(of: " ", with: "")
        let katakanaTerm = normalized.applyingTransform(.hiraganaToKatakana, reverse: false) ?? normalized

        var priority: [DictionaryEntry] = []
        var results: [DictionaryEntry] = []

        for entry in entries {
            if let filter, entry.type != filter { continue }
            let cEnglish = entry.english.lowercased().replacingOccurrences(of: " ", with: "")
            let cRomaji = entry.romaji.lowercased().replacingOccurrences(of: " ", with: "")
            let matches = cEnglish.contains(cTerm)
                || entry.katakana.contains(katakanaTerm)
                || cRomaji.contains(cTerm)
            guard matches else { continue }
            let isExact = cEnglish == cTerm || entry.katakana == katakanaTerm || cRomaji == cTerm
            if isExact { priority.append(entry) } else { results.append(entry) }
        }
        return SearchResults(priority: priority, results: results)
    }
}
