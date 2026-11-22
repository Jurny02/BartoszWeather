import Foundation

/// The eight compass points used to show where the wind blows from.
nonisolated public enum CompassDirection: Int, CaseIterable, Sendable {
    case north, northEast, east, southEast, south, southWest, west, northWest

    /// Creates the nearest compass point for a meteorological bearing in degrees; any angle is accepted.
    public init(degrees: Double) {
        let normalized = (degrees.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        self = CompassDirection(rawValue: Int((normalized / 45).rounded()) % 8) ?? .north
    }

    /// Rotation in degrees, clockwise, to apply to a symbol that points north.
    public var arrowRotation: Double {
        Double(rawValue) * 45
    }

    public var abbreviation: String {
        switch self {
        case .north: "N"
        case .northEast: "NE"
        case .east: "E"
        case .southEast: "SE"
        case .south: "S"
        case .southWest: "SW"
        case .west: "W"
        case .northWest: "NW"
        }
    }

    /// The point as VoiceOver should read it, such as "northwest".
    public var spokenName: String {
        switch self {
        case .north: String(localized: "north")
        case .northEast: String(localized: "northeast")
        case .east: String(localized: "east")
        case .southEast: String(localized: "southeast")
        case .south: String(localized: "south")
        case .southWest: String(localized: "southwest")
        case .west: String(localized: "west")
        case .northWest: String(localized: "northwest")
        }
    }
}
