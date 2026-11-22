import Foundation

/// The weather for one city: now, by hour and by day.
nonisolated public struct Forecast: Hashable, Sendable {
    public let current: CurrentWeather
    /// Hours in chronological order, one hour apart.
    public let hourly: [HourlyForecast]
    /// Days in chronological order.
    public let daily: [DailyForecast]
    /// The city's time zone, used to show hours and weekdays in local time.
    public let timeZone: TimeZone
    public let updatedAt: Date

    public init(
        current: CurrentWeather,
        hourly: [HourlyForecast],
        daily: [DailyForecast],
        timeZone: TimeZone,
        updatedAt: Date
    ) {
        self.current = current
        self.hourly = hourly
        self.daily = daily
        self.timeZone = timeZone
        self.updatedAt = updatedAt
    }

    /// Up to `count` hours, starting with the hour that contains `date`.
    public func hours(from date: Date, count: Int) -> [HourlyForecast] {
        Array(hourly.lazy.filter { $0.contains(date) || $0.date > date }.prefix(max(count, 0)))
    }
}
