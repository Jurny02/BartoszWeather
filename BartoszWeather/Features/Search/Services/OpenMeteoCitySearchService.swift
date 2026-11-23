import Foundation

/// Searches cities with the Open-Meteo geocoding API and maps the places it returns to `City`.
nonisolated public struct OpenMeteoCitySearchService: CitySearchService {
    private let client: any APIClient
    private let language: String

    /// - Parameter language: A lower-case language code for the names of cities, regions and countries.
    public init(client: any APIClient, language: String) {
        self.client = client
        self.language = language
    }

    public func cities(matching query: String) async throws -> [City] {
        let response = try await client.send(GeocodingSearchEndpoint(name: query, language: language))
        return (response.results ?? []).compactMap(City.init(place:))
    }
}

nonisolated private extension City {
    init?(place: GeocodingPlaceDTO) {
        guard (-90...90).contains(place.latitude), (-180...180).contains(place.longitude) else { return nil }
        self.init(
            id: place.id,
            name: place.name,
            region: Self.nonBlank(place.admin1),
            district: Self.nonBlank(place.admin2),
            country: Self.nonBlank(place.country),
            coordinate: Coordinate(latitude: place.latitude, longitude: place.longitude)
        )
    }

    static func nonBlank(_ text: String?) -> String? {
        guard let text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return text
    }
}
