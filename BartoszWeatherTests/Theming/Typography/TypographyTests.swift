import SwiftUI
import Testing
@testable import BartoszWeather

struct TypographyTests {
    @Test(arguments: [
        (Typography.largeTitle, CGFloat(34), Font.Weight.bold),
        (.title, 22, .bold),
        (.headline, 17, .semibold),
        (.body, 17, .regular),
        (.footnote, 13, .regular),
        (.caption, 12, .medium),
        (.metricValue, 26, .medium),
        (.cityTitle, 28, .medium),
        (.heroTemperature, 88, .light),
        (.cardCity, 22, .semibold),
        (.cardTemperature, 44, .light),
        (.cardCaption, 13, .medium),
    ])
    func matchesFigmaTypeScale(style: Typography, size: CGFloat, weight: Font.Weight) {
        #expect(style.size == size)
        #expect(style.weight == weight)
    }

    @Test(arguments: [
        (Typography.largeTitle, Font.TextStyle.largeTitle),
        (.title, .title2),
        (.headline, .headline),
        (.body, .body),
        (.footnote, .footnote),
        (.caption, .caption),
        (.metricValue, .title),
        (.cityTitle, .title),
        (.heroTemperature, .largeTitle),
        (.cardCity, .title2),
        (.cardTemperature, .largeTitle),
        (.cardCaption, .footnote),
    ])
    func scalesWithMatchingDynamicTypeStyle(style: Typography, textStyle: Font.TextStyle) {
        #expect(style.textStyle == textStyle)
    }
}
