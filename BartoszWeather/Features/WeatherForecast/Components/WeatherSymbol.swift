import SwiftUI

struct WeatherSymbol: View {
    nonisolated enum Layer: Equatable, Sendable {
        case text
        case accent
    }

    nonisolated struct Palette: Equatable, Sendable {
        let primary: Layer
        let secondary: Layer
        let tertiary: Layer
    }

    @Environment(\.weatherAppearance) private var appearance
    private let icon: Icon
    @ScaledMetric private var size: CGFloat

    init(icon: Icon, size: CGFloat, relativeTo textStyle: Font.TextStyle) {
        self.icon = icon
        _size = ScaledMetric(wrappedValue: size, relativeTo: textStyle)
    }

    nonisolated static func palette(for icon: Icon) -> Palette {
        switch icon {
        case .sunMaxFill: Palette(primary: .accent, secondary: .accent, tertiary: .accent)
        case .cloudSunFill, .cloudSunRainFill: Palette(primary: .text, secondary: .accent, tertiary: .text)
        default: Palette(primary: .text, secondary: .text, tertiary: .text)
        }
    }

    var body: some View {
        let palette = Self.palette(for: icon)
        Image(icon: icon)
            .resizable()
            .symbolRenderingMode(.palette)
            .foregroundStyle(color(for: palette.primary), color(for: palette.secondary), color(for: palette.tertiary))
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }

    private func color(for layer: Layer) -> Color {
        switch layer {
        case .text: Color(appearance.text)
        case .accent: Color(appearance.symbolAccent)
        }
    }
}
