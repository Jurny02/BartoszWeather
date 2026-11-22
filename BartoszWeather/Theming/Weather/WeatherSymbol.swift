import SwiftUI

/// A decorative weather symbol drawn with palette rendering in the current weather appearance.
public struct WeatherSymbol: View {
    @Environment(\.weatherAppearance) private var appearance
    private let icon: Icon
    @ScaledMetric private var size: CGFloat

    public init(icon: Icon, size: CGFloat, relativeTo textStyle: Font.TextStyle) {
        self.icon = icon
        _size = ScaledMetric(wrappedValue: size, relativeTo: textStyle)
    }

    public var body: some View {
        let palette = WeatherSymbolPalette(icon: icon)
        Image(icon: icon)
            .resizable()
            .symbolRenderingMode(.palette)
            .foregroundStyle(color(for: palette.primary), color(for: palette.secondary), color(for: palette.tertiary))
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }

    private func color(for layer: WeatherSymbolPalette.Layer) -> Color {
        switch layer {
        case .text: Color(appearance.text)
        case .accent: Color(appearance.symbolAccent)
        }
    }
}

#Preview {
    HStack(spacing: Spacing.medium) {
        ForEach([Icon.sunMaxFill, .cloudSunFill, .cloudRainFill, .moonStarsFill], id: \.self) { icon in
            WeatherSymbol(icon: icon, size: 40, relativeTo: .title)
        }
    }
    .padding(Spacing.medium)
    .background(Color(.Weather.Clear.dayEnd))
}
