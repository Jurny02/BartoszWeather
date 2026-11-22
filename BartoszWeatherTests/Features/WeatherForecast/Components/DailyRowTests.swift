import Testing
@testable import BartoszWeather

struct DailyRowTests {
    @Test func readsDayChanceOfRainAndTemperatureRange() {
        let row = DailyRow(day: "Today", icon: .cloudSunFill, precipitationChance: 20, low: 8, high: 15)
        #expect(row.displayedPrecipitation == "20%")
        #expect(row.displayedLow == "8°")
        #expect(row.displayedHigh == "15°")
        #expect(row.accessibilityLabel == "Today, chance of rain 20%, low 8°, high 15°")
    }

    @Test func readsNoDataWhenEverythingIsMissing() {
        let row = DailyRow(day: "Tuesday", icon: .cloudSunFill, precipitationChance: nil, low: nil, high: nil)
        #expect(row.displayedPrecipitation == "—")
        #expect(row.displayedLow == "—")
        #expect(row.displayedHigh == "—")
        #expect(row.accessibilityLabel == "Tuesday, no data")
    }

    @Test func readsNoDataForEachMissingValue() {
        let row = DailyRow(day: "Wednesday", icon: .cloudFill, precipitationChance: 40, low: nil, high: 12)
        #expect(row.accessibilityLabel == "Wednesday, chance of rain 40%, low no data, high 12°")
    }
}
