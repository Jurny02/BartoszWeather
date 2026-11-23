import Foundation
import Testing
@testable import BartoszWeather

/// Tests that the Open-Meteo forecast service requests the detail preset and maps the response to `Forecast`.
struct OpenMeteoForecastServiceTests {
    private let now = Date(timeIntervalSince1970: 1_795_388_700)
    private let warsaw = TimeZone(identifier: "Europe/Warsaw")!

    private func makeService(response: ForecastResponseDTO) -> (OpenMeteoForecastService, FakeAPIClient) {
        let client = FakeAPIClient(response: response)
        let now = now
        return (OpenMeteoForecastService(client: client, now: { now }), client)
    }

    private func current(
        isDay: Int? = 0, weatherCode: Int? = 3, humidity: Int? = 89, cloudCover: Int? = 100,
        precipitation: Int? = 0, windSpeed: Double? = 6.5, windGusts: Double? = 10.1, windDirection: Double? = 247
    ) -> ForecastCurrentDTO {
        ForecastCurrentDTO(
            time: 1_795_388_400, temperature2m: 1.0, apparentTemperature: -2.2, relativeHumidity2m: humidity,
            isDay: isDay, weatherCode: weatherCode, cloudCover: cloudCover, precipitationProbability: precipitation,
            windSpeed10m: windSpeed, windGusts10m: windGusts, windDirection10m: windDirection
        )
    }

    private func response(
        timezone: String? = "Europe/Warsaw",
        utcOffsetSeconds: Int? = 3600,
        current: ForecastCurrentDTO?,
        hourly: ForecastHourlyDTO? = nil,
        daily: ForecastDailyDTO? = nil
    ) -> ForecastResponseDTO {
        ForecastResponseDTO(
            utcOffsetSeconds: utcOffsetSeconds, timezone: timezone, current: current, hourly: hourly, daily: daily
        )
    }

