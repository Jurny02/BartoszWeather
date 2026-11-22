import Foundation
import os

/// Sends endpoints over `URLSession` and reports every failure as `APIError`,
/// except cancellation, which is rethrown as `CancellationError`.
nonisolated public final class URLSessionAPIClient: APIClient {
    static let maxResponseSize = 1_048_576

    private let session: URLSession
    private let logger = Logger(subsystem: "com.jurny02.BartoszWeather", category: "Networking")

    public init(configuration: URLSessionConfiguration = .api) {
        session = URLSession(configuration: configuration)
    }

    deinit {
        session.finishTasksAndInvalidate()
    }

    @concurrent
    public func send<E: Endpoint>(_ endpoint: E) async throws -> E.Response {
        let request = try endpoint.makeRequest()
        let start = ContinuousClock.now
        let (data, response) = try await data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw APIError.transport
        }
        logger.debug("\(endpoint.method.rawValue, privacy: .public) \(endpoint.path, privacy: .public) \(response.statusCode) in \(start.duration(to: .now), privacy: .public)")

        guard data.count <= Self.maxResponseSize else {
            logger.error("\(endpoint.method.rawValue, privacy: .public) \(endpoint.path, privacy: .public) returned \(data.count) bytes")
            throw APIError.transport
        }
        guard (200..<300).contains(response.statusCode) else {
            let reason = endpoint.errorReason(from: data)
            logger.error("\(endpoint.method.rawValue, privacy: .public) \(endpoint.path, privacy: .public) failed: \(reason ?? "no reason", privacy: .private)")
            throw APIError.server(status: response.statusCode, reason: reason)
        }
        guard data.isEmpty || Self.isJSON(response) else {
            throw APIError.offline
        }
        do {
            return try endpoint.decode(data)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            logger.error("\(endpoint.method.rawValue, privacy: .public) \(endpoint.path, privacy: .public) decoding failed: \(error, privacy: .private)")
            throw APIError.decoding(description: String(describing: error))
        }
    }

    private func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch let error as URLError {
            throw Self.mapped(error)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw APIError.transport
        }
    }

    private static func mapped(_ error: URLError) -> any Error {
        switch error.code {
        case .cancelled:
            CancellationError()
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed,
             .internationalRoamingOff, .cannotConnectToHost:
            APIError.offline
        case .timedOut:
            APIError.timeout
        default:
            APIError.transport
        }
    }

    private static func isJSON(_ response: HTTPURLResponse) -> Bool {
        guard let contentType = response.value(forHTTPHeaderField: "Content-Type") else {
            return false
        }
        let mediaType = contentType
            .prefix { $0 != ";" }
            .trimmingCharacters(in: .whitespaces)
            .lowercased()
        return mediaType == "application/json" || mediaType.hasSuffix("+json")
    }
}
