import Foundation

/// A recently loaded city with its last forecast, newest first in the search history.
nonisolated public struct SearchHistoryEntry: Identifiable, Hashable, Sendable {
    public var id: City.ID { city.id }
    public let city: City
    /// The last loaded forecast, or `nil` once it is too old to show.
    public let forecast: Forecast?

    public init(city: City, forecast: Forecast?) {
        self.city = city
        self.forecast = forecast
    }
}
