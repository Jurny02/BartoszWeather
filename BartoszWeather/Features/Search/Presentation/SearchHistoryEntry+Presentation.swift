import Foundation

/// An entry without a forecast reads as missing data: dashes, "No data" and the unknown condition by day.
nonisolated extension SearchHistoryEntry {
    private var current: CurrentWeather? { forecast?.current }
    private var today: DailyForecast? { forecast?.daily.first }
    private var condition: WeatherCondition { current?.condition ?? .unknown }
    private var isDay: Bool { current?.isDay ?? true }
    private var hasStrongWind: Bool { current?.wind?.isStrong ?? false }

    public var temperatureText: String {
        WeatherFormatter.temperature(current?.temperature)
    }

    /// The condition, preceded by "Strong wind" when the wind is strong, such as "Strong wind · Overcast";
    /// "No data" without a forecast.
    public var conditionText: String {
        guard current != nil else { return WeatherFormatter.noData }
        let description = condition.localizedDescription
        return hasStrongWind ? "\(String(localized: "Strong wind")) · \(description)" : description
    }

    /// Today's low and high, such as "14° – 26°", with dashes for values the forecast did not report.
    public var rangeText: String {
        "\(WeatherFormatter.temperature(today?.minTemperature)) – \(WeatherFormatter.temperature(today?.maxTemperature))"
    }

    /// The wind symbol when the wind is strong, otherwise the condition symbol for the city's time of day.
    public var icon: Icon {
        hasStrongWind ? .wind : condition.icon(isDay: isDay)
    }

    /// The whole card as VoiceOver reads it, such as
    /// "Kraków, Małopolskie, Poland. 24 degrees. Clear sky. Low 14 degrees, high 26 degrees.";
    /// without a forecast, the place followed by "No data."
    public var accessibilityLabel: String {
        var sentences = [([city.name] + city.regionAndCountryParts).joined(separator: ", ")]
        if let current {
            sentences.append(WeatherFormatter.spokenTemperature(current.temperature))
            if hasStrongWind {
                sentences.append(String(localized: "Strong wind"))
            }
            sentences.append(current.condition.localizedDescription)
            let low = WeatherFormatter.spokenTemperature(today?.minTemperature)
            let high = WeatherFormatter.spokenTemperature(today?.maxTemperature)
            sentences.append(String(localized: "Low \(low), high \(high)"))
        } else {
            sentences.append(WeatherFormatter.noData)
        }
        return sentences.map { "\($0)." }.joined(separator: " ")
    }
}

extension SearchHistoryEntry {
    /// Day or night colors, following the time of day at the city.
    public var appearance: WeatherAppearance {
        WeatherAppearance(isDay: isDay)
    }

    public var sky: Sky {
        Sky(condition: condition)
    }
}
