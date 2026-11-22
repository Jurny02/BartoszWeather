/// The body of a successful city search.
nonisolated public struct GeocodingSearchResponseDTO: Decodable, Equatable, Sendable {
    /// The places found, most relevant first; `nil` when nothing matched.
    public let results: [GeocodingPlaceDTO]?

    public init(results: [GeocodingPlaceDTO]?) {
        self.results = results
    }
}

/// One place returned by the city search. The server leaves out fields it has no value for.
nonisolated public struct GeocodingPlaceDTO: Decodable, Equatable, Sendable {
    public let id: Int
    public let name: String
    public let latitude: Double
    public let longitude: Double
    public let country: String?
    /// First-level administrative area, such as a voivodeship or a state.
    public let admin1: String?
    /// Second-level administrative area, such as a county or a district.
    public let admin2: String?
    /// The place's time zone identifier, such as "Europe/Warsaw".
    public let timezone: String?

    public init(
        id: Int, name: String, latitude: Double, longitude: Double,
        country: String?, admin1: String?, admin2: String?, timezone: String?
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.country = country
        self.admin1 = admin1
        self.admin2 = admin2
        self.timezone = timezone
    }
}
