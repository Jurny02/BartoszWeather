import Foundation

nonisolated extension SearchHistoryEntry {
    private var current: CurrentWeather { forecast.current }
    private var today: DailyForecast? { forecast.daily.first }
    private var hasStrongWind: Bool { current.wind?.isStrong ?? false }

    public var temperatureText: String {
        WeatherFormatter.temperature(current.temperature)
    }

    /// The condition, preceded by "Strong wind" when the wind is strong, such as "Strong wind · Overcast".
    public var conditionText: String {
        let condition = current.condition.localizedDescription
        return hasStrongWind ? "\(String(localized: "Strong wind")) · \(condition)" : condition
    }

    /// Today's low and high, such as "14° – 26°", with dashes for values the forecast did not report.
    public var rangeText: String {
        "\(WeatherFormatter.temperature(today?.minTemperature)) – \(WeatherFormatter.temperature(today?.maxTemperature))"
    }

    /// The wind symbol when the wind is strong, otherwise the condition symbol for the city's time of day.
    public var icon: Icon {
        hasStrongWind ? .wind : current.condition.icon(isDay: current.isDay)
    }

    /// The whole card as VoiceOver reads it, such as
    /// "Kraków, Małopolskie, Poland. 24 degrees. Clear sky. Low 14 degrees, high 26 degrees."
    public var accessibilityLabel: String {
        var sentences = [
            ([city.name] + city.regionAndCountryParts).joined(separator: ", "),
            WeatherFormatter.spokenTemperature(current.temperature),
        ]
        if hasStrongWind {
            sentences.append(String(localized: "Strong wind"))
        }
        sentences.append(current.condition.localizedDescription)
        let low = WeatherFormatter.spokenTemperature(today?.minTemperature)
        let high = WeatherFormatter.spokenTemperature(today?.maxTemperature)
        sentences.append(String(localized: "Low \(low), high \(high)"))
        return sentences.map { "\($0)." }.joined(separator: " ")
    }
}

extension SearchHistoryEntry {
    /// Day or night colors, following the time of day at the city.
    public var appearance: WeatherAppearance {
        WeatherAppearance(isDay: forecast.current.isDay)
    }

    public var sky: Sky {
        Sky(condition: forecast.current.condition)
    }
}
