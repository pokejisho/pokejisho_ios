import Foundation

/// Cleans raw OCR-selected text into a single-line search query.
/// Trims surrounding whitespace/newlines and collapses internal whitespace
/// runs (including newlines from multi-line selections) into single spaces.
/// Does not perform search normalization — `DictionaryStore.search` handles that.
public func normalizeScannedText(_ raw: String) -> String {
    raw
        .components(separatedBy: .whitespacesAndNewlines)
        .filter { !$0.isEmpty }
        .joined(separator: " ")
}
