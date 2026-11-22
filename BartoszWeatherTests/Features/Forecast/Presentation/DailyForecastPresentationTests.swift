import Foundation
import Testing
@testable import BartoszWeather

struct DailyForecastPresentationTests {
    private func day(low: Double? = 8, high: Double? = 15, precipitation: Int? = 30) -> DailyForecast {
        DailyForecast(
            date: Date(timeIntervalSince1970: 1_784_117_100), condition: .rain,
            minTemperature: low, maxTemperature: high, precipitationProbability: precipitation
        )
    }

    @Test func formatsTemperaturesAndPrecipitation() {
        let day = day(low: 7.6, high: 15.2, precipitation: 30)

        #expect(day.lowText == "8°")
        #expect(day.highText == "15°")
        #expect(day.precipitationText == "30%")
    }

    @Test func showsDashesForMissingValues() {
        let day = day(low: nil, high: nil, precipitation: nil)

        #expect(day.lowText == "—")
        #expect(day.highText == "—")
        #expect(day.precipitationText == "—")
    }

    @Test func readsTheWholeRow() {
        #expect(
            day().accessibilityLabel(dayLabel: "Today")
                == "Today, Rain, low 8 degrees, high 15 degrees, 30% chance of precipitation"
        )
    }

    @Test func leavesOutMissingValuesFromTheSpokenLabel() {
        #expect(day(low: nil, high: nil, precipitation: nil).accessibilityLabel(dayLabel: "Wed") == "Wed, Rain")
    }

    @Test func spansTheLowestLowAndHighestHigh() {
        let days = [day(low: 8, high: 15), day(low: 3, high: 12), day(low: 9, high: 21)]

        #expect(DailyForecast.temperatureRange(of: days) == 3...21)
    }

    @Test func ignoresMissingTemperaturesInTheRange() {
        let days = [day(low: nil, high: 15), day(low: 3, high: nil)]

        #expect(DailyForecast.temperatureRange(of: days) == 3...15)
    }

    @Test func hasNoRangeWithoutTemperatures() {
        #expect(DailyForecast.temperatureRange(of: []) == nil)
        #expect(DailyForecast.temperatureRange(of: [day(low: nil, high: nil)]) == nil)
    }
}
