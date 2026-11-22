import Foundation

/// What the search screen shows below the search field.
nonisolated public enum SearchCityContent: Hashable, Sendable {
    /// Nothing searched yet and no history.
    case prompt
    /// Recently opened cities, newest first.
    case history([SearchHistoryEntry])
    case loading
    case results(query: String, cities: [City])
    /// The query contains characters other than letters, spaces and hyphens.
    case invalidInput
    case noResults(query: String)
    case offline
    case failure

    public var isInputInvalid: Bool {
        self == .invalidInput
    }

    /// The red message under the search field, shown only for invalid input.
    public var validationMessage: String? {
        isInputInvalid ? String(localized: "Only letters, spaces and hyphens are allowed.") : nil
    }

    /// The hint shown in place of results while the input is invalid.
    public static var invalidInputHint: String {
        String(localized: "Try “Nowy Sącz” or “Bielsko-Biała”")
    }

    /// The empty or error state, or `nil` when the screen shows history, results, loading or the invalid-input hint.
    public var stateMessage: SearchStateMessage? {
        switch self {
        case .prompt:
            SearchStateMessage(
                icon: .cloudSunFill,
                title: String(localized: "Search for a city to see the weather"),
                message: String(localized: "Your next forecast is a search away."),
                showsRetry: false
            )
        case .noResults(let query):
            SearchStateMessage(
                icon: .magnifyingGlass,
                title: String(localized: "No city found for “\(query)”"),
                message: String(localized: "Check the spelling"),
                showsRetry: false
            )
        case .offline:
            SearchStateMessage(
                icon: .wifiSlash,
                title: String(localized: "No internet connection"),
                message: String(localized: "Check your connection and try again."),
                showsRetry: true
            )
        case .failure:
            SearchStateMessage(
                icon: .exclamationmarkTriangle,
                title: String(localized: "Something went wrong"),
                message: String(localized: "We couldn't load the data. Please try again."),
                showsRetry: true
            )
        case .history, .loading, .results, .invalidInput:
            nil
        }
    }

    /// The number of found cities, such as "3 results" or "1 result".
    public static func resultCountText(_ count: Int) -> String {
        count == 1 ? String(localized: "1 result") : String(localized: "\(count) results")
    }
}

/// The icon and copy of an empty or error state on the search screen.
nonisolated public struct SearchStateMessage: Hashable, Sendable {
    public let icon: Icon
    public let title: String
    public let message: String
    public let showsRetry: Bool
}
