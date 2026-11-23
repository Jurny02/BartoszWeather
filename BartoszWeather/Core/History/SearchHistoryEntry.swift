import Foundation

/// A previously opened city with the forecast its history card shows.
nonisolated public struct SearchHistoryEntry: Identifiable, Hashable, Sendable {
    public var id: City.ID { city.id }
    public let city: City
    public let forecast: Forecast

    public init(city: City, forecast: Forecast) {
        self.city = city
        self.forecast = forecast
    }
}
