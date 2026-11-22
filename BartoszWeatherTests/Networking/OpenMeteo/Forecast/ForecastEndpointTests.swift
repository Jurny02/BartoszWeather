import Foundation
import Testing
@testable import BartoszWeather

/// Tests the request and the response decoding of the Open-Meteo forecast.
struct ForecastEndpointTests {
    private let krakow = Coordinate(latitude: 50.06143, longitude: 19.93658)

    @Test func buildsRequestWithFixedFormatAndUnits() throws {
        let endpoint = ForecastEndpoint(
            coordinate: krakow, current: [.temperature, .weatherCode], hourly: [], daily: [],
            forecastHours: nil, forecastDays: nil
        )
        let request = try endpoint.makeRequest()
        let components = try #require(request.url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) })

        #expect(request.httpMethod == "GET")
        #expect(components.host == "api.open-meteo.com")
        #expect(components.path == "/v1/forecast")
        #expect(components.queryItems == [
            URLQueryItem(name: "latitude", value: "50.06143"),
            URLQueryItem(name: "longitude", value: "19.93658"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "timeformat", value: "unixtime"),
            URLQueryItem(name: "temperature_unit", value: "celsius"),
            URLQueryItem(name: "wind_speed_unit", value: "kmh"),
            URLQueryItem(name: "current", value: "temperature_2m,weather_code"),
        ])
    }

    @Test func detailPresetRequestsEverythingTheForecastScreenShows() throws {
        let items = ForecastEndpoint.detail(for: krakow).queryItems
        let values = Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value) })

        #expect(values["current"] == """
        temperature_2m,apparent_temperature,relative_humidity_2m,is_day,weather_code,\
        cloud_cover,precipitation_probability,wind_speed_10m,wind_gusts_10m,wind_direction_10m
        """)
        #expect(values["hourly"] == "temperature_2m,precipitation_probability,weather_code,is_day")
        #expect(values["forecast_hours"] == "24")
        #expect(values["daily"] == "weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max")
        #expect(values["forecast_days"] == "7")
    }

    @Test func decodesDetailForecast() throws {
        let response = try ForecastEndpoint.detail(for: krakow).decode(Data(Self.detailJSON.utf8))

        #expect(response == ForecastResponseDTO(
            utcOffsetSeconds: 3600,
            timezone: "Europe/Warsaw",
            current: ForecastCurrentDTO(
                time: 1_795_388_400, temperature2m: 1.0, apparentTemperature: -2.2, relativeHumidity2m: 89,
                isDay: 0, weatherCode: 3, cloudCover: 100, precipitationProbability: 0,
                windSpeed10m: 6.5, windGusts10m: 10.1, windDirection10m: 247
            ),
            hourly: ForecastHourlyDTO(
                time: [1_795_388_400, 1_795_392_000, 1_795_395_600],
                temperature2m: [1.0, 0.6, 0.9], precipitationProbability: [0, 0, 0],
                weatherCode: [3, 3, 3], isDay: [0, 0, 0]
            ),
            daily: ForecastDailyDTO(
                time: [1_795_388_400, 1_795_474_800],
                weatherCode: [71, 71], temperature2mMax: [2.5, 1.8], temperature2mMin: [0.3, 0.0],
                precipitationProbabilityMax: [57, 65]
            )
        ))
    }

    @Test func decodesNullValuesAndMissingVariables() throws {
        let response = try ForecastEndpoint.detail(for: krakow).decode(Data(Self.nullsJSON.utf8))

        #expect(response == ForecastResponseDTO(
            utcOffsetSeconds: 3600,
            timezone: nil,
            current: ForecastCurrentDTO(
                time: 1_795_388_400, temperature2m: nil, apparentTemperature: nil, relativeHumidity2m: nil,
                isDay: 1, weatherCode: nil, cloudCover: nil, precipitationProbability: nil,
                windSpeed10m: nil, windGusts10m: nil, windDirection10m: nil
            ),
            hourly: ForecastHourlyDTO(
                time: [1_795_388_400, 1_795_392_000],
                temperature2m: [nil], precipitationProbability: nil, weatherCode: [3, nil], isDay: nil
            ),
            daily: nil
        ))
    }

    private static let detailJSON = #"""
    {"latitude":50.064266,"longitude":19.923676,"generationtime_ms":0.39958953857421875,"utc_offset_seconds":3600,"timezone":"Europe/Warsaw","timezone_abbreviation":"GMT+1","elevation":214.0,"current_units":{"time":"unixtime","interval":"seconds","temperature_2m":"°C","apparent_temperature":"°C","relative_humidity_2m":"%","is_day":"","weather_code":"wmo code","cloud_cover":"%","precipitation_probability":"%","wind_speed_10m":"km/h","wind_gusts_10m":"km/h","wind_direction_10m":"°"},"current":{"time":1795388400,"interval":900,"temperature_2m":1.0,"apparent_temperature":-2.2,"relative_humidity_2m":89,"is_day":0,"weather_code":3,"cloud_cover":100,"precipitation_probability":0,"wind_speed_10m":6.5,"wind_gusts_10m":10.1,"wind_direction_10m":247},"hourly_units":{"time":"unixtime","temperature_2m":"°C","precipitation_probability":"%","weather_code":"wmo code","is_day":""},"hourly":{"time":[1795388400,1795392000,1795395600],"temperature_2m":[1.0,0.6,0.9],"precipitation_probability":[0,0,0],"weather_code":[3,3,3],"is_day":[0,0,0]},"daily_units":{"time":"unixtime","weather_code":"wmo code","temperature_2m_max":"°C","temperature_2m_min":"°C","precipitation_probability_max":"%"},"daily":{"time":[1795388400,1795474800],"weather_code":[71,71],"temperature_2m_max":[2.5,1.8],"temperature_2m_min":[0.3,0.0],"precipitation_probability_max":[57,65]}}
    """#

    private static let nullsJSON = #"""
    {"utc_offset_seconds":3600,"current":{"time":1795388400,"interval":900,"temperature_2m":null,"is_day":1,"weather_code":null},"hourly":{"time":[1795388400,1795392000],"temperature_2m":[null],"weather_code":[3,null]}}
    """#
}
