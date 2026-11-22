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

    /// The whole row as one VoiceOver sentence; `dayLabel` is the weekday or "Today".
    public func accessibilityLabel(dayLabel: String) -> String {
        var parts = [dayLabel, condition.localizedDescription]
        if let minTemperature {
            parts.append(String(localized: "low \(WeatherFormatter.spokenTemperature(minTemperature))"))
        }
        if let maxTemperature {
            parts.append(String(localized: "high \(WeatherFormatter.spokenTemperature(maxTemperature))"))
        }
        if let precipitationProbability {
            parts.append(String(localized: "\(precipitationProbability)% chance of precipitation"))
        }
        return parts.joined(separator: ", ")
    }

    /// The lowest low and the highest high across `days`, or `nil` when no temperature was reported.
    public static func temperatureRange(of days: [DailyForecast]) -> ClosedRange<Double>? {
        let temperatures = days.flatMap { [$0.minTemperature, $0.maxTemperature] }.compactMap { $0 }
        guard let lowest = temperatures.min(), let highest = temperatures.max() else { return nil }
        return lowest...highest
    }
}
