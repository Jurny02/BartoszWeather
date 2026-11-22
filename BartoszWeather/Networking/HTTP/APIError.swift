/// A failed API request, in terms the feature layer can turn into a screen state.
///
/// Cancellation is never an `APIError`: clients rethrow it as `CancellationError`.
nonisolated public enum APIError: Error, Equatable, Sendable {
    /// The device has no usable connection, or a captive portal answered instead of the API.
    case offline
    /// The server did not answer within the request timeout.
    case timeout
    /// The server answered with a non-2xx status. `reason` is for logs only, never for the UI.
    case server(status: Int, reason: String?)
    /// The response body did not match the expected type.
    case decoding(description: String)
    /// The request could not be built, for example an invalid URL or a body that fails to encode.
    case invalidRequest
    /// Any other transport failure, such as a TLS error or an oversized response.
    case transport
}
