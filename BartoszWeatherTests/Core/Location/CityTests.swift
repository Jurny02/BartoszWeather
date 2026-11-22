import Foundation
import Testing
@testable import BartoszWeather

struct CityTests {
    @Test func survivesAnEncodingRoundTrip() throws {
        let city = City(
            id: 3_094_802,
            name: "Bielsko-Biała",
            region: "Województwo śląskie",
            district: nil,
            country: "Polska",
            coordinate: Coordinate(latitude: 49.82, longitude: 19.04)
        )

        let data = try JSONEncoder().encode(city)

        #expect(try JSONDecoder().decode(City.self, from: data) == city)
    }

    @Test(arguments: [
        ("Małopolskie", "Poland" as String?, "Małopolskie · Poland" as String?),
        (nil, "Poland", "Poland"),
        ("Małopolskie", nil, "Małopolskie"),
        ("  ", "Poland", "Poland"),
        ("", "", nil),
        (nil, nil, nil),
    ] as [(String?, String?, String?)])
    func describesTheCityByRegionAndCountry(region: String?, country: String?, expected: String?) {
        let city = City(
            id: 1, name: "Kraków", region: region, district: nil, country: country,
            coordinate: Coordinate(latitude: 50.06, longitude: 19.94)
        )

        #expect(city.regionAndCountry == expected)
    }

    @Test func listsTrimmedRegionAndCountryParts() {
        let city = City(
            id: 1, name: "Kraków", region: " Małopolskie ", district: "Kraków", country: "",
            coordinate: Coordinate(latitude: 50.06, longitude: 19.94)
        )

        #expect(city.regionAndCountryParts == ["Małopolskie"])
    }
}
