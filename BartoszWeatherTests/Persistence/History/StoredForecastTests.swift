import Foundation
import Testing
@testable import BartoszWeather

/// Tests that a forecast survives the trip to its stored JSON form and back, and that unreadable data is rejected.
struct StoredForecastTests {
    nonisolated private static let allConditions: [WeatherCondition] = [
        .clearSky, .mainlyClear, .partlyCloudy, .overcast, .fog, .drizzle, .freezingDrizzle, .rain, .heavyRain,
        .freezingRain, .snow, .snowGrains, .rainShowers, .snowShowers, .thunderstorm, .thunderstormWithHail, .unknown,
    ]

    private let date = Date(timeIntervalSince1970: 1_784_117_100)

    private func forecast(
        condition: WeatherCondition = .clearSky,
        timeZone: TimeZone = TimeZone(identifier: "Europe/Warsaw")!
    ) -> Forecast {
        Forecast(
            current: CurrentWeather(
                date: date, condition: condition, isDay: false, temperature: -3.5, apparentTemperature: nil,
                humidity: 80, cloudCover: nil, precipitationProbability: 30,
                wind: Wind(speed: 12.4, gusts: nil, direction: 270)
            ),
            hourly: [
                HourlyForecast(date: date, condition: condition, isDay: false, temperature: nil, precipitationProbability: 5),
                HourlyForecast(
                    date: date.addingTimeInterval(3_600), condition: .rain, isDay: true, temperature: 1.2,
                    precipitationProbability: nil
                ),
            ],
            daily: [
                DailyForecast(
                    date: date, condition: condition, minTemperature: -5, maxTemperature: nil, precipitationProbability: 40
                ),
            ],
            timeZone: timeZone,
            updatedAt: date.addingTimeInterval(0.25)
        )
    }

    @Test func roundTripsAForecastWithMissingValues() throws {
        let original = forecast()
        let data = try StoredForecast(original).encoded()
        #expect(try StoredForecast.decode(data).forecast() == original)
    }

    @Test func roundTripsAForecastWithoutWind() throws {
        let original = Forecast(
            current: CurrentWeather(
                date: date, condition: .fog, isDay: true, temperature: nil, apparentTemperature: nil, humidity: nil,
                cloudCover: nil, precipitationProbability: nil, wind: nil
            ),
            hourly: [], daily: [], timeZone: .gmt, updatedAt: date
        )
        #expect(try StoredForecast.decode(StoredForecast(original).encoded()).forecast() == original)
    }

    @Test(arguments: allConditions)
    func roundTripsEveryCondition(_ condition: WeatherCondition) throws {
        let original = forecast(condition: condition)
        #expect(try StoredForecast.decode(StoredForecast(original).encoded()).forecast() == original)
    }

    @Test func readsAnUnknownConditionKeyAsUnknown() throws {
        let data = try StoredForecast(forecast()).encoded()
        let renamed = try #require(String(data: data, encoding: .utf8))
            .replacingOccurrences(of: "\"clearSky\"", with: "\"sunnyAndBright\"")
        let stored = try StoredForecast.decode(Data(renamed.utf8)).forecast()
        #expect(stored.current.condition == .unknown)
        #expect(stored.daily.first?.condition == .unknown)
    }

    @Test func fallsBackToTheUTCOffsetForAnUnknownTimeZone() throws {
        let data = try StoredForecast(forecast()).encoded()
        let renamed = try #require(String(data: data, encoding: .utf8))
            .replacingOccurrences(of: "Europe\\/Warsaw", with: "Mars\\/Olympus")
            .replacingOccurrences(of: "Europe/Warsaw", with: "Mars/Olympus")
        let timeZone = try StoredForecast.decode(Data(renamed.utf8)).forecast().timeZone
        #expect(timeZone.secondsFromGMT(for: date) == TimeZone(identifier: "Europe/Warsaw")!.secondsFromGMT(for: date))
    }

    @Test func rejectsAnotherVersion() throws {
        let data = try StoredForecast(forecast()).encoded()
        var object = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        object["version"] = StoredForecast.currentVersion + 1
        let newer = try JSONSerialization.data(withJSONObject: object)
        #expect(throws: StoredForecastError.unsupportedVersion(StoredForecast.currentVersion + 1)) {
            try StoredForecast.decode(newer)
        }
    }

    @Test func rejectsCorruptData() {
        #expect(throws: (any Error).self) {
            try StoredForecast.decode(Data("not json".utf8))
        }
    }
}
