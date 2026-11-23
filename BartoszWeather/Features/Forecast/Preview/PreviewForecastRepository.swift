#if DEBUG
/// A `ForecastRepository` for previews: answers every load with the same fixture result and offers
/// a fixed stored forecast, without the network or a store.
nonisolated struct PreviewForecastRepository: ForecastRepository {
    let result: Result<Forecast, APIError>
    var cached: Forecast?

    func forecast(for city: City) async throws -> Forecast {
        try Task.checkCancellation()
        return try result.get()
    }

    func cachedForecast(for city: City) async -> Forecast? {
        cached
    }
}
#endif
