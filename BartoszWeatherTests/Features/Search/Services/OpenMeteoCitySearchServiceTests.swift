import Testing
@testable import BartoszWeather

/// Tests that the Open-Meteo city search sends the right request and maps found places to cities.
struct OpenMeteoCitySearchServiceTests {
    private let krakowPlace = GeocodingPlaceDTO(
        id: 3_094_802, name: "Kraków", latitude: 50.06143, longitude: 19.93658,
        country: "Polska", admin1: "Województwo małopolskie", admin2: "Kraków", timezone: "Europe/Warsaw"
    )

    @Test func searchesByNameInTheGivenLanguage() async throws {
        let client = FakeAPIClient(response: GeocodingSearchResponseDTO(results: []))
        let service = OpenMeteoCitySearchService(client: client, language: "pl")

        _ = try await service.cities(matching: "Kraków")

        let endpoint = try #require(client.sentEndpoints.first as? GeocodingSearchEndpoint)
        #expect(client.sentEndpoints.count == 1)
        #expect(endpoint.name == "Kraków")
        #expect(endpoint.language == "pl")
    }

    @Test func mapsPlacesToCitiesInServerOrder() async throws {
        let mcMurdo = GeocodingPlaceDTO(
            id: 13_664_897, name: "McMurdo Station", latitude: -77.84114, longitude: 166.75272,
            country: nil, admin1: nil, admin2: nil, timezone: "Antarctica/McMurdo"
        )
        let client = FakeAPIClient(response: GeocodingSearchResponseDTO(results: [krakowPlace, mcMurdo]))

        let cities = try await OpenMeteoCitySearchService(client: client, language: "pl").cities(matching: "K")

        #expect(cities == [
            City(
                id: 3_094_802, name: "Kraków", region: "Województwo małopolskie", district: "Kraków", country: "Polska",
                coordinate: Coordinate(latitude: 50.06143, longitude: 19.93658)
            ),
            City(
                id: 13_664_897, name: "McMurdo Station", region: nil, district: nil, country: nil,
                coordinate: Coordinate(latitude: -77.84114, longitude: 166.75272)
            ),
        ])
    }

    @Test func treatsBlankAreasAsMissing() async throws {
        let place = GeocodingPlaceDTO(
            id: 1, name: "Hel", latitude: 54.61, longitude: 18.80, country: " ", admin1: "", admin2: "\n", timezone: nil
        )
        let client = FakeAPIClient(response: GeocodingSearchResponseDTO(results: [place]))

        let city = try #require(try await OpenMeteoCitySearchService(client: client, language: "en").cities(matching: "Hel").first)

        #expect(city.region == nil)
        #expect(city.district == nil)
        #expect(city.country == nil)
    }

    @Test func dropsPlacesWithImpossibleCoordinates() async throws {
        let broken = GeocodingPlaceDTO(
            id: 2, name: "Nowhere", latitude: 150, longitude: 19.9, country: nil, admin1: nil, admin2: nil, timezone: nil
        )
        let client = FakeAPIClient(response: GeocodingSearchResponseDTO(results: [broken, krakowPlace]))

        let cities = try await OpenMeteoCitySearchService(client: client, language: "pl").cities(matching: "K")

        #expect(cities.map(\.id) == [3_094_802])
    }

    @Test func findsNoCitiesWhenResultsAreMissing() async throws {
        let client = FakeAPIClient(response: GeocodingSearchResponseDTO(results: nil))

        let cities = try await OpenMeteoCitySearchService(client: client, language: "en").cities(matching: "Xqzzqx")

        #expect(cities.isEmpty)
    }

    @Test func passesClientErrorsThrough() async {
        let client = FakeAPIClient(error: APIError.offline)

        await #expect(throws: APIError.offline) {
            try await OpenMeteoCitySearchService(client: client, language: "en").cities(matching: "Hel")
        }
    }
}
