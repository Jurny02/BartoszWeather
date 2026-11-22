import Foundation

/// The response of an endpoint whose body carries nothing the app needs, such as a `204 No Content`.
///
/// The body is not decoded, but a non-empty, non-JSON body in a successful response is still reported as `APIError.offline`,
/// because it most likely comes from a captive portal.
nonisolated public struct EmptyResponse: Decodable, Equatable, Sendable {
    public init() {}
}

nonisolated extension Endpoint where Response == EmptyResponse {
    public func decode(_ data: Data) throws -> EmptyResponse {
        EmptyResponse()
    }
}
