import SwiftUI

/// Whether weather content is shown with the day or the night card colors.
///
/// Set it once on a container with `.environment(\.weatherAppearance, .night)`;
/// weather components read their color roles from it.
nonisolated public enum WeatherAppearance: Sendable {
    case day
    case night
}

extension WeatherAppearance {
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
