/// Sends endpoints and returns their decoded responses.
///
/// Implementations throw `APIError` for failures and `CancellationError` when the request is cancelled.
nonisolated public protocol APIClient: Sendable {
    func send<E: Endpoint>(_ endpoint: E) async throws -> E.Response
}
