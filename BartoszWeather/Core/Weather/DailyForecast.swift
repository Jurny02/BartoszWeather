import Foundation

/// The forecast for one day, starting at local midnight in the city. A `nil` value was not reported by the forecast source.
nonisolated public struct DailyForecast: Identifiable, Hashable, Sendable {
    public var id: Date { date }
    public let date: Date
    public let condition: WeatherCondition
    /// Degrees Celsius.
    public let minTemperature: Double?
    /// Degrees Celsius.
    public let maxTemperature: Double?
    /// Highest hourly chance during the day, percent 0–100.
    public let precipitationProbability: Int?

    public init(
        date: Date,
        condition: WeatherCondition,
        minTemperature: Double?,
        maxTemperature: Double?,
        precipitationProbability: Int?
    ) {
        self.date = date
        self.condition = condition
        self.minTemperature = minTemperature
        self.maxTemperature = maxTemperature
        self.precipitationProbability = precipitationProbability
    }
}
