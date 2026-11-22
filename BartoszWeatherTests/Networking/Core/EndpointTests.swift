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

    nonisolated struct FavoriteEndpoint: Endpoint {
        typealias Response = [String]

        var baseURL = URL(string: "https://example.com")!
        var path = "/v1/favorites"
        var method: HTTPMethod = .post
        var headers: [String: String] = [:]
        var body: HTTPBody?
    }

    nonisolated struct Favorite: Encodable {
        let cityID: Int
    }

    nonisolated struct UnencodableValue: Encodable {
        func encode(to encoder: any Encoder) throws {
            throw EncodingError.invalidValue(self, .init(codingPath: [], debugDescription: "Unencodable"))
        }
    }

    nonisolated struct UnencodableBodyEndpoint: Endpoint {
        typealias Response = [String]

        var baseURL = URL(string: "https://example.com")!
        var path = "/v1/favorites"
        var method: HTTPMethod = .post

        var body: HTTPBody? {
            get throws(APIError) {
                try .json(UnencodableValue())
            }
        }
    }

    @Test func buildsGetRequestForJSON() throws {
        let request = try SearchEndpoint(queryItems: [URLQueryItem(name: "count", value: "10")]).makeRequest()

        #expect(request.url?.absoluteString == "https://geocoding-api.open-meteo.com/v1/search?count=10")
        #expect(request.httpMethod == "GET")
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
        #expect(request.httpBody == nil)
        #expect(request.value(forHTTPHeaderField: "Content-Type") == nil)
    }

    @Test(arguments: [HTTPMethod.post, .put, .patch, .delete, HTTPMethod(rawValue: "PURGE")])
    func usesTheEndpointMethod(method: HTTPMethod) throws {
        let request = try FavoriteEndpoint(method: method).makeRequest()

        #expect(request.httpMethod == method.rawValue)
    }

    @Test func addsEndpointHeadersThatOverrideTheDefaults() throws {
        let request = try FavoriteEndpoint(headers: ["Accept": "application/geo+json", "X-Client": "ios"]).makeRequest()

        #expect(request.value(forHTTPHeaderField: "Accept") == "application/geo+json")
        #expect(request.value(forHTTPHeaderField: "X-Client") == "ios")
    }

    @Test func sendsJSONBodyWithItsContentType() throws {
        let request = try FavoriteEndpoint(body: .json(Favorite(cityID: 3094802))).makeRequest()

        #expect(request.httpBody == Data(#"{"cityID":3094802}"#.utf8))
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    @Test func sendsRawBodyWithItsContentType() throws {
        let body = HTTPBody(data: Data("name=Kraków".utf8), contentType: "application/x-www-form-urlencoded")

        let request = try FavoriteEndpoint(body: body).makeRequest()

        #expect(request.httpBody == Data("name=Kraków".utf8))
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/x-www-form-urlencoded")
    }

    @Test func reportsUnencodableBodyAsInvalidRequest() {
        #expect(throws: APIError.invalidRequest) {
            try UnencodableBodyEndpoint().makeRequest()
        }
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
