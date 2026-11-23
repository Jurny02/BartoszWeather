/// Keeps the last loaded forecast of each recent city, so it can be shown again later, for example offline.
nonisolated public protocol ForecastStore: Sendable {
    /// Saves the forecast as the city's newest history entry, replacing the city's older entry.
    /// The oldest entries may be dropped to keep the history short.
    ///
    /// Throws when the store cannot be written.
    func save(_ forecast: Forecast, for city: City) async throws

    /// The city's stored forecast, or `nil` when none is stored or it is too old to show.
    ///
    /// Throws when the store cannot be read.
    func forecast(for cityID: City.ID) async throws -> Forecast?
}
