import os
@testable import BartoszWeather

/// A `ForecastRepository` whose loads behave like `FakeForecastService`: canned results in order, optionally held
/// until released, honouring cancellation. Its stored forecast is a fixed stub, and every lookup of it is recorded.
nonisolated final class FakeForecastRepository: ForecastRepository {
    private let service: FakeForecastService
    private let cached: Forecast?
    private let cacheLookups = OSAllocatedUnfairLock<[City]>(initialState: [])

    /// - Precondition: `results` is not empty.
    init(
        results: [Result<Forecast, APIError>],
        cached: Forecast? = nil,
        holdsResponses: Bool = false,
        checksCancellation: Bool = true
    ) {
        service = FakeForecastService(
            results: results, holdsResponses: holdsResponses, checksCancellation: checksCancellation
        )
        self.cached = cached
    }

    convenience init(forecast: Forecast, holdsResponses: Bool = false) {
        self.init(results: [.success(forecast)], holdsResponses: holdsResponses)
    }

    convenience init(
        error: APIError, cached: Forecast? = nil, holdsResponses: Bool = false, checksCancellation: Bool = true
    ) {
        self.init(
            results: [.failure(error)], cached: cached,
            holdsResponses: holdsResponses, checksCancellation: checksCancellation
        )
    }

    /// The cities loaded so far, oldest first.
    var requestedCities: [City] {
        service.requestedCities
    }

    /// The cities whose stored forecast was looked up so far, oldest first.
    var cachedForecastRequests: [City] {
        cacheLookups.withLock { $0 }
    }

    /// Waits until the next load starts and returns its city.
    func nextRequest() async -> City? {
        await service.nextRequest()
    }

    /// Lets the oldest held load that is still waiting answer.
    func releaseResponse() {
        service.releaseResponse()
    }

    /// Lets the newest held load that is still waiting answer.
    func releaseNewestResponse() {
        service.releaseNewestResponse()
    }

    func forecast(for city: City) async throws -> Forecast {
        try await service.forecast(for: city)
    }

    func cachedForecast(for city: City) async -> Forecast? {
        cacheLookups.withLock { $0.append(city) }
        return cached
    }
}
