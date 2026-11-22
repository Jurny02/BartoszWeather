nonisolated public enum APIError: Error, Equatable, Sendable {
    case offline
    case timeout
    case server(status: Int, reason: String?)
    case decoding(description: String)
    case invalidRequest
    case transport
}
