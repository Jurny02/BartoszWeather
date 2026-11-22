import Testing
@testable import BartoszWeather

struct WeatherConditionTests {
    @Test(arguments: [
        (0, WeatherCondition.clearSky),
        (1, .mainlyClear),
        (2, .partlyCloudy),
        (3, .overcast),
        (45, .fog), (48, .fog),
        (51, .drizzle), (53, .drizzle), (55, .drizzle),
        (56, .freezingDrizzle), (57, .freezingDrizzle),
        (61, .rain), (63, .rain),
        (65, .heavyRain), (82, .heavyRain),
        (66, .freezingRain), (67, .freezingRain),
        (71, .snow), (73, .snow), (75, .snow),
        (77, .snowGrains),
        (80, .rainShowers), (81, .rainShowers),
        (85, .snowShowers), (86, .snowShowers),
        (95, .thunderstorm),
        (96, .thunderstormWithHail), (99, .thunderstormWithHail),
    ])
    func mapsWMOCode(code: Int, condition: WeatherCondition) {
        #expect(WeatherCondition(wmoCode: code) == condition)
    }

    @Test(arguments: [-1, 4, 50, 100])
    func mapsUnrecognisedCodeToUnknown(code: Int) {
        #expect(WeatherCondition(wmoCode: code) == .unknown)
    }
}
