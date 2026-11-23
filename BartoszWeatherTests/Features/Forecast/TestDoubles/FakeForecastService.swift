import os
@testable import BartoszWeather

/// A `ForecastService` that answers with canned results in order, repeating the last one, and records every city.
///
/// With `holdsResponses`, each answer waits for `releaseResponse()`, so a test can act while a load is in flight;
/// cancelling a held load ends the holding, also for the fake's later loads.
/// Cancellation is honoured like a real service: a cancelled load throws `CancellationError`.
/// Without `checksCancellation`, it answers anyway, like a request that failed or finished just as it was cancelled.
nonisolated final class FakeForecastService: ForecastService {
    private let results: OSAllocatedUnfairLock<[Result<Forecast, APIError>]>
    private let holdsResponses: Bool
    private let checksCancellation: Bool
    private let requests = AsyncStream<City>.makeStream()
    private let releases = AsyncStream<Void>.makeStream()
    private let recorded = OSAllocatedUnfairLock<[City]>(initialState: [])

    /// - Precondition: `results` is not empty.
    init(results: [Result<Forecast, APIError>], holdsResponses: Bool = false, checksCancellation: Bool = true) {
        precondition(!results.isEmpty, "FakeForecastService needs at least one result")
        self.results = OSAllocatedUnfairLock(initialState: results)
        self.holdsResponses = holdsResponses
        self.checksCancellation = checksCancellation
    }

    convenience init(forecast: Forecast, holdsResponses: Bool = false) {
        self.init(results: [.success(forecast)], holdsResponses: holdsResponses)
    }

    convenience init(error: APIError, holdsResponses: Bool = false, checksCancellation: Bool = true) {
        self.init(results: [.failure(error)], holdsResponses: holdsResponses, checksCancellation: checksCancellation)
    }

    /// The cities loaded so far, oldest first.
    var requestedCities: [City] {
        recorded.withLock { $0 }
    }

    /// Waits until the next load starts and returns its city.
    func nextRequest() async -> City? {
        var iterator = requests.stream.makeAsyncIterator()
        return await iterator.next()
    }

    /// Lets one held load answer.
    func releaseResponse() {
        releases.continuation.yield()
    }

    func forecast(for city: City) async throws -> Forecast {
        recorded.withLock { $0.append(city) }
        requests.continuation.yield(city)
        if holdsResponses {
            var iterator = releases.stream.makeAsyncIterator()
            _ = await iterator.next()
        }
        if checksCancellation {
            try Task.checkCancellation()
        }
        let result = results.withLock { results in
            results.count > 1 ? results.removeFirst() : results[0]
        }
        return try result.get()
    }
}
