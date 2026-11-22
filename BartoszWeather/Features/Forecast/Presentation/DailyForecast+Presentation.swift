import Foundation

nonisolated extension DailyForecast {
    public var lowText: String {
        WeatherFormatter.temperature(minTemperature)
    }

    public var highText: String {
        WeatherFormatter.temperature(maxTemperature)
    }

    public var precipitationText: String {
        WeatherFormatter.percent(precipitationProbability)
    }

    /// The whole row as one VoiceOver sentence, reading missing values as "No data"; `dayLabel` is the weekday or "Today".
    public func accessibilityLabel(dayLabel: String) -> String {
        var parts = [dayLabel, condition.localizedDescription]
        let noData = WeatherFormatter.noData
        parts.append(
            minTemperature == nil
                ? String(localized: "low: \(noData)")
                : String(localized: "low \(WeatherFormatter.spokenTemperature(minTemperature))")
        )
        parts.append(
            maxTemperature == nil
                ? String(localized: "high: \(noData)")
                : String(localized: "high \(WeatherFormatter.spokenTemperature(maxTemperature))")
        )
        parts.append(
            precipitationProbability.map { String(localized: "\($0)% chance of precipitation") }
                ?? String(localized: "chance of precipitation: \(noData)")
        )
        return parts.joined(separator: ", ")
    }

    /// The lowest low and the highest high across `days`, or `nil` when no temperature was reported.
    public static func temperatureRange(of days: [DailyForecast]) -> ClosedRange<Double>? {
        let temperatures = days.flatMap { [$0.minTemperature, $0.maxTemperature] }.compactMap { $0 }
        guard let lowest = temperatures.min(), let highest = temperatures.max() else { return nil }
        return lowest...highest
    }
}
