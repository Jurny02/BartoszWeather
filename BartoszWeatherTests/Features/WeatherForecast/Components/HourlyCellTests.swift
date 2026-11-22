import Testing
@testable import BartoszWeather

struct HourlyCellTests {
    @Test func showsTemperatureAndChanceOfRain() {
        let cell = HourlyCell(time: "15:00", icon: .cloudSunFill, temperature: 14.2, precipitationChance: 20)
        #expect(cell.displayedTemperature == "14°")
        #expect(cell.displayedPrecipitation == "20%")
        #expect(cell.accessibilityLabel == "15:00, 14°, chance of rain 20%")
    }

    @Test func hidesChanceOfRainBelowTenPercent() {
        let cell = HourlyCell(time: "Now", icon: .moonStarsFill, temperature: -12, precipitationChance: 9)
        #expect(cell.displayedPrecipitation == nil)
        #expect(cell.accessibilityLabel == "Now, -12°")
    }

    @Test func showsTenPercentChanceOfRain() {
        let cell = HourlyCell(time: "16:00", icon: .cloudFill, temperature: 10, precipitationChance: 10)
        #expect(cell.displayedPrecipitation == "10%")
    }

    @Test func readsNoDataForEveryMissingValue() {
        let cell = HourlyCell(time: "15:00", icon: .cloudSunFill, temperature: nil, precipitationChance: nil)
        #expect(cell.displayedTemperature == "—")
        #expect(cell.displayedPrecipitation == "—")
        #expect(cell.accessibilityLabel == "15:00, no data, chance of rain no data")
    }
}
