import Foundation

/// An HTTP request and the type its successful response decodes to.
///
/// Responses are JSON by default; an endpoint that reads another format overrides `acceptsResponse(contentType:)`,
/// `decode(_:)` and the `Accept` header.
///
/// Requests default to GET without a body; endpoints override `method`, `headers` and `body` as needed.
/// Query values are always percent-encoded, so user input can neither add parameters nor change the path.
nonisolated public protocol Endpoint: Sendable {
    /// The type a successful response decodes to.
    associatedtype Response: Decodable & Sendable

    var baseURL: URL { get }
    /// The path appended to `baseURL`. It must start with `/`.
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    var method: HTTPMethod { get }
    /// Extra header fields. They override the defaults, such as `Accept: application/json`.
    var headers: [String: String] { get }
    /// The request body. Any `APIError` thrown here fails the request before it is sent, unchanged.
    var body: HTTPBody? { get throws(APIError) }

    /// Whether a non-empty successful body with this `Content-Type` is meant for `decode`.
    ///
    /// Returning `false` reports the response as `APIError.offline`, because such a body most likely
    /// comes from a captive portal. The default accepts `application/json` and any `+json` media type.
    /// An endpoint that accepts another format should also send it as `Accept` through `headers`.
    func acceptsResponse(contentType: String?) -> Bool

    /// Decodes a successful response whose body is empty or accepted by `acceptsResponse(contentType:)`.
    ///
    /// The default returns `EmptyResponse` without reading the body and decodes any other type as JSON.
    /// A thrown `CancellationError` reaches the caller unchanged; any other error becomes `APIError.decoding`.
    func decode(_ data: Data) throws -> Response
    /// Reads the server's explanation from the body of a failed response, for logs only.
    func errorReason(from data: Data) -> String?
}

nonisolated extension Endpoint {
    public var queryItems: [URLQueryItem] { [] }
    public var method: HTTPMethod { .get }
    public var headers: [String: String] { [:] }
    public var body: HTTPBody? { nil }

    public func decode(_ data: Data) throws -> Response {
        if let empty = EmptyResponse() as? Response {
            return empty
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }

    public func errorReason(from data: Data) -> String? {
        nil
    }

    public func acceptsResponse(contentType: String?) -> Bool {
        guard let contentType else {
            return false
        }
        let mediaType = contentType
            .prefix { $0 != ";" }
            .trimmingCharacters(in: .whitespaces)
            .lowercased()
        return mediaType == "application/json" || mediaType.hasSuffix("+json")
    }

    /// Builds the `URLRequest`.
    ///
    /// Throws `APIError.invalidRequest` when `path` does not start with `/` or the URL cannot be built,
    /// and rethrows any error from `body`.
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
