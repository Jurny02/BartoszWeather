import CoreGraphics
import Testing
@testable import BartoszWeather

struct SizeTokensTests {
    @Test func buttonSizeMatchesFigmaRetryButton() {
        #expect(Size.buttonHeight == 48)
        #expect(Size.buttonMinWidth == 144)
    }

    @Test func stateIconMatchesFigmaStateView() {
        #expect(Size.stateIcon == 48)
    }
}
