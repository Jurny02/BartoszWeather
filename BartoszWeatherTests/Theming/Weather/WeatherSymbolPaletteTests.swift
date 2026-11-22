import Testing
@testable import BartoszWeather

struct WeatherSymbolPaletteTests {
    @Test func paintsTheWholeSunWithTheAccent() {
        #expect(WeatherSymbolPalette(icon: .sunMaxFill) == .init(primary: .accent, secondary: .accent, tertiary: .accent))
    }

    @Test(arguments: [Icon.cloudSunFill, .cloudSunRainFill])
    func paintsOnlyTheSunLayerWithTheAccent(icon: Icon) {
        #expect(WeatherSymbolPalette(icon: icon) == .init(primary: .text, secondary: .accent, tertiary: .text))
    }

    @Test(arguments: [Icon.cloudRainFill, .cloudSnowFill, .moonStarsFill, .cloudMoonFill, .cloudBoltRainFill])
    func paintsSymbolsWithoutASunInTheTextColor(icon: Icon) {
        #expect(WeatherSymbolPalette(icon: icon) == .init(primary: .text, secondary: .text, tertiary: .text))
    }
}
