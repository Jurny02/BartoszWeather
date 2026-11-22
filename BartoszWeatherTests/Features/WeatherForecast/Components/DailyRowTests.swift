import Foundation
import Testing
@testable import BartoszWeather

struct DailyRowTests {
    private func day(
        _ condition: WeatherCondition = .partlyCloudy,
        low: Double?,
        high: Double?,
        chance: Int?
    ) -> DailyForecast {
        DailyForecast(
            date: Date(timeIntervalSince1970: 1_795_302_000),
            condition: condition,
            minTemperature: low,
            maxTemperature: high,
            precipitationProbability: chance
        )
    }

    @Test func readsDayConditionChanceOfRainAndTemperatureRange() {
        let row = DailyRow(day: day(low: 8, high: 15, chance: 20), dayLabel: "Today")
        #expect(row.icon == .cloudSunFill)
        #expect(row.displayedPrecipitation == "20%")
        #expect(row.displayedLow == "8°")
        #expect(row.displayedHigh == "15°")
        #expect(row.showsRangeBar)
        #expect(row.accessibilityLabel == "Today, Partly cloudy, chance of rain 20%, low 8°, high 15°")
    }

    @Test func readsNoDataWhenEverythingIsMissing() {
        let row = DailyRow(day: day(.unknown, low: nil, high: nil, chance: nil), dayLabel: "Tuesday")
        #expect(row.displayedPrecipitation == "—")
        #expect(row.displayedLow == "—")
        #expect(row.displayedHigh == "—")
        #expect(row.showsRangeBar == false)
        #expect(row.accessibilityLabel == "Tuesday, no data")
    }

    @Test func keepsAKnownConditionWhenMeasurementsAreMissing() {
        let row = DailyRow(day: day(.rain, low: nil, high: nil, chance: nil), dayLabel: "Tuesday")
        #expect(row.accessibilityLabel == "Tuesday, Rain, no data")
    }

    @Test func readsNoDataForEachMissingValue() {
        let row = DailyRow(day: day(.overcast, low: nil, high: 12, chance: 40), dayLabel: "Wednesday")
        #expect(row.showsRangeBar == false)
        #expect(row.accessibilityLabel == "Wednesday, Overcast, chance of rain 40%, low no data, high 12°")
    }

    @Test func hidesTheRangeBarForAnImplausibleTemperature() {
        let row = DailyRow(day: day(low: -.infinity, high: 12, chance: 0), dayLabel: "Thursday")
        #expect(row.displayedLow == "—")
        #expect(row.showsRangeBar == false)
    }

    @Test func boundsSpanTheLowestLowAndHighestHigh() {
        let days = [day(low: 4, high: 9, chance: 0), day(low: -6, high: 1, chance: 0), day(low: 8, high: 15, chance: 0)]
        #expect(DailyRow.temperatureBounds(for: days) == -6...15)
    }

    @Test func boundsSkipMissingAndImplausibleTemperatures() {
        let days = [day(low: nil, high: 9, chance: 0), day(low: 2, high: .nan, chance: 0)]
        #expect(DailyRow.temperatureBounds(for: days) == 2...9)
    }

    @Test func boundsAreMissingWithoutBothEnds() {
        #expect(DailyRow.temperatureBounds(for: []) == nil)
        #expect(DailyRow.temperatureBounds(for: [day(low: nil, high: 9, chance: 0)]) == nil)
    }

    @Test func boundsAreMissingWhenTheLowestLowIsAboveTheHighestHigh() {
        #expect(DailyRow.temperatureBounds(for: [day(low: 10, high: 5, chance: 0)]) == nil)
    }
}
