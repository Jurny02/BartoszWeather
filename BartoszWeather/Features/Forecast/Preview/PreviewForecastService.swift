#if DEBUG
/// A `ForecastService` for previews: answers every load with the same fixture result, without the network.
nonisolated struct PreviewForecastService: ForecastService {
    let result: Result<Forecast, APIError>

    func forecast(for city: City) async throws -> Forecast {
        try Task.checkCancellation()
        return try result.get()
    }
}
#endif
