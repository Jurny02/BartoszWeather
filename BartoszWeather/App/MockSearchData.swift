import Foundation

/// Temporary stand-in for the forecast service, built from preview fixtures.
///
/// Debug builds open fixture forecasts; release builds have none. Replaced by the real forecast service in the next step.
struct MockSearchData {
    #if DEBUG
    private let history = SearchHistoryEntry.previewEntries

    /// The fixture forecast of a history city, or Kraków's for any other city.
    func forecast(for city: City) -> Forecast? {
        history.first { $0.city.id == city.id }?.forecast ?? .krakowDay
    }
    #else
    func forecast(for city: City) -> Forecast? {
        nil
    }
    #endif
}
