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

    @Test(arguments: [Double.nan, .infinity, -.infinity, 1e300])
    func showsPlaceholderForImplausibleTemperature(value: Double) {
        #expect(ForecastFormat.temperature(value) == "—")
    }

    @Test func formatsPercentage() {
        #expect(ForecastFormat.percentage(20) == "20%")
        #expect(ForecastFormat.percentage(nil) == "—")
    }

    @Test func clampsPercentageToZeroThroughHundred() {
        #expect(ForecastFormat.percentage(-5) == "0%")
        #expect(ForecastFormat.percentage(120) == "100%")
    }
}
