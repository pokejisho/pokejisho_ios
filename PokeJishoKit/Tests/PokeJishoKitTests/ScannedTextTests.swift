import Testing
@testable import PokeJishoKit

@Test func trimsLeadingAndTrailingWhitespace() {
    #expect(normalizeScannedText("  ピカチュウ  ") == "ピカチュウ")
}

@Test func collapsesInternalNewlinesToSpaces() {
    #expect(normalizeScannedText("Karate\nChop") == "Karate Chop")
}

@Test func collapsesMultipleWhitespaceRuns() {
    #expect(normalizeScannedText("Karate \n  Chop") == "Karate Chop")
}

@Test func emptyOrWhitespaceOnlyReturnsEmpty() {
    #expect(normalizeScannedText("") == "")
    #expect(normalizeScannedText("   \n  ") == "")
}
