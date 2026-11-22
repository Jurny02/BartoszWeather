import Foundation

/// Conditions at the time of the forecast request. A `nil` value was not reported by the forecast source.
nonisolated public struct CurrentWeather: Hashable, Sendable {
    public let date: Date
    public let condition: WeatherCondition
    /// Day or night at the city, independent of the device.
    public let isDay: Bool
    /// Degrees Celsius.
    public let temperature: Double?
    /// Degrees Celsius.
    public let apparentTemperature: Double?
    /// Percent, 0–100.
    public let humidity: Int?
    /// Percent, 0–100.
    public let cloudCover: Int?
    /// Percent, 0–100.
    public let precipitationProbability: Int?
    public let wind: Wind?

    public init(
        date: Date,
        condition: WeatherCondition,
        isDay: Bool,
        temperature: Double?,
        apparentTemperature: Double?,
        humidity: Int?,
        cloudCover: Int?,
        precipitationProbability: Int?,
        wind: Wind?
    ) {
        self.date = date
        self.condition = condition
        self.isDay = isDay
        self.temperature = temperature
        self.apparentTemperature = apparentTemperature
        self.humidity = humidity
        self.cloudCover = cloudCover
        self.precipitationProbability = precipitationProbability
        self.wind = wind
    }
}
