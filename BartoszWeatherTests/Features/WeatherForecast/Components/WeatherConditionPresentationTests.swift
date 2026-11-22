import Testing
@testable import BartoszWeather

struct WeatherConditionPresentationTests {
    private static let allConditions: [WeatherCondition] = [
        .clearSky, .mainlyClear, .partlyCloudy, .overcast, .fog, .drizzle, .freezingDrizzle, .rain, .heavyRain,
        .freezingRain, .snow, .snowGrains, .rainShowers, .snowShowers, .thunderstorm, .thunderstormWithHail, .unknown,
    ]

    @Test(arguments: [
        (WeatherCondition.clearSky, Icon.sunMaxFill, Icon.moonStarsFill),
        (.mainlyClear, .sunMaxFill, .moonStarsFill),
        (.partlyCloudy, .cloudSunFill, .cloudMoonFill),
        (.rainShowers, .cloudSunRainFill, .cloudMoonRainFill),
    ])
    func usesSunSymbolsByDayAndMoonSymbolsAtNight(condition: WeatherCondition, day: Icon, night: Icon) {
        #expect(condition.icon(isDay: true) == day)
        #expect(condition.icon(isDay: false) == night)
    }

    @Test(arguments: [
        (WeatherCondition.overcast, Icon.cloudFill),
        (.fog, .cloudFogFill),
        (.drizzle, .cloudDrizzleFill),
        (.freezingDrizzle, .cloudSleetFill),
        (.rain, .cloudRainFill),
        (.heavyRain, .cloudHeavyrainFill),
        (.freezingRain, .cloudSleetFill),
        (.snow, .cloudSnowFill),
        (.snowGrains, .cloudSnowFill),
        (.snowShowers, .cloudSnowFill),
        (.thunderstorm, .cloudBoltRainFill),
        (.thunderstormWithHail, .cloudHailFill),
        (.unknown, .exclamationmarkIcloud),
    ])
    func usesTheSameSymbolByDayAndNight(condition: WeatherCondition, icon: Icon) {
        #expect(condition.icon(isDay: true) == icon)
        #expect(condition.icon(isDay: false) == icon)
    }

    @Test(arguments: [
        (WeatherCondition.clearSky, "Clear sky"),
        (.partlyCloudy, "Partly cloudy"),
        (.heavyRain, "Heavy rain"),
        (.thunderstormWithHail, "Thunderstorm with hail"),
        (.unknown, "Unknown conditions"),
    ])
    func describesTheCondition(condition: WeatherCondition, description: String) {
        #expect(condition.localizedDescription == description)
    }

    @Test func describesEveryConditionDifferently() {
        let descriptions = Self.allConditions.map(\.localizedDescription)
        #expect(Set(descriptions).count == Self.allConditions.count)
        #expect(descriptions.allSatisfy { !$0.isEmpty })
    }

    @Test func speaksKnownConditionsAndSkipsUnknown() {
        #expect(WeatherCondition.rain.spokenDescription == "Rain")
        #expect(WeatherCondition.unknown.spokenDescription == nil)
    }
}
