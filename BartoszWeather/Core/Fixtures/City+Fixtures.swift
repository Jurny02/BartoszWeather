#if DEBUG
import Foundation

extension City {
    /// Fixture city for previews.
    static let krakow = City(
        id: 3_094_802, name: "Kraków", region: "Małopolskie", district: nil, country: "Poland",
        coordinate: Coordinate(latitude: 50.06, longitude: 19.94)
    )

    /// Fixture city for previews.
    static let zakopane = City(
        id: 3_080_165, name: "Zakopane", region: "Małopolskie", district: nil, country: "Poland",
        coordinate: Coordinate(latitude: 49.30, longitude: 19.95)
    )

    /// Fixture city for previews.
    static let hel = City(
        id: 3_099_539, name: "Hel", region: "Pomorskie", district: nil, country: "Poland",
        coordinate: Coordinate(latitude: 54.61, longitude: 18.80)
    )
}
#endif
