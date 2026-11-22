import Foundation

/// The weather described by a WMO weather interpretation code.
nonisolated public enum WeatherCondition: Hashable, Sendable {
    case clearSky
    case mainlyClear
    case partlyCloudy
    case overcast
    case fog
    case drizzle
    case freezingDrizzle
    case rain
    case heavyRain
    case freezingRain
    case snow
    case snowGrains
    case rainShowers
    case snowShowers
    case thunderstorm
    case thunderstormWithHail
    case unknown

    /// Creates the condition for a WMO code (WMO 4677, as used by Open-Meteo); unrecognised codes give `unknown`.
    public init(wmoCode: Int) {
        self = switch wmoCode {
        case 0: .clearSky
        case 1: .mainlyClear
        case 2: .partlyCloudy
        case 3: .overcast
        case 45, 48: .fog
        case 51, 53, 55: .drizzle
        case 56, 57: .freezingDrizzle
        case 61, 63: .rain
        case 65, 82: .heavyRain
        case 66, 67: .freezingRain
        case 71, 73, 75: .snow
        case 77: .snowGrains
        case 80, 81: .rainShowers
        case 85, 86: .snowShowers
        case 95: .thunderstorm
        case 96, 99: .thunderstormWithHail
        default: .unknown
        }
    }
}
