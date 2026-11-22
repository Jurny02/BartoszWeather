import Foundation

nonisolated extension WeatherCondition {
    /// The weather symbol for the condition, with a moon variant after dark where one exists.
    public func icon(isDay: Bool) -> Icon {
        switch self {
        case .clearSky, .mainlyClear: isDay ? .sunMaxFill : .moonStarsFill
        case .partlyCloudy: isDay ? .cloudSunFill : .cloudMoonFill
        case .overcast: .cloudFill
        case .fog: .cloudFogFill
        case .drizzle: .cloudDrizzleFill
        case .freezingDrizzle, .freezingRain: .cloudSleetFill
        case .rain: .cloudRainFill
        case .heavyRain: .cloudHeavyrainFill
        case .snow, .snowGrains, .snowShowers: .cloudSnowFill
        case .rainShowers: isDay ? .cloudSunRainFill : .cloudMoonRainFill
        case .thunderstorm: .cloudBoltRainFill
        case .thunderstormWithHail: .cloudHailFill
        case .unknown: .exclamationmarkIcloud
        }
    }

    /// A short sentence-case description such as "Clear sky".
    public var localizedDescription: String {
        switch self {
        case .clearSky: String(localized: "Clear sky")
        case .mainlyClear: String(localized: "Mainly clear")
        case .partlyCloudy: String(localized: "Partly cloudy")
        case .overcast: String(localized: "Overcast")
        case .fog: String(localized: "Fog")
        case .drizzle: String(localized: "Drizzle")
        case .freezingDrizzle: String(localized: "Freezing drizzle")
        case .rain: String(localized: "Rain")
        case .heavyRain: String(localized: "Heavy rain")
        case .freezingRain: String(localized: "Freezing rain")
        case .snow: String(localized: "Snow")
        case .snowGrains: String(localized: "Snow grains")
        case .rainShowers: String(localized: "Rain showers")
        case .snowShowers: String(localized: "Snow showers")
        case .thunderstorm: String(localized: "Thunderstorm")
        case .thunderstormWithHail: String(localized: "Thunderstorm with hail")
        case .unknown: String(localized: "Unknown conditions")
        }
    }
}
