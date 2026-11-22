import SwiftUI

/// Text styles from the Figma `iOS/*` type scale, scaled with Dynamic Type relative to `textStyle`.
nonisolated public enum Typography: CaseIterable, Sendable {
    case largeTitle
    case title
    case headline
    case body
    case footnote
    case caption
    case metricValue
    case cityTitle
    case heroTemperature
    case cardCity
    case cardTemperature
    case cardCaption

    public var size: CGFloat {
        switch self {
        case .largeTitle: 34
        case .cityTitle: 28
        case .heroTemperature: 88
        case .title, .cardCity: 22
        case .headline, .body: 17
        case .footnote, .cardCaption: 13
        case .caption: 12
        case .metricValue: 26
        case .cardTemperature: 44
        }
    }

    public var weight: Font.Weight {
        switch self {
        case .largeTitle, .title: .bold
        case .headline, .cardCity: .semibold
        case .body, .footnote: .regular
        case .caption, .metricValue, .cityTitle, .cardCaption: .medium
        case .heroTemperature, .cardTemperature: .light
        }
    }

    public var textStyle: Font.TextStyle {
        switch self {
        case .largeTitle: .largeTitle
        case .title, .cardCity: .title2
        case .headline: .headline
        case .body: .body
        case .footnote, .cardCaption: .footnote
        case .caption: .caption
        case .metricValue, .cityTitle: .title
        case .heroTemperature, .cardTemperature: .largeTitle
        }
    }
}

extension View {
    public func typography(_ typography: Typography) -> some View {
        modifier(TypographyModifier(typography: typography))
    }
}

private struct TypographyModifier: ViewModifier {
    let typography: Typography
    @ScaledMetric private var size: CGFloat

    init(typography: Typography) {
        self.typography = typography
        _size = ScaledMetric(wrappedValue: typography.size, relativeTo: typography.textStyle)
    }

    func body(content: Content) -> some View {
        content.font(.system(size: size, weight: typography.weight))
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.small) {
        ForEach(Typography.allCases, id: \.self) { style in
            Text(String(describing: style)).typography(style)
        }
    }
    .padding(Spacing.medium)
}
