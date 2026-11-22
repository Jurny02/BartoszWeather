import Foundation

/// The response of an endpoint whose body carries nothing the app needs, such as a `204 No Content`.
///
/// The body is not decoded, but a non-empty body in a successful response still goes through
/// `acceptsResponse(contentType:)`, so by default a non-JSON body is reported as `APIError.offline`.
nonisolated public struct EmptyResponse: Decodable, Equatable, Sendable {
    public init() {}
}

nonisolated extension Endpoint where Response == EmptyResponse {
    public func decode(_ data: Data) throws -> EmptyResponse {
        EmptyResponse()
    }
}
