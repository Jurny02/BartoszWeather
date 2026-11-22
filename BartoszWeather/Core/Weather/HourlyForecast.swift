import Foundation

/// The forecast for one hour, starting at `date`. A `nil` value was not reported by the forecast source.
nonisolated public struct HourlyForecast: Identifiable, Hashable, Sendable {
    public static let length: TimeInterval = 3_600

    public var id: Date { date }
    public let date: Date
    public let condition: WeatherCondition
    /// Day or night at the city, independent of the device.
    public let isDay: Bool
    /// Degrees Celsius.
    public let temperature: Double?
    /// Percent, 0–100.
    public let precipitationProbability: Int?

    public init(
        date: Date, condition: WeatherCondition, isDay: Bool, temperature: Double?, precipitationProbability: Int?
    ) {
        self.date = date
        self.condition = condition
        self.isDay = isDay
        self.temperature = temperature
        self.precipitationProbability = precipitationProbability
    }

    /// `true` when `moment` falls within this hour, from `date` up to but not including the next hour.
    public func contains(_ moment: Date) -> Bool {
        date <= moment && moment < date.addingTimeInterval(Self.length)
    }
}
