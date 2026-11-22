import Foundation

/// A place found by the city search and kept in the search history.
nonisolated public struct City: Identifiable, Hashable, Codable, Sendable {
    public let id: Int
    public let name: String
    /// First-level administrative area, such as a voivodeship or a state.
    public let region: String?
    /// Second-level administrative area, such as a county or a district.
    public let district: String?
    public let country: String?
    public let coordinate: Coordinate

    public init(id: Int, name: String, region: String?, district: String?, country: String?, coordinate: Coordinate) {
        self.id = id
        self.name = name
        self.region = region
        self.district = district
        self.country = country
        self.coordinate = coordinate
    }
}
