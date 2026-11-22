import Foundation

nonisolated extension CurrentWeather {
    public var temperatureText: String {
        WeatherFormatter.temperature(temperature)
    }

    /// The apparent temperature line under the condition, such as "Feels like 25°".
    public var feelsLikeText: String {
        String(localized: "Feels like \(WeatherFormatter.temperature(apparentTemperature))")
    }

    public var showsStrongWindBadge: Bool {
        wind?.isStrong ?? false
    }

    /// The whole header as one VoiceOver text, such as
    /// "Kraków, Małopolskie, Poland. 24 degrees, Clear sky. Feels like 25 degrees."
    public func accessibilityLabel(city: City) -> String {
        let place = ([city.name] + city.regionAndCountryParts).joined(separator: ", ")
        let now = "\(WeatherFormatter.spokenTemperature(temperature)), \(condition.localizedDescription)"
        var sentences = [place, now]
        if apparentTemperature != nil {
            sentences.append(String(localized: "Feels like \(WeatherFormatter.spokenTemperature(apparentTemperature))"))
        }
        if showsStrongWindBadge {
            sentences.append(String(localized: "Strong wind"))
        }
        return sentences.map { "\($0)." }.joined(separator: " ")
    }
}
