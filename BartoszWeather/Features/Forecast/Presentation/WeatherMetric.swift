import Foundation

/// One of the four current-conditions tiles, carrying the value it shows and deriving all of its texts from it.
///
/// A `nil` value means the forecast source did not report it; the tile then shows a dash and "No data".
nonisolated public enum WeatherMetric: Hashable, Identifiable, Sendable {
    /// Percent, 0–100.
    case cloudCover(Int?)
    /// Chance of precipitation in the next hour, percent 0–100.
    case precipitation(Int?)
    case wind(Wind?)
    /// Relative humidity, percent 0–100.
    case humidity(Int?)

    public var id: String { title }

    /// The four tiles in display order for the current conditions.
    public static func metrics(for current: CurrentWeather) -> [WeatherMetric] {
        [
            .cloudCover(current.cloudCover),
            .precipitation(current.precipitationProbability),
            .wind(current.wind),
            .humidity(current.humidity),
        ]
    }

    public var icon: Icon {
        switch self {
        case .cloudCover: .cloudFill
        case .precipitation: .dropFill
        case .wind: .wind
        case .humidity: .humidityFill
        }
    }

    public var title: String {
        switch self {
        case .cloudCover: String(localized: "Cloud cover")
        case .precipitation: String(localized: "Chance of rain")
        case .wind: String(localized: "Wind")
        case .humidity: String(localized: "Humidity")
        }
    }

    public var value: String {
        switch self {
        case .cloudCover(let percent), .precipitation(let percent), .humidity(let percent):
            WeatherFormatter.percent(percent)
        case .wind(let wind):
            WeatherFormatter.speed(wind?.speed)
        }
    }

    public var caption: String {
        switch self {
        case .cloudCover(let percent):
            percent.map(Self.cloudDescription) ?? WeatherFormatter.noData
        case .precipitation(let percent):
            percent == nil ? WeatherFormatter.noData : String(localized: "Next hour")
        case .wind(let wind):
            wind == nil ? WeatherFormatter.noData : String(localized: "Gusts \(WeatherFormatter.speed(wind?.gusts))")
        case .humidity(let percent):
            percent == nil ? WeatherFormatter.noData : String(localized: "Relative humidity")
        }
    }

    /// The point the wind blows from, when the wind and its bearing are known.
    public var direction: CompassDirection? {
        guard case .wind(let wind) = self, let bearing = wind?.direction else { return nil }
        return CompassDirection(degrees: bearing)
    }

    /// `true` for strong wind, which the tile draws with an emphasized value and border.
    public var isHighlighted: Bool {
        guard case .wind(let wind) = self else { return false }
        return wind?.isStrong ?? false
    }

    /// The whole tile as one VoiceOver sentence, reading missing values as "No data".
    public var accessibilityLabel: String {
        guard hasValue else { return "\(title), \(WeatherFormatter.noData)" }
        var parts = [title, value]
        if let direction {
            parts.append(String(localized: "from \(direction.spokenName)"))
        }
        parts.append(spokenCaption)
        if isHighlighted {
            parts.append(String(localized: "strong wind"))
        }
        return parts.joined(separator: ", ")
    }

    private var hasValue: Bool {
        switch self {
        case .cloudCover(let percent), .precipitation(let percent), .humidity(let percent): percent != nil
        case .wind(let wind): wind != nil
        }
    }

    private var spokenCaption: String {
        guard case .wind(let wind?) = self, wind.gusts == nil else { return caption }
        return String(localized: "Gusts: \(WeatherFormatter.noData)")
    }

    private static func cloudDescription(percent: Int) -> String {
        switch percent {
        case ..<11: String(localized: "Clear sky")
        case ..<51: String(localized: "Partly cloudy")
        case ..<86: String(localized: "Mostly cloudy")
        default: String(localized: "Overcast")
        }
    }
}
