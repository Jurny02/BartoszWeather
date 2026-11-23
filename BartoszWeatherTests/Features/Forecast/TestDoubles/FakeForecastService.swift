import os
@testable import BartoszWeather

/// A `ForecastService` that answers with canned results in order, repeating the last one, and records every city.
/// Each load takes its result when it starts.
///
/// With `holdsResponses`, each load waits until `releaseResponse()` (oldest first) or `releaseNewestResponse()`
/// lets it answer, so a test can act while loads are in flight; a cancelled load stops waiting.
/// Cancellation is honoured like a real service: a cancelled load throws `CancellationError`.
/// Without `checksCancellation`, it answers anyway, like a request that failed or finished just as it was cancelled.
nonisolated final class FakeForecastService: ForecastService {
    private let results: OSAllocatedUnfairLock<[Result<Forecast, APIError>]>
    private let holdsResponses: Bool
    private let checksCancellation: Bool
    private let requests = AsyncStream<City>.makeStream()
    private let heldResponses = OSAllocatedUnfairLock<[AsyncStream<Void>.Continuation]>(initialState: [])
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

    /// Lets the oldest held load that is still waiting answer.
    func releaseResponse() {
        release { $0.isEmpty ? nil : $0.removeFirst() }
    }

    /// Lets the newest held load that is still waiting answer.
    func releaseNewestResponse() {
        release { $0.popLast() }
    }

    private func release(next: @Sendable (inout [AsyncStream<Void>.Continuation]) -> AsyncStream<Void>.Continuation?) {
        while let release = heldResponses.withLock(next) {
            if case .enqueued = release.yield() {
                return
            }
        }
    }

    func forecast(for city: City) async throws -> Forecast {
        recorded.withLock { $0.append(city) }
        let result = results.withLock { results in
            results.count > 1 ? results.removeFirst() : results[0]
        }
        if holdsResponses {
            let gate = AsyncStream<Void>.makeStream()
            heldResponses.withLock { $0.append(gate.continuation) }
            requests.continuation.yield(city)
            var iterator = gate.stream.makeAsyncIterator()
            _ = await iterator.next()
        } else {
            requests.continuation.yield(city)
        }
        if checksCancellation {
            try Task.checkCancellation()
        }
        return try result.get()
    }
}
