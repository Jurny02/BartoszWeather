import Foundation
import Testing
@testable import BartoszWeather

struct OpenMeteoEndpointTests {
    nonisolated struct ForecastStub: OpenMeteoEndpoint {
        typealias Response = [String: Double]

        var baseURL = URL(string: "https://api.open-meteo.com")!
        let path = "/v1/forecast"
    }

    @Test(arguments: [
        #"{"error":true,"reason":"Latitude must be in range of -90 to 90°. Given: 150.0."}"#,
        #"{"reason":"Latitude must be in range of -90 to 90°. Given: 150.0.","error":true}"#,
    ])
    func readsReasonFromErrorBodyInAnyKeyOrder(body: String) {
        #expect(ForecastStub().errorReason(from: Data(body.utf8)) == "Latitude must be in range of -90 to 90°. Given: 150.0.")
    }

    @Test(arguments: [
        #"{"error":true}"#,
        "<html>Bad gateway</html>",
        "",
    ])
    func hasNoReasonWhenBodyDoesNotCarryOne(body: String) {
        #expect(ForecastStub().errorReason(from: Data(body.utf8)) == nil)
    }

    @Test func clientReportsReasonOfFailedRequest() async {
        let configuration = URLSessionConfiguration.api
        configuration.protocolClasses = [StubURLProtocol.self]
        let client = URLSessionAPIClient(configuration: configuration)
        let baseURL = StubURLProtocol.register(
            status: 400,
            body: #"{"error":true,"reason":"Forecast days is invalid. Allowed range 0 to 16. Given 17."}"#
        )

        await #expect(throws: APIError.server(status: 400, reason: "Forecast days is invalid. Allowed range 0 to 16. Given 17.")) {
            try await client.send(ForecastStub(baseURL: baseURL))
        }
    }
}
