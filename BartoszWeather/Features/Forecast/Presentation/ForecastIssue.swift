import Foundation

/// Why the forecast could not be loaded or refreshed.
nonisolated public enum ForecastIssue: Hashable, Sendable {
    case offline
    /// The weather service's request limit has been reached.
    case rateLimited
    /// The weather service is down or overloaded.
    case serviceUnavailable
    case failure

    /// The issue behind a failed load: `offline`, `rateLimited` for HTTP 429,
    /// `serviceUnavailable` for HTTP 5xx, and `failure` for anything else.
    public init(error: any Error) {
        self = switch error as? APIError {
        case .offline: .offline
        case .server(status: 429, _): .rateLimited
        case .server(status: 500...599, _): .serviceUnavailable
        default: .failure
        }
    }

    /// The full-screen state shown when there is no forecast to fall back on. Every issue offers a retry.
    public var message: ForecastStateMessage {
        switch self {
        case .offline:
            ForecastStateMessage(
                icon: .wifiSlash,
                title: String(localized: "No internet connection"),
                message: String(localized: "Check your connection and try again.")
            )
        case .rateLimited:
            ForecastStateMessage(
                icon: .clockBadgeExclamationmark,
                title: String(localized: "Too many requests"),
                message: String(localized: "The weather service limit has been reached. Please try again later.")
            )
        case .serviceUnavailable:
            ForecastStateMessage(
                icon: .exclamationmarkIcloud,
                title: String(localized: "Weather service unavailable"),
                message: String(localized: "The service is temporarily down. Please try again in a few minutes.")
            )
        case .failure:
            ForecastStateMessage(
                icon: .exclamationmarkTriangle,
                title: String(localized: "Something went wrong"),
                message: String(localized: "We couldn't load the data. Please try again.")
            )
        }
    }

    /// The icon of the status line shown above a forecast that could not be refreshed.
    public var statusIcon: Icon {
        self == .offline ? .wifiSlash : .arrowClockwise
    }

    /// The status line shown above a forecast that could not be refreshed, such as
    /// "No connection · Showing data from 14:05", with the time in the city's time zone.
    public func statusText(lastUpdated: Date, timeZone: TimeZone) -> String {
        let time = WeatherFormatter(timeZone: timeZone).hour(lastUpdated)
        return switch self {
        case .offline: String(localized: "No connection · Showing data from \(time)")
        case .rateLimited, .serviceUnavailable, .failure: String(localized: "Couldn't refresh · Showing data from \(time)")
        }
    }
}

/// The icon and copy of a full-screen error state on the forecast screen.
nonisolated public struct ForecastStateMessage: Hashable, Sendable {
    public let icon: Icon
    public let title: String
    public let message: String
}
