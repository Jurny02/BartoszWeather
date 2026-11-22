import Foundation
import Testing
@testable import BartoszWeather

struct URLSessionAPIClientTests {
    nonisolated struct Payload: Decodable, Equatable, Sendable {
        let value: String
    }

    nonisolated struct PayloadEndpoint: Endpoint {
        typealias Response = Payload

        let baseURL: URL
        let path = "/payload"

        func errorReason(from data: Data) -> String? {
            String(decoding: data, as: UTF8.self)
        }
    }

    nonisolated struct PlainEndpoint: Endpoint {
        typealias Response = Payload

        let baseURL: URL
        let path = "/payload"
    }

    private let client: URLSessionAPIClient = {
        let configuration = URLSessionConfiguration.api
        configuration.protocolClasses = [StubURLProtocol.self]
        return URLSessionAPIClient(configuration: configuration)
    }()

    @Test func decodesSuccessfulJSONResponse() async throws {
        let baseURL = StubURLProtocol.register(status: 200, body: #"{"value":"Kraków"}"#)

        let payload = try await client.send(PayloadEndpoint(baseURL: baseURL))

        #expect(payload == Payload(value: "Kraków"))
    }

    @Test func acceptsJSONContentTypeWithCharset() async throws {
        let baseURL = StubURLProtocol.register(
            status: 200,
            contentType: "application/json; charset=utf-8",
            body: #"{"value":"Gdańsk"}"#
        )

        let payload = try await client.send(PayloadEndpoint(baseURL: baseURL))

        #expect(payload == Payload(value: "Gdańsk"))
    }

    @Test(arguments: [400, 404, 429, 500, 503])
    func reportsServerErrorWithReason(status: Int) async {
        let baseURL = StubURLProtocol.register(status: status, body: "The service is overloaded")

        await #expect(throws: APIError.server(status: status, reason: "The service is overloaded")) {
            try await client.send(PayloadEndpoint(baseURL: baseURL))
        }
    }

    @Test func reportsServerErrorWithoutReasonByDefault() async {
        let baseURL = StubURLProtocol.register(status: 500, body: "Internal Server Error")

        await #expect(throws: APIError.server(status: 500, reason: nil)) {
            try await client.send(PlainEndpoint(baseURL: baseURL))
        }
    }

    @Test func reportsInvalidJSONAsDecodingError() async {
        let baseURL = StubURLProtocol.register(status: 200, body: #"{"value":"#)

        await #expect {
            try await client.send(PayloadEndpoint(baseURL: baseURL))
        } throws: { error in
            guard case APIError.decoding = error else { return false }
            return true
        }
    }

    @Test(arguments: ["text/html", nil])
    func reportsNonJSONPageAsOfflineBecauseItComesFromACaptivePortal(contentType: String?) async {
        let baseURL = StubURLProtocol.register(
            status: 200,
            contentType: contentType,
            body: "<html><body>Log in to the hotel Wi-Fi</body></html>"
        )

        await #expect(throws: APIError.offline) {
            try await client.send(PayloadEndpoint(baseURL: baseURL))
        }
    }

    @Test func rejectsResponseLargerThanTheSizeCap() async {
        let body = #"{"value":""# + String(repeating: "a", count: URLSessionAPIClient.maxResponseSize) + #""}"#
        let baseURL = StubURLProtocol.register(status: 200, body: body)

        await #expect(throws: APIError.transport) {
            try await client.send(PayloadEndpoint(baseURL: baseURL))
        }
    }

    @Test(arguments: [
        (URLError.Code.notConnectedToInternet, APIError.offline),
        (.networkConnectionLost, .offline),
        (.dataNotAllowed, .offline),
        (.internationalRoamingOff, .offline),
        (.cannotConnectToHost, .offline),
        (.timedOut, .timeout),
        (.cannotFindHost, .transport),
        (.secureConnectionFailed, .transport),
        (.badServerResponse, .transport),
    ])
    func mapsURLErrors(code: URLError.Code, expected: APIError) async {
        let baseURL = StubURLProtocol.register(failingWith: code)

        await #expect(throws: expected) {
            try await client.send(PayloadEndpoint(baseURL: baseURL))
        }
    }

    @Test func reportsCancelledURLRequestAsCancellation() async {
        let baseURL = StubURLProtocol.register(failingWith: .cancelled)

        await #expect(throws: CancellationError.self) {
            try await client.send(PayloadEndpoint(baseURL: baseURL))
        }
    }

    @Test func reportsCancelledTaskAsCancellation() async {
        let baseURL = StubURLProtocol.register(status: 200, body: #"{"value":"Kraków"}"#)
        let client = client
        let task = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            return try await client.send(PayloadEndpoint(baseURL: baseURL))
        }

        await #expect(throws: CancellationError.self) {
            try await task.value
        }
    }
}
