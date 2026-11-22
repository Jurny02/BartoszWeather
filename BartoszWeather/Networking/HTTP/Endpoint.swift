import Foundation

/// An HTTP request to a JSON API and the type its successful response decodes to.
///
/// Requests default to GET without a body; endpoints override `method`, `headers` and `body` as needed.
///
/// `path` must start with `/`. Query values are always percent-encoded, so user input
/// can neither add parameters nor change the path.
nonisolated public protocol Endpoint: Sendable {
    associatedtype Response: Decodable & Sendable

    var baseURL: URL { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var body: HTTPBody? { get throws(APIError) }

    func decode(_ data: Data) throws -> Response
    func errorReason(from data: Data) -> String?
}

nonisolated extension Endpoint {
    public var queryItems: [URLQueryItem] { [] }
    public var method: HTTPMethod { .get }
    public var headers: [String: String] { [:] }
    public var body: HTTPBody? { nil }

    public func decode(_ data: Data) throws -> Response {
        try JSONDecoder().decode(Response.self, from: data)
    }

    public func errorReason(from data: Data) -> String? {
        nil
    }

    public func makeRequest() throws(APIError) -> URLRequest {
        guard path.hasPrefix("/"),
              var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw .invalidRequest
        }
        if components.path.hasSuffix("/") {
            components.path.removeLast()
        }
        components.path += path
        if !queryItems.isEmpty {
            components.queryItems = queryItems
            components.percentEncodedQuery = components.percentEncodedQuery?
                .replacingOccurrences(of: "+", with: "%2B")
        }
        guard let url = components.url else {
            throw .invalidRequest
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body = try body {
            request.httpBody = body.data
            request.setValue(body.contentType, forHTTPHeaderField: "Content-Type")
        }
        for (field, value) in headers {
            request.setValue(value, forHTTPHeaderField: field)
        }
        return request
    }
}
