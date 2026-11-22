import SwiftUI

struct WeatherSymbol: View {
    @Environment(\.weatherAppearance) private var appearance
    private let icon: Icon
    @ScaledMetric private var size: CGFloat

    init(icon: Icon, size: CGFloat, relativeTo textStyle: Font.TextStyle) {
        self.icon = icon
        _size = ScaledMetric(wrappedValue: size, relativeTo: textStyle)
    }

    var body: some View {
        Image(icon: icon)
            .resizable()
            .symbolRenderingMode(.palette)
            .foregroundStyle(Color(appearance.text), Color(appearance.symbolAccent))
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}
