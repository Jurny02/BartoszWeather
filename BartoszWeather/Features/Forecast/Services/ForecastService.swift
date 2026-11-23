/// Loads the weather for a city: now, by hour and by day.
nonisolated public protocol ForecastService: Sendable {
    /// Throws `APIError` when loading fails and `CancellationError` when the calling task is cancelled
    /// during the request; a request that has already finished may still return or throw `APIError`.
    func forecast(for city: City) async throws -> Forecast
}
