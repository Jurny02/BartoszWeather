import Foundation

/// Searches Open-Meteo for places whose name matches a query, most relevant first.
///
/// A query that matches nothing still succeeds, with `results` left out of the response.
nonisolated public struct GeocodingSearchEndpoint: OpenMeteoEndpoint {
    public typealias Response = GeocodingSearchResponseDTO

    public let name: String
    /// The maximum number of places, 1–100. The server answers 400 outside that range.
    public let count: Int
    /// A lower-case language code that translates the names, countries and regions.
    public let language: String

    public init(name: String, count: Int = 10, language: String) {
        self.name = name
        self.count = count
        self.language = language
    }

    public var baseURL: URL { URL(string: "https://geocoding-api.open-meteo.com")! }
    public var path: String { "/v1/search" }

    public var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "count", value: String(count)),
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "format", value: "json"),
        ]
    }
}
