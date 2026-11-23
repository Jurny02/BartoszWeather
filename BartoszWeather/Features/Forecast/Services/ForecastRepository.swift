/// The forecast screen's source of forecasts: loads fresh ones and remembers them for later.
nonisolated public protocol ForecastRepository: Sendable {
    /// Loads the city's current forecast and stores it for later use.
    ///
    /// Throws `APIError` when loading fails and `CancellationError` when the calling task is cancelled
    /// during the request; a request that has already finished may still return or throw `APIError`.
    /// A forecast that loads but cannot be stored is still returned.
    func forecast(for city: City) async throws -> Forecast

    /// The city's last stored forecast, or `nil` when none is stored, it is too old to show or the store fails.
    func cachedForecast(for city: City) async -> Forecast?
}
