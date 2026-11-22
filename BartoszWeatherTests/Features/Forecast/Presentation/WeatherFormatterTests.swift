import Foundation
import Testing
@testable import BartoszWeather

struct WeatherFormatterTests {
    private let warsaw = TimeZone(identifier: "Europe/Warsaw")!
    private let formatter: WeatherFormatter
    private let noon = Date(timeIntervalSince1970: 1_784_117_100)
    private let lateEvening = Date(timeIntervalSince1970: 1_784_154_600)

    init() {
        formatter = WeatherFormatter(timeZone: TimeZone(identifier: "Europe/Warsaw")!, locale: Locale(identifier: "en_US"))
    }

    @Test(arguments: [
        (24.4 as Double?, "24°"),
        (24.5, "25°"),
        (0.2, "0°"),
        (-0.4, "0°"),
        (-12.0, "−12°"),
        (-0.6, "−1°"),
        (nil, "—"),
    ])
    func formatsTemperature(value: Double?, expected: String) {
        #expect(WeatherFormatter.temperature(value) == expected)
    }

    @Test func formatsHourCount() {
        #expect(WeatherFormatter.hourCount(24) == "24 hours")
        #expect(WeatherFormatter.hourCount(1) == "1 hour")
    }

    @Test func formatsPercent() {
        #expect(WeatherFormatter.percent(30) == "30%")
        #expect(WeatherFormatter.percent(nil) == "—")
    }

    @Test func formatsSpeed() {
        #expect(WeatherFormatter.speed(7.6) == "8 km/h")
        #expect(WeatherFormatter.speed(nil) == "—")
    }

    @Test(arguments: [
        (24.0 as Double?, "24 degrees"),
        (1.0, "1 degree"),
        (0.0, "0 degrees"),
        (-1.0, "minus 1 degree"),
        (-12.0, "minus 12 degrees"),
        (nil, "No data"),
    ])
    func speaksTemperature(value: Double?, expected: String) {
        #expect(WeatherFormatter.spokenTemperature(value) == expected)
    }

    @Test func showsTheHourInTheCityTimeZone() {
        #expect(formatter.hour(noon) == "14:05")
        #expect(formatter.hour(lateEvening) == "00:30")
    }

    @Test func showsTheHourOnA24HourClockRegardlessOfLocale() {
        let posix = WeatherFormatter(timeZone: warsaw, locale: Locale(identifier: "en_US_POSIX"))

        #expect(posix.hour(noon.addingTimeInterval(3600 * 2)) == "16:05")
    }

    @Test func namesTheCurrentDayToday() {
        #expect(formatter.dayName(noon, now: noon.addingTimeInterval(3600)) == "Today")
    }

    @Test func namesOtherDaysByWeekdayInTheCityTimeZone() {
        #expect(formatter.dayName(noon.addingTimeInterval(86_400), now: noon) == "Thu")
        #expect(formatter.dayName(lateEvening, now: noon) == "Thu")
    }

    @Test func showsTheUpdateTime() {
        #expect(formatter.updated(noon) == "Updated 14:05")
    }
}
