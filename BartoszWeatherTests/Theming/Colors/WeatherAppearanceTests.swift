import SwiftUI
import Testing
@testable import BartoszWeather

struct WeatherAppearanceTests {
    @Test func dayUsesWeatherCardColors() {
        let appearance = WeatherAppearance.day
        #expect(appearance.card == .Weather.card)
        #expect(appearance.text == .Weather.text)
        #expect(appearance.secondaryText == .Weather.secondary)
        #expect(appearance.accent == .accent)
        #expect(appearance.selection == .Surface.selected)
        #expect(appearance.symbolAccent == .Weather.sun)
        #expect(appearance.highlight == .Wind.strongValue)
    }

    @Test func nightUsesNightCardColors() {
        let appearance = WeatherAppearance.night
        #expect(appearance.card == .Weather.nightCard)
        #expect(appearance.text == .Weather.onNight)
        #expect(appearance.secondaryText == .Weather.nightSecondary)
        #expect(appearance.accent == .Weather.nightAccent)
        #expect(appearance.selection == .Weather.nightCard)
        #expect(appearance.symbolAccent == .Weather.onNight)
        #expect(appearance.highlight == .Weather.nightAccent)
    }

    @Test func defaultsToDay() {
        #expect(EnvironmentValues().weatherAppearance == .day)
    }
}
