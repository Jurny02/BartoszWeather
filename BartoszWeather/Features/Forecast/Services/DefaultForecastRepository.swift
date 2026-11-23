import os

/// A `ForecastRepository` that loads forecasts from a `ForecastService` and keeps each one in a `ForecastStore`.
///
/// Store failures are logged and never fail a load.
nonisolated public struct DefaultForecastRepository: ForecastRepository {
    private let service: any ForecastService
    private let store: any ForecastStore
    private let logger = Logger(subsystem: "com.jurny02.BartoszWeather", category: "Forecast")

    public init(service: any ForecastService, store: any ForecastStore) {
        self.service = service
        self.store = store
    }

    public func forecast(for city: City) async throws -> Forecast {
        let forecast = try await service.forecast(for: city)
        do {
            try await store.save(forecast, for: city)
        } catch {
            logger.error("Could not store the forecast for city \(city.id): \(error, privacy: .public)")
        }
        return forecast
    }

    public func cachedForecast(for city: City) async -> Forecast? {
        do {
            return try await store.forecast(for: city.id)
        } catch {
            logger.error("Could not read the stored forecast for city \(city.id): \(error, privacy: .public)")
            return nil
        }
    }
}
