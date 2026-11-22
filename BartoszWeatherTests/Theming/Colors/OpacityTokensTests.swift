import Testing
@testable import BartoszWeather

struct OpacityTokensTests {
    @Test func pressedOpacityDimsWithoutHiding() {
        #expect(Opacity.pressed == 0.8)
    }
}
