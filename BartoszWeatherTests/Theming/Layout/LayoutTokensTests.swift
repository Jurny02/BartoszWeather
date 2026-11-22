import CoreGraphics
import Testing
@testable import BartoszWeather

struct LayoutTokensTests {
    @Test func spacingMatchesFigmaScale() {
        let scale = [Spacing.xxSmall, Spacing.xSmall, Spacing.small, Spacing.medium, Spacing.large, Spacing.xLarge]
        #expect(scale == [4, 8, 12, 16, 24, 32])
    }

    @Test func radiusMatchesFigmaScale() {
        #expect([Radius.medium, Radius.large] == [12, 20])
    }
}
