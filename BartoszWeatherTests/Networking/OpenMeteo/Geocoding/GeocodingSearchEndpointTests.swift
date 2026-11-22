import Foundation
import Testing
@testable import BartoszWeather

/// Tests the request and the response decoding of the Open-Meteo city search.
struct GeocodingSearchEndpointTests {
    @Test func buildsSearchRequest() throws {
        let request = try GeocodingSearchEndpoint(name: "Kraków", language: "pl").makeRequest()
        let components = try #require(request.url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) })

        #expect(request.httpMethod == "GET")
        #expect(components.scheme == "https")
        #expect(components.host == "geocoding-api.open-meteo.com")
        #expect(components.path == "/v1/search")
        #expect(components.queryItems == [
            URLQueryItem(name: "name", value: "Kraków"),
            URLQueryItem(name: "count", value: "10"),
            URLQueryItem(name: "language", value: "pl"),
            URLQueryItem(name: "format", value: "json"),
        ])
    }

    @Test func sendsTheRequestedResultCount() throws {
        let request = try GeocodingSearchEndpoint(name: "Hel", count: 3, language: "en").makeRequest()

        #expect(request.url?.query()?.contains("count=3") == true)
    }

    @Test(arguments: [
        ("Bielsko-Biała", "name=Bielsko-Bia%C5%82a"),
        ("Nowy Sącz", "name=Nowy%20S%C4%85cz"),
        ("Paris, France", "name=Paris,%20France"),
        ("Kraków&count=500", "name=Krak%C3%B3w%26count%3D500"),
    ])
    func percentEncodesTheName(name: String, encoded: String) throws {
        let request = try GeocodingSearchEndpoint(name: name, language: "pl").makeRequest()

        #expect(request.url?.absoluteString.contains(encoded) == true)
    }

    @Test func decodesFoundPlaces() throws {
        let response = try GeocodingSearchEndpoint(name: "Kraków", language: "pl").decode(Data(Self.krakowJSON.utf8))
        let places = try #require(response.results)

        #expect(places == [
            GeocodingPlaceDTO(
                id: 3_094_802, name: "Kraków", latitude: 50.06143, longitude: 19.93658,
                country: "Polska", admin1: "Województwo małopolskie", admin2: "Kraków", timezone: "Europe/Warsaw"
            ),
            GeocodingPlaceDTO(
                id: 5_258_888, name: "Krakow", latitude: 44.76166, longitude: -88.25149,
                country: "Stany Zjednoczone", admin1: "Wisconsin", admin2: "Hrabstwo Oconto", timezone: "America/Chicago"
            ),
        ])
    }

    @Test func decodesPlacesWithoutCountryOrRegion() throws {
        let response = try GeocodingSearchEndpoint(name: "McMurdo", language: "en").decode(Data(Self.mcMurdoJSON.utf8))

        #expect(response.results == [
            GeocodingPlaceDTO(
                id: 13_664_897, name: "McMurdo Station", latitude: -77.84114, longitude: 166.75272,
                country: nil, admin1: nil, admin2: nil, timezone: "Antarctica/McMurdo"
            ),
        ])
    }

    @Test func decodesMissingResultsAsNoResults() throws {
        let response = try GeocodingSearchEndpoint(name: "Xqzzqx", language: "en")
            .decode(Data(#"{"generationtime_ms":0.05888939}"#.utf8))

        #expect(response.results == nil)
    }

    private static let krakowJSON = #"""
    {"results":[{"id":3094802,"name":"Kraków","latitude":50.06143,"longitude":19.93658,"elevation":219.0,"feature_code":"PPLA","country_code":"PL","admin1_id":858786,"admin2_id":6690154,"admin3_id":7531791,"timezone":"Europe/Warsaw","population":816614,"country_id":798544,"country":"Polska","admin1":"Województwo małopolskie","admin2":"Kraków","admin3":"Kraków"},{"id":5258888,"name":"Krakow","latitude":44.76166,"longitude":-88.25149,"elevation":237.0,"feature_code":"PPL","country_code":"US","admin1_id":5279468,"admin2_id":5265518,"admin3_id":5248361,"timezone":"America/Chicago","population":354,"postcodes":["54137"],"country_id":6252001,"country":"Stany Zjednoczone","admin1":"Wisconsin","admin2":"Hrabstwo Oconto","admin3":"Town of Chase"}],"generationtime_ms":0.21779537}
    """#

    private static let mcMurdoJSON = #"""
    {"results":[{"id":13664897,"name":"McMurdo Station","latitude":-77.84114,"longitude":166.75272,"elevation":10.0,"feature_code":"PPL","country_code":"AQ","timezone":"Antarctica/McMurdo","population":153}],"generationtime_ms":0.11706352}
    """#
}
