import SwiftUI

/// Whether weather content is shown with the day or the night color roles.
///
/// Set it once on a container with `.environment(\.weatherAppearance, .night)`;
/// weather components read their color roles from it.
public enum WeatherAppearance: Sendable {
    case day
    case night

    /// Creates the appearance for daylight or darkness at the city, independent of the device color scheme.
    public init(isDay: Bool) {
        self = isDay ? .day : .night
    }

    public var card: ColorResource {
        switch self {
        case .day: .Weather.card
        case .night: .Weather.nightCard
        }
    }

    public var text: ColorResource {
        switch self {
        case .day: .Weather.text
        case .night: .Weather.onNight
        }
    }

    public var secondaryText: ColorResource {
        switch self {
        case .day: .Weather.secondary
        case .night: .Weather.nightSecondary
        }
    }

    public var accent: ColorResource {
        switch self {
        case .day: .accent
        case .night: .Weather.nightAccent
        }
    }

    public var selection: ColorResource {
        switch self {
        case .day: .Surface.selected
        case .night: .Weather.nightCard
        }
    }

    public var symbolAccent: ColorResource {
        switch self {
        case .day: .Weather.sun
        case .night: .Weather.onNight
        }
    }

    public var badgeText: ColorResource {
        switch self {
        case .day: .Wind.badgeText
        case .night: .Weather.onNight
        }
    }

    public var highlight: ColorResource {
        switch self {
        case .day: .Wind.strongValue
        case .night: .Weather.nightAccent
        }
    }
}

extension EnvironmentValues {
    @Entry public var weatherAppearance: WeatherAppearance = .day
}
