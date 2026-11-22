import Foundation

nonisolated struct WindDirection: Equatable, Sendable {
    let degrees: Double

    private var compassPointIndex: Int {
        let normalized = degrees.truncatingRemainder(dividingBy: 360) + 360
        return Int((normalized / 45).rounded()) % 8
    }

    var abbreviation: String {
        ["N", "NE", "E", "SE", "S", "SW", "W", "NW"][compassPointIndex]
    }

    var spokenName: String {
        [
            String(localized: "north"),
            String(localized: "northeast"),
            String(localized: "east"),
            String(localized: "southeast"),
            String(localized: "south"),
            String(localized: "southwest"),
            String(localized: "west"),
            String(localized: "northwest"),
        ][compassPointIndex]
    }
}
