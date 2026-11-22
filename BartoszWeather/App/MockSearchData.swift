import Foundation

/// Temporary stand-in for the search view model and the forecast service, built from preview fixtures.
///
/// Debug builds show the fixture history, filter fixture cities by name and open fixture forecasts;
/// release builds show the empty prompt. Replaced by real services in the next step.
struct MockSearchData {
    #if DEBUG
    private let history = SearchHistoryEntry.previewEntries
    private var cities: [City] { City.searchResults + [.zakopane, .hel] }

    func content(for query: String) -> SearchCityContent {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return .history(history) }
        let matches = cities.filter { $0.highlightedNameRange(matching: query) != nil }
        return matches.isEmpty ? .noResults(query: query) : .results(query: query, cities: matches)
    }

    /// The fixture forecast of a history city, or Kraków's for any other city.
    func forecast(for city: City) -> Forecast? {
        history.first { $0.city.id == city.id }?.forecast ?? .krakowDay
    }
    #else
    func content(for query: String) -> SearchCityContent {
        .prompt
    }

    func forecast(for city: City) -> Forecast? {
        nil
    }
    #endif
}
