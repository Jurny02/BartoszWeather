import Testing
@testable import BartoszWeather

struct SkyTests {
    @Test(arguments: [
        (WeatherCondition.clearSky, Sky.clear),
        (.mainlyClear, .clear),
        (.partlyCloudy, .clear),
        (.overcast, .overcast),
        (.fog, .overcast),
        (.drizzle, .overcast),
        (.freezingDrizzle, .overcast),
        (.rain, .overcast),
        (.heavyRain, .overcast),
        (.freezingRain, .overcast),
        (.rainShowers, .overcast),
        (.unknown, .overcast),
        (.snow, .snow),
        (.snowGrains, .snow),
        (.snowShowers, .snow),
        (.thunderstorm, .storm),
        (.thunderstormWithHail, .storm),
    ])
    func mapsConditionToSky(condition: WeatherCondition, sky: Sky) {
        #expect(Sky(condition: condition) == sky)
    }

    @Test func usesTheClearDayColors() {
        let colors = Sky.clear.colors(isNight: false)

        #expect(colors.start == .Weather.Clear.dayStart)
        #expect(colors.end == .Weather.Clear.dayEnd)
    }

    @Test func usesTheNightColorsAfterDark() {
        let colors = Sky.storm.colors(isNight: true)

        #expect(colors.start == .Weather.Storm.nightStart)
        #expect(colors.end == .Weather.Storm.nightEnd)
    }

    @Test(arguments: Sky.allCases)
    func dayAndNightColorsDiffer(sky: Sky) {
        #expect(sky.colors(isNight: false).start != sky.colors(isNight: true).start)
    }

    @Test func onlyTheClearSkyIsDiagonal() {
        #expect(Sky.allCases.filter(\.isDiagonal) == [.clear])
    }
}
