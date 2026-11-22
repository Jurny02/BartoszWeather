import Foundation

nonisolated public struct HTTPBody: Equatable, Sendable {
    public let data: Data
    public let contentType: String

    public init(data: Data, contentType: String) {
        self.data = data
        self.contentType = contentType
    }

    public static func json(_ value: some Encodable, encoder: JSONEncoder = JSONEncoder()) throws(APIError) -> HTTPBody {
        do {
            return HTTPBody(data: try encoder.encode(value), contentType: "application/json")
        } catch {
            throw .invalidRequest
        }
    }
}
