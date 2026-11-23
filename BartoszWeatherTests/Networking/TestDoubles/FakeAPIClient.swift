import os
@testable import BartoszWeather

/// An `APIClient` that records the endpoints it is sent and answers each with a canned response or error.
///
/// Honours cancellation like a real client: a cancelled task gets `CancellationError` before the response.
nonisolated final class FakeAPIClient: APIClient {
    typealias Responder = @Sendable (any Endpoint) throws -> any Sendable

    private let respond: Responder
    private let sent = OSAllocatedUnfairLock<[any Endpoint]>(initialState: [])

    init(respond: @escaping Responder) {
        self.respond = respond
    }

    convenience init(response: some Sendable) {
        self.init { _ in response }
    }

    convenience init(error: some Error) {
        self.init { _ in throw error }
    }

    /// The endpoints sent so far, oldest first.
    var sentEndpoints: [any Endpoint] {
        sent.withLock { $0 }
    }

    func send<E: Endpoint>(_ endpoint: E) async throws -> E.Response {
        sent.withLock { $0.append(endpoint) }
        try Task.checkCancellation()
        guard let response = try respond(endpoint) as? E.Response else {
            throw APIError.decoding(description: "FakeAPIClient has no \(E.Response.self) response")
        }
        return response
    }
}
