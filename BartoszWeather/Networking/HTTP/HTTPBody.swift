import Foundation

/// The payload of a request together with the media type sent as its `Content-Type`.
nonisolated public struct HTTPBody: Equatable, Sendable {
    public let data: Data
    public let contentType: String

    public init(data: Data, contentType: String) {
        self.data = data
        self.contentType = contentType
    }

    /// Encodes `value` as JSON. An encoding failure is reported as `APIError.invalidRequest`.
    public static func json(_ value: some Encodable, encoder: JSONEncoder = JSONEncoder()) throws(APIError) -> HTTPBody {
        do {
            return HTTPBody(data: try encoder.encode(value), contentType: "application/json")
        } catch {
            throw .invalidRequest
        }
    }
}
