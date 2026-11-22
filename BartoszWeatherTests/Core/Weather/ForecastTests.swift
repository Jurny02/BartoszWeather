import Foundation
import Testing
@testable import BartoszWeather

struct ForecastTests {
    private let start = Date(timeIntervalSince1970: 1_795_302_000)

    private func forecast(hourCount: Int) -> Forecast {
        let hourly = (0..<hourCount).map { offset in
            HourlyForecast(
                date: start.addingTimeInterval(TimeInterval(offset) * 3600),
                condition: .clearSky,
                isDay: true,
                temperature: Double(offset),
                precipitationProbability: 0
            )
        }
        let current = CurrentWeather(
            date: start, condition: .clearSky, isDay: true, temperature: nil, apparentTemperature: nil,
            humidity: nil, cloudCover: nil, precipitationProbability: nil, wind: nil
        )
        return Forecast(current: current, hourly: hourly, daily: [], timeZone: .gmt, updatedAt: start)
    }

    @Test func hoursStartWithTheHourContainingTheDate() {
        let now = start.addingTimeInterval(2 * 3600 + 25 * 60)

        let hours = forecast(hourCount: 10).hours(from: now, count: 3)

        #expect(hours.map(\.temperature) == [2, 3, 4])
    }

    @Test func hoursStopAtTheEndOfTheForecast() {
        let now = start.addingTimeInterval(8 * 3600)

        let hours = forecast(hourCount: 10).hours(from: now, count: 24)

        #expect(hours.map(\.temperature) == [8, 9])
    }

    @Test func hoursAreEmptyAfterTheForecastEnds() {
        let now = start.addingTimeInterval(10 * 3600)

        #expect(forecast(hourCount: 10).hours(from: now, count: 24).isEmpty)
    }

    @Test(arguments: [0, -1])
    func hoursAreEmptyForANonPositiveCount(count: Int) {
        #expect(forecast(hourCount: 10).hours(from: start, count: count).isEmpty)
    }
}
