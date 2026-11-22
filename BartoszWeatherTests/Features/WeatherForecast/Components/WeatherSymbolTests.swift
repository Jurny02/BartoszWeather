import Testing
@testable import BartoszWeather

struct WeatherSymbolTests {
    @Test func paintsTheWholeSunWithTheAccent() {
        #expect(WeatherSymbol.palette(for: .sunMaxFill) == .init(primary: .accent, secondary: .accent, tertiary: .accent))
    }

    @Test(arguments: [Icon.cloudSunFill, .cloudSunRainFill])
    func paintsOnlyTheSunLayerWithTheAccent(icon: Icon) {
        #expect(WeatherSymbol.palette(for: icon) == .init(primary: .text, secondary: .accent, tertiary: .text))
    }

    @Test(arguments: [Icon.cloudRainFill, .cloudSnowFill, .moonStarsFill, .cloudMoonFill, .cloudBoltRainFill])
    func paintsSymbolsWithoutASunInTheTextColor(icon: Icon) {
        #expect(WeatherSymbol.palette(for: icon) == .init(primary: .text, secondary: .text, tertiary: .text))
    }
}
