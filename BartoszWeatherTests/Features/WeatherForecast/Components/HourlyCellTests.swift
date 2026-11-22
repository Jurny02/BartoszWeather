import Foundation
import Testing
@testable import BartoszWeather

struct HourlyCellTests {
    private func hour(
        _ condition: WeatherCondition = .partlyCloudy,
        isDay: Bool = true,
        temperature: Double?,
        chance: Int?
    ) -> HourlyForecast {
        HourlyForecast(
            date: Date(timeIntervalSince1970: 1_795_302_000),
            condition: condition,
            isDay: isDay,
            temperature: temperature,
            precipitationProbability: chance
        )
    }

    @Test func readsTimeConditionTemperatureAndChanceOfRain() {
        let cell = HourlyCell(hour: hour(temperature: 14.2, chance: 20), timeLabel: "15:00")
        #expect(cell.displayedTemperature == "14°")
        #expect(cell.displayedPrecipitation == "20%")
        #expect(cell.accessibilityLabel == "15:00, Partly cloudy, 14°, chance of rain 20%")
    }

    @Test func picksTheSymbolForDayOrNight() {
        #expect(HourlyCell(hour: hour(isDay: true, temperature: 1, chance: 0), timeLabel: "12:00").icon == .cloudSunFill)
        #expect(HourlyCell(hour: hour(isDay: false, temperature: 1, chance: 0), timeLabel: "00:00").icon == .cloudMoonFill)
    }

    @Test func hidesChanceOfRainBelowTenPercent() {
        let cell = HourlyCell(hour: hour(.clearSky, isDay: false, temperature: -12, chance: 9), timeLabel: "Now")
        #expect(cell.displayedPrecipitation == nil)
        #expect(cell.accessibilityLabel == "Now, Clear sky, -12°")
    }

    @Test func showsTenPercentChanceOfRain() {
        let cell = HourlyCell(hour: hour(temperature: 10, chance: 10), timeLabel: "16:00")
        #expect(cell.displayedPrecipitation == "10%")
    }

    @Test func readsNoDataForEveryMissingValue() {
        let cell = HourlyCell(hour: hour(temperature: nil, chance: nil), timeLabel: "15:00")
        #expect(cell.displayedTemperature == "—")
        #expect(cell.displayedPrecipitation == "—")
        #expect(cell.accessibilityLabel == "15:00, Partly cloudy, no data, chance of rain no data")
    }

    @Test func treatsAnImplausibleTemperatureAsMissing() {
        let cell = HourlyCell(hour: hour(temperature: .nan, chance: 0), timeLabel: "15:00")
        #expect(cell.displayedTemperature == "—")
        #expect(cell.accessibilityLabel == "15:00, Partly cloudy, no data")
    }

    @Test func leavesAnUnknownConditionOutOfTheLabel() {
        let cell = HourlyCell(hour: hour(.unknown, temperature: 10, chance: 30), timeLabel: "15:00")
        #expect(cell.icon == .exclamationmarkIcloud)
        #expect(cell.accessibilityLabel == "15:00, 10°, chance of rain 30%")
    }
}
