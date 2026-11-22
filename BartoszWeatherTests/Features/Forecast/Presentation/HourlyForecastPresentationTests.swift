import Foundation
import Testing
@testable import BartoszWeather

struct HourlyForecastPresentationTests {
    private func hour(
        temperature: Double? = 24, precipitation: Int? = 30, condition: WeatherCondition = .clearSky
    ) -> HourlyForecast {
        HourlyForecast(
            date: Date(timeIntervalSince1970: 1_784_117_100), condition: condition, isDay: true,
            temperature: temperature, precipitationProbability: precipitation
        )
    }

    @Test func formatsTemperature() {
        #expect(hour(temperature: 24.4).temperatureText == "24°")
        #expect(hour(temperature: nil).temperatureText == "—")
    }

    @Test func formatsPrecipitation() {
        #expect(hour(precipitation: 30).precipitationText == "30%")
        #expect(hour(precipitation: nil).precipitationText == "—")
    }

    @Test(arguments: [(0 as Int?, false), (9, false), (10, true), (30, true), (nil, true)])
    func hidesPrecipitationBelowTenPercent(probability: Int?, isShown: Bool) {
        #expect(hour(precipitation: probability).showsPrecipitation == isShown)
    }

    @Test func readsTimeTemperatureConditionAndPrecipitation() {
        #expect(
            hour().accessibilityLabel(timeLabel: "Now")
                == "Now, 24 degrees, Clear sky, 30% chance of precipitation"
        )
    }

    @Test func leavesOutHiddenPrecipitationFromTheSpokenLabel() {
        #expect(hour(precipitation: 5).accessibilityLabel(timeLabel: "15:00") == "15:00, 24 degrees, Clear sky")
    }

    @Test func readsMissingTemperatureAsNoData() {
        #expect(
            hour(temperature: nil, precipitation: nil).accessibilityLabel(timeLabel: "15:00")
                == "15:00, No data, Clear sky"
        )
    }
}
