import Testing
@testable import BartoszWeather

struct WeatherConditionPresentationTests {
    @Test(arguments: [
        (WeatherCondition.clearSky, Icon.sunMaxFill, Icon.moonStarsFill),
        (.mainlyClear, .sunMaxFill, .moonStarsFill),
        (.partlyCloudy, .cloudSunFill, .cloudMoonFill),
        (.rainShowers, .cloudSunRainFill, .cloudMoonRainFill),
        (.overcast, .cloudFill, .cloudFill),
        (.fog, .cloudFogFill, .cloudFogFill),
        (.drizzle, .cloudDrizzleFill, .cloudDrizzleFill),
        (.freezingDrizzle, .cloudSleetFill, .cloudSleetFill),
        (.freezingRain, .cloudSleetFill, .cloudSleetFill),
        (.rain, .cloudRainFill, .cloudRainFill),
        (.heavyRain, .cloudHeavyrainFill, .cloudHeavyrainFill),
        (.snow, .cloudSnowFill, .cloudSnowFill),
        (.snowGrains, .cloudSnowFill, .cloudSnowFill),
        (.snowShowers, .cloudSnowFill, .cloudSnowFill),
        (.thunderstorm, .cloudBoltRainFill, .cloudBoltRainFill),
        (.thunderstormWithHail, .cloudHailFill, .cloudHailFill),
        (.unknown, .exclamationmarkIcloud, .exclamationmarkIcloud),
    ])
    func picksTheIconForDayAndNight(condition: WeatherCondition, day: Icon, night: Icon) {
        #expect(condition.icon(isDay: true) == day)
        #expect(condition.icon(isDay: false) == night)
    }

    @Test func describesTheConditionInEnglish() {
        #expect(WeatherCondition.clearSky.localizedDescription == "Clear sky")
        #expect(WeatherCondition.thunderstormWithHail.localizedDescription == "Thunderstorm with hail")
        #expect(WeatherCondition.unknown.localizedDescription == "Unknown conditions")
    }
}
