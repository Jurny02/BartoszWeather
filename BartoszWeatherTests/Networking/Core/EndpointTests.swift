import Foundation
import Testing
@testable import BartoszWeather

struct EndpointTests {
    nonisolated struct SearchEndpoint: Endpoint {
        typealias Response = [String]

        var baseURL = URL(string: "https://geocoding-api.open-meteo.com")!
        var path = "/v1/search"
        var queryItems: [URLQueryItem] = []
    }

    @Test func buildsGetRequestForJSON() throws {
        let request = try SearchEndpoint(queryItems: [URLQueryItem(name: "count", value: "10")]).makeRequest()

        #expect(request.url?.absoluteString == "https://geocoding-api.open-meteo.com/v1/search?count=10")
        #expect(request.httpMethod == "GET")
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    @Test func omitsQuestionMarkWithoutQueryItems() throws {
        let request = try SearchEndpoint().makeRequest()

        #expect(request.url?.absoluteString == "https://geocoding-api.open-meteo.com/v1/search")
    }

    @Test(arguments: [
        ("Bielsko-Biała", "name=Bielsko-Bia%C5%82a"),
        ("Nowy Sącz", "name=Nowy%20S%C4%85cz"),
        ("Paris, France", "name=Paris,%20France"),
        ("Kraków&count=500", "name=Krak%C3%B3w%26count%3D500"),
        ("C++", "name=C%2B%2B"),
    ])
    func percentEncodesUserInput(name: String, expectedQuery: String) throws {
        let request = try SearchEndpoint(queryItems: [URLQueryItem(name: "name", value: name)]).makeRequest()

        #expect(request.url?.query(percentEncoded: true) == expectedQuery)
    }

    @Test func joinsBaseURLWithTrailingSlashAndPathWithoutDoubleSlash() throws {
        let request = try SearchEndpoint(baseURL: URL(string: "https://geocoding-api.open-meteo.com/")!).makeRequest()

        #expect(request.url?.absoluteString == "https://geocoding-api.open-meteo.com/v1/search")
    }

    @Test(arguments: [
        "https://geocoding-api.open-meteo.com",
        "https://geocoding-api.open-meteo.com/api",
        "https://geocoding-api.open-meteo.com/api/",
    ])
    func rejectsPathWithoutLeadingSlash(baseURL: String) {
        #expect(throws: APIError.invalidRequest) {
            try SearchEndpoint(baseURL: URL(string: baseURL)!, path: "v1/search").makeRequest()
        }
    }

    @Test func appendsPathToBaseURLWithPath() throws {
        let request = try SearchEndpoint(baseURL: URL(string: "https://geocoding-api.open-meteo.com/api")!).makeRequest()

        #expect(request.url?.absoluteString == "https://geocoding-api.open-meteo.com/api/v1/search")
    }
}
