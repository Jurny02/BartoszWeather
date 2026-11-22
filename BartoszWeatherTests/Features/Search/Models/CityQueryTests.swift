import Testing
@testable import BartoszWeather

/// Tests how the typed text is normalized and classified before a city search.
struct CityQueryTests {
    @Test(arguments: ["", "   ", "\n\t"])
    func blankTextIsEmpty(text: String) {
        #expect(CityQuery(text) == .empty)
    }

    @Test(arguments: ["K", " ł "])
    func oneLetterIsTooShort(text: String) {
        #expect(CityQuery(text) == .tooShort)
    }

    @Test(arguments: [
        ("Kraków", "Kraków"),
        ("Bielsko-Biała", "Bielsko-Biała"),
        ("Nowy Sącz", "Nowy Sącz"),
        ("東京", "東京"),
        ("Zürich", "Zürich"),
    ])
    func lettersSpacesAndHyphensAreValid(text: String, query: String) {
        #expect(CityQuery(text) == .valid(query))
    }

    @Test func trimsAndCollapsesSpaces() {
        #expect(CityQuery("  Nowy   Sącz \n") == .valid("Nowy Sącz"))
    }

    @Test(arguments: ["Kraków123", "Krak1", "1", "Paris, France", "Kraków!", "Hel 🌊", "Hel\u{0007}", "L'Aquila"])
    func otherCharactersAreInvalid(text: String) {
        #expect(CityQuery(text) == .invalid)
    }

    @Test(arguments: ["-", "--", "- -"])
    func textWithoutLettersIsInvalid(text: String) {
        #expect(CityQuery(text) == .invalid)
    }

    @Test func capsTheLength() {
        let long = String(repeating: "a", count: 80)
        #expect(CityQuery(long) == .valid(String(repeating: "a", count: CityQuery.maxLength)))
    }

    @Test func doesNotEndWithASpaceWhenTheCapCutsAtOne() {
        let long = String(repeating: "a", count: CityQuery.maxLength - 1) + " bbb"
        #expect(CityQuery(long) == .valid(String(repeating: "a", count: CityQuery.maxLength - 1)))
    }
}
