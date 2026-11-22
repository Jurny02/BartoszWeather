import Foundation

nonisolated extension HourlyForecast {
    /// Chances below this percentage are not shown in the hourly cell.
    public static let visiblePrecipitationThreshold = 10

    public var temperatureText: String {
        WeatherFormatter.temperature(temperature)
    }

    public var precipitationText: String {
        WeatherFormatter.percent(precipitationProbability)
    }

    /// `false` for a low chance of precipitation, which the cell hides while keeping its space.
    public var showsPrecipitation: Bool {
        guard let precipitationProbability else { return true }
        return precipitationProbability >= Self.visiblePrecipitationThreshold
    }

    /// The whole cell as one VoiceOver sentence, reading missing values as "No data"; `timeLabel` is the hour or "Now".
    public func accessibilityLabel(timeLabel: String) -> String {
        var parts = [timeLabel, WeatherFormatter.spokenTemperature(temperature), condition.localizedDescription]
        if let precipitationProbability {
            if showsPrecipitation {
                parts.append(String(localized: "\(precipitationProbability)% chance of precipitation"))
            }
        } else {
            parts.append(String(localized: "chance of precipitation: \(WeatherFormatter.noData)"))
        }
        return parts.joined(separator: ", ")
    }
}
