import Testing
@testable import BartoszWeather

struct TemperatureRangeBarTests {
    @Test func fillsTheWholeTrackWithoutBounds() {
        let segment = TemperatureRangeBar.segment(low: 8, high: 15, bounds: nil)
        #expect(segment == 0...1)
    }

    @Test func placesTheRangeWithinTheBounds() {
        let segment = TemperatureRangeBar.segment(low: 5, high: 15, bounds: 0...20)
        #expect(segment == 0.25...0.75)
    }

    @Test func clampsTheRangeToTheBounds() {
        let segment = TemperatureRangeBar.segment(low: -5, high: 25, bounds: 0...20)
        #expect(segment == 0...1)
    }

    @Test func fillsTheWholeTrackWhenBoundsAreEqual() {
        let segment = TemperatureRangeBar.segment(low: 10, high: 10, bounds: 10...10)
        #expect(segment == 0...1)
    }
}
