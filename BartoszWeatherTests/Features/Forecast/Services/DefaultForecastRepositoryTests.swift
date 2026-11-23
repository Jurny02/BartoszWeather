import Testing
@testable import BartoszWeather

/// Tests that loaded forecasts are stored and that store failures never fail a load.
struct DefaultForecastRepositoryTests {
    @Test func savesAndReturnsALoadedForecast() async throws {
        let service = FakeForecastService(forecast: .krakowDay)
        let store = FakeForecastStore()
        let repository = DefaultForecastRepository(service: service, store: store)

        let forecast = try await repository.forecast(for: .krakow)

        #expect(forecast == .krakowDay)
        #expect(service.requestedCities == [.krakow])
        #expect(store.savedForecasts == [SavedForecast(forecast: .krakowDay, city: .krakow)])
    }

    @Test func returnsTheForecastWhenSavingFails() async throws {
        let store = FakeForecastStore(failsSaves: true)
        let repository = DefaultForecastRepository(service: FakeForecastService(forecast: .krakowDay), store: store)

        let forecast = try await repository.forecast(for: .krakow)

        #expect(forecast == .krakowDay)
        #expect(store.savedForecasts == [SavedForecast(forecast: .krakowDay, city: .krakow)])
    }

    @Test func rethrowsAFailedLoadWithoutSaving() async {
        let store = FakeForecastStore()
        let repository = DefaultForecastRepository(service: FakeForecastService(error: .offline), store: store)

        await #expect(throws: APIError.offline) {
            try await repository.forecast(for: .krakow)
        }
        #expect(store.savedForecasts.isEmpty)
    }

    @Test func rethrowsCancellationWithoutSaving() async {
        let store = FakeForecastStore()
        let repository = DefaultForecastRepository(service: FakeForecastService(forecast: .krakowDay), store: store)

        let load = Task { try await repository.forecast(for: .krakow) }
        load.cancel()

        await #expect(throws: CancellationError.self) {
            try await load.value
        }
        #expect(store.savedForecasts.isEmpty)
    }

    @Test func returnsTheStoredForecast() async {
        let store = FakeForecastStore(stored: [City.krakow.id: .krakowDay])
        let repository = DefaultForecastRepository(service: FakeForecastService(error: .offline), store: store)

        #expect(await repository.cachedForecast(for: .krakow) == .krakowDay)
        #expect(await repository.cachedForecast(for: .hel) == nil)
    }

    @Test func returnsNoStoredForecastWhenReadingFails() async {
        let store = FakeForecastStore(stored: [City.krakow.id: .krakowDay], failsReads: true)
        let repository = DefaultForecastRepository(service: FakeForecastService(error: .offline), store: store)

        #expect(await repository.cachedForecast(for: .krakow) == nil)
    }
}
