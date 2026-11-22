import Foundation
import Testing
@testable import BartoszWeather

/// Tests the result subtitle and the highlighted name prefix of a found city.
struct CitySearchPresentationTests {
    private func city(
        name: String = "Kraków", region: String? = "Małopolskie", district: String? = "Kraków", country: String? = "Poland"
    ) -> City {
        City(
            id: 1, name: name, region: region, district: district, country: country,
            coordinate: Coordinate(latitude: 50.06, longitude: 19.94)
        )
    }

    @Test func joinsRegionAndDistrictBeforeTheCountry() {
        #expect(city().resultSubtitle == "Małopolskie, Kraków · Poland")
    }

    @Test(arguments: [
        (String?("Wisconsin"), String?.none, String?("United States"), String?("Wisconsin · United States")),
        (nil, "Kraków", "Poland", "Kraków · Poland"),
        ("Małopolskie", "Kraków", nil, "Małopolskie, Kraków"),
        (nil, nil, "Poland", "Poland"),
        ("  ", " ", "", nil),
        (nil, nil, nil, nil),
    ])
    func leavesOutMissingOrBlankParts(region: String?, district: String?, country: String?, expected: String?) {
        #expect(city(region: region, district: district, country: country).resultSubtitle == expected)
    }

    @Test(arguments: [
        ("Krak", "Krak"),
        ("krak", "Krak"),
        ("krako", "Krakó"),
        ("  Krak ", "Krak"),
    ])
    func highlightsTheTypedPrefixIgnoringCaseAndDiacritics(query: String, expected: String) throws {
        let name = "Kraków"
        let range = try #require(city(name: name).highlightedNameRange(matching: query))
        #expect(String(name[range]) == expected)
    }

    @Test(arguments: ["", "   ", "rak", "Warsaw", "Krakówek"])
    func highlightsNothingWhenTheNameDoesNotStartWithTheQuery(query: String) {
        #expect(city().highlightedNameRange(matching: query) == nil)
    }
}
