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
}
