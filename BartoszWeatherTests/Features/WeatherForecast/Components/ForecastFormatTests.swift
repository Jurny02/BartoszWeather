import Testing
@testable import BartoszWeather

struct ForecastFormatTests {
    @Test(arguments: [
        (14.0, "14°"),
        (14.5, "15°"),
        (-12.4, "-12°"),
        (-0.4, "0°"),
        (0.0, "0°"),
    ])
    func roundsTemperatureToWholeDegrees(value: Double, expected: String) {
        #expect(ForecastFormat.temperature(value) == expected)
    }

    @Test func showsPlaceholderForMissingTemperature() {
        #expect(ForecastFormat.temperature(nil) == "—")
    }

    @Test func formatsPercentage() {
        #expect(ForecastFormat.percentage(20) == "20%")
        #expect(ForecastFormat.percentage(nil) == "—")
    }
}
