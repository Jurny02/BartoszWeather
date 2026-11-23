import Testing
@testable import BartoszWeather

struct TemperatureRangeSegmentTests {
    @Test func placesTheSegmentWithinTheSharedRange() {
        let segment = TemperatureRangeSegment(low: 5, high: 15, within: 0...20)

        #expect(segment?.start == 0.25)
        #expect(segment?.end == 0.75)
    }

    @Test func measuresTheSegmentAsAFractionOfTheBar() {
        let segment = TemperatureRangeSegment(low: 5, high: 15, within: 0...20)

        #expect(segment?.length == 0.5)
    }

    @Test func fillsTheBarForTheExtremeDays() {
        let segment = TemperatureRangeSegment(low: 0, high: 20, within: 0...20)

        #expect(segment?.start == 0)
        #expect(segment?.end == 1)
    }

    @Test func clampsTemperaturesOutsideTheRange() {
        let segment = TemperatureRangeSegment(low: -10, high: 40, within: 0...20)

        #expect(segment?.start == 0)
        #expect(segment?.end == 1)
    }

    @Test func fillsTheBarWhenTheRangeIsASinglePoint() {
        let segment = TemperatureRangeSegment(low: 10, high: 10, within: 10...10)

        #expect(segment?.start == 0)
        #expect(segment?.end == 1)
    }

    @Test func hasNoSegmentWithoutData() {
        #expect(TemperatureRangeSegment(low: nil, high: 10, within: 0...20) == nil)
        #expect(TemperatureRangeSegment(low: 5, high: nil, within: 0...20) == nil)
        #expect(TemperatureRangeSegment(low: 5, high: 10, within: nil) == nil)
    }
}
