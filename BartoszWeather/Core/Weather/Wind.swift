import Foundation

/// Wind at 10 meters above ground.
nonisolated public struct Wind: Hashable, Sendable {
    public static let strongSpeed: Double = 40
    public static let strongGusts: Double = 60

    /// Kilometers per hour.
    public let speed: Double
    /// Kilometers per hour.
    public let gusts: Double?
    /// Meteorological bearing in degrees: the direction the wind blows from, clockwise from north.
    public let direction: Double?

    public init(speed: Double, gusts: Double?, direction: Double?) {
        self.speed = speed
        self.gusts = gusts
        self.direction = direction
    }

    /// `true` when the speed reaches `strongSpeed` or the gusts reach `strongGusts`.
    public var isStrong: Bool {
        speed >= Self.strongSpeed || (gusts ?? 0) >= Self.strongGusts
    }
}
