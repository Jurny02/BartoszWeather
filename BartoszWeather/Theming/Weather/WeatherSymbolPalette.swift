/// Which color role paints each of the three layers of a multicolor weather symbol.
nonisolated public struct WeatherSymbolPalette: Equatable, Sendable {
    /// A color role a symbol layer can take.
    public enum Layer: Equatable, Sendable {
        case text
        case accent
    }

    public let primary: Layer
    public let secondary: Layer
    public let tertiary: Layer

    public init(primary: Layer, secondary: Layer, tertiary: Layer) {
        self.primary = primary
        self.secondary = secondary
        self.tertiary = tertiary
    }

    /// The palette for a symbol: sun parts take the accent, everything else the text color.
    public init(icon: Icon) {
        switch icon {
        case .sunMaxFill: self.init(primary: .accent, secondary: .accent, tertiary: .accent)
        case .cloudSunFill, .cloudSunRainFill: self.init(primary: .text, secondary: .accent, tertiary: .text)
        default: self.init(primary: .text, secondary: .text, tertiary: .text)
        }
    }
}
