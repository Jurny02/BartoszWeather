import os
@testable import BartoszWeather

/// A `CitySearchService` that answers with canned cities or an error and records every query.
///
/// With `holdsResponses`, each answer waits for `releaseResponse()`, so a test can act while a search is in flight.
/// Cancelling a held search ends the holding, also for the fake's later searches.
/// Cancellation is honoured like a real service: a cancelled search throws `CancellationError`.
/// Without `checksCancellation`, it answers anyway, like a request that failed or finished just as it was cancelled.
nonisolated final class FakeCitySearchService: CitySearchService {
    private let respond: @Sendable (String) throws -> [City]
    private let holdsResponses: Bool
    private let checksCancellation: Bool
    private let requests = AsyncStream<String>.makeStream()
    private let releases = AsyncStream<Void>.makeStream()
    private let recorded = OSAllocatedUnfairLock<[String]>(initialState: [])

    init(
        holdsResponses: Bool = false,
        checksCancellation: Bool = true,
        respond: @escaping @Sendable (String) throws -> [City]
    ) {
        self.holdsResponses = holdsResponses
        self.checksCancellation = checksCancellation
        self.respond = respond
    }

    convenience init(cities: [City], holdsResponses: Bool = false) {
        self.init(holdsResponses: holdsResponses) { _ in cities }
    }

    convenience init(error: some Error) {
        self.init { _ in throw error }
    }

    /// The queries searched so far, oldest first.
    var queries: [String] {
        recorded.withLock { $0 }
    }

    /// Waits until the next search starts and returns its query.
    func nextRequest() async -> String? {
        var iterator = requests.stream.makeAsyncIterator()
        return await iterator.next()
    }

    /// Lets one held search answer.
    func releaseResponse() {
        releases.continuation.yield()
    }

    func cities(matching query: String) async throws -> [City] {
        recorded.withLock { $0.append(query) }
        requests.continuation.yield(query)
        if holdsResponses {
            var iterator = releases.stream.makeAsyncIterator()
            _ = await iterator.next()
        }
        if checksCancellation {
            try Task.checkCancellation()
        }
        return try respond(query)
    }
}
