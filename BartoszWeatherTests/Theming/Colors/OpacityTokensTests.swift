import Testing
@testable import BartoszWeather

struct OpacityTokensTests {
    @Test func pressedOpacityDimsWithoutHiding() {
        #expect(Opacity.pressed == 0.8)
    }

    @Test func disabledOpacityIsDimmerThanPressed() {
        #expect(Opacity.disabled == 0.5)
        #expect(Opacity.disabled < Opacity.pressed)
    }
}