    private func expectDecodingError(
        sourceLocation: SourceLocation = #_sourceLocation,
        _ load: () async throws -> Forecast
    ) async {
        let error = await #expect(throws: APIError.self, sourceLocation: sourceLocation) {
            try await load()
        }
        guard case .decoding = error else {
            Issue.record("Expected APIError.decoding, got \(String(describing: error))", sourceLocation: sourceLocation)
            return
        }
    }

    @Test func requestsTheDetailPresetForTheCity() async throws {
        let (service, client) = makeService(response: response(current: current()))

        _ = try await service.forecast(for: .krakow)

        let endpoint = try #require(client.sentEndpoints.first as? ForecastEndpoint)
        let detail = ForecastEndpoint.detail(for: City.krakow.coordinate)
        #expect(client.sentEndpoints.count == 1)
        #expect(endpoint.coordinate == City.krakow.coordinate)
        #expect(endpoint.queryItems == detail.queryItems)
    }

    @Test func mapsAFullResponse() async throws {
        let (service, _) = makeService(response: response(
            current: current(),
            hourly: ForecastHourlyDTO(
                time: [1_795_388_400, 1_795_392_000],
                temperature2m: [1.0, 0.6], precipitationProbability: [0, 10], weatherCode: [3, 61], isDay: [0, 1]
            ),
            daily: ForecastDailyDTO(
                time: [1_795_388_400], weatherCode: [71], temperature2mMax: [2.5], temperature2mMin: [0.3],
                precipitationProbabilityMax: [57]
            )
        ))

        let forecast = try await service.forecast(for: .krakow)

        #expect(forecast == Forecast(
            current: CurrentWeather(
                date: Date(timeIntervalSince1970: 1_795_388_400), condition: .overcast, isDay: false,
                temperature: 1.0, apparentTemperature: -2.2, humidity: 89, cloudCover: 100, precipitationProbability: 0,
                wind: Wind(speed: 6.5, gusts: 10.1, direction: 247)
            ),
            hourly: [
                HourlyForecast(
                    date: Date(timeIntervalSince1970: 1_795_388_400), condition: .overcast, isDay: false,
                    temperature: 1.0, precipitationProbability: 0
                ),
                HourlyForecast(
                    date: Date(timeIntervalSince1970: 1_795_392_000), condition: .rain, isDay: true,
                    temperature: 0.6, precipitationProbability: 10
                ),
            ],
            daily: [
                DailyForecast(
                    date: Date(timeIntervalSince1970: 1_795_388_400), condition: .snow,
                    minTemperature: 0.3, maxTemperature: 2.5, precipitationProbability: 57
                ),
            ],
            timeZone: warsaw,
            updatedAt: now
        ))
    }

    @Test func startsEachDayAtLocalMidnightAcrossADaylightSavingChange() async throws {
        let october26AtSummerOffset = 1_792_965_600
        let (service, _) = makeService(response: response(
            utcOffsetSeconds: 7200,
            current: current(),
            daily: ForecastDailyDTO(
                time: [october26AtSummerOffset], weatherCode: [3], temperature2mMax: [12], temperature2mMin: [5],
                precipitationProbabilityMax: [10]
            )
        ))

        let forecast = try await service.forecast(for: .krakow)

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = warsaw
        let october26 = try #require(calendar.date(from: DateComponents(year: 2026, month: 10, day: 26)))
        #expect(forecast.daily.map(\.date) == [october26])
    }

    @Test func fallsBackToTheUTCOffsetForAnUnknownTimeZone() async throws {
        let (service, _) = makeService(response: response(timezone: "Mars/Olympus_Mons", current: current()))

        let forecast = try await service.forecast(for: .krakow)

        #expect(forecast.timeZone == TimeZone(secondsFromGMT: 3600))
    }

    @Test func failsWithoutAnyTimeZone() async {
        let (service, _) = makeService(response: response(timezone: nil, utcOffsetSeconds: nil, current: current()))

        await expectDecodingError { try await service.forecast(for: .krakow) }
    }

    @Test func failsWithoutCurrentConditions() async {
        let (service, _) = makeService(response: response(current: nil))

        await expectDecodingError { try await service.forecast(for: .krakow) }
    }

    @Test func readsMissingValuesAndShortArraysAsNoData() async throws {
        let (service, _) = makeService(response: response(
            current: current(isDay: nil, weatherCode: nil, windSpeed: nil),
            hourly: ForecastHourlyDTO(
                time: [1_795_388_400, 1_795_392_000],
                temperature2m: [nil], precipitationProbability: nil, weatherCode: [3, nil], isDay: nil
            ),
            daily: ForecastDailyDTO(
                time: [1_795_388_400], weatherCode: nil, temperature2mMax: [], temperature2mMin: [nil],
                precipitationProbabilityMax: nil
            )
        ))

        let forecast = try await service.forecast(for: .krakow)

        #expect(forecast.current.condition == .unknown)
        #expect(forecast.current.isDay)
        #expect(forecast.current.wind == nil)
        #expect(forecast.hourly == [
            HourlyForecast(
                date: Date(timeIntervalSince1970: 1_795_388_400), condition: .overcast, isDay: true,
                temperature: nil, precipitationProbability: nil
            ),
            HourlyForecast(
                date: Date(timeIntervalSince1970: 1_795_392_000), condition: .unknown, isDay: true,
                temperature: nil, precipitationProbability: nil
            ),
        ])
        #expect(forecast.daily == [
            DailyForecast(
                date: Date(timeIntervalSince1970: 1_795_388_400), condition: .unknown,
                minTemperature: nil, maxTemperature: nil, precipitationProbability: nil
            ),
        ])
    }

    @Test func dropsValuesOutsideTheirRange() async throws {
        let (service, _) = makeService(response: response(
            current: current(humidity: 120, cloudCover: -5, precipitation: 101, windGusts: -1, windDirection: 400),
            hourly: ForecastHourlyDTO(
                time: [1_795_388_400], temperature2m: [1.0], precipitationProbability: [150], weatherCode: [3], isDay: [0]
            )
        ))

        let forecast = try await service.forecast(for: .krakow)

        #expect(forecast.current.humidity == nil)
        #expect(forecast.current.cloudCover == nil)
        #expect(forecast.current.precipitationProbability == nil)
        #expect(forecast.current.wind == Wind(speed: 6.5, gusts: nil, direction: nil))
        #expect(forecast.hourly.first?.precipitationProbability == nil)
    }

    @Test func dropsWindWithANegativeSpeed() async throws {
        let (service, _) = makeService(response: response(current: current(windSpeed: -3)))

        let forecast = try await service.forecast(for: .krakow)

        #expect(forecast.current.wind == nil)
    }

    @Test func capsTheNumberOfHoursAndDays() async throws {
        let hours = (0..<400).map { 1_795_388_400 + $0 * 3600 }
        let days = (0..<20).map { 1_795_388_400 + $0 * 86_400 }
        let (service, _) = makeService(response: response(
            current: current(),
            hourly: ForecastHourlyDTO(
                time: hours, temperature2m: nil, precipitationProbability: nil, weatherCode: nil, isDay: nil
            ),
            daily: ForecastDailyDTO(
                time: days, weatherCode: nil, temperature2mMax: nil, temperature2mMin: nil, precipitationProbabilityMax: nil
            )
        ))

        let forecast = try await service.forecast(for: .krakow)

        #expect(forecast.hourly.count == 384)
        #expect(forecast.daily.count == 16)
    }

    @Test func passesClientErrorsThrough() async {
        let service = OpenMeteoForecastService(client: FakeAPIClient(error: APIError.offline), now: { .now })

        await #expect(throws: APIError.offline) {
            try await service.forecast(for: .krakow)
        }
    }
}
