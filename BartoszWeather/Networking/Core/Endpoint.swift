import Foundation

/// A GET request to a JSON API and the type its successful response decodes to.
///
/// `path` must start with `/`. Query values are always percent-encoded, so user input
/// can neither add parameters nor change the path.
nonisolated public protocol Endpoint: Sendable {
    associatedtype Response: Decodable & Sendable

    var baseURL: URL { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }

    func decode(_ data: Data) throws -> Response
    func errorReason(from data: Data) -> String?
}

nonisolated extension Endpoint {
    public var queryItems: [URLQueryItem] { [] }

    public func decode(_ data: Data) throws -> Response {
        try JSONDecoder().decode(Response.self, from: data)
    }

    public func errorReason(from data: Data) -> String? {
        nil
    }

    public func makeRequest() throws(APIError) -> URLRequest {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
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
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}
