import Testing
@testable import BartoszWeather

struct WeatherAppearanceTests {
    @Test func daylightGivesTheDayAppearance() {
        #expect(WeatherAppearance(isDay: true) == .day)
        #expect(WeatherAppearance(isDay: false) == .night)
    }

    @Test func dayUsesLightCardsAndDarkText() {
        #expect(WeatherAppearance.day.card == .Weather.card)
        #expect(WeatherAppearance.day.text == .Weather.text)
        #expect(WeatherAppearance.day.secondaryText == .Weather.secondary)
        #expect(WeatherAppearance.day.accent == .accent)
        #expect(WeatherAppearance.day.selection == .Surface.selected)
        #expect(WeatherAppearance.day.symbolAccent == .Weather.sun)
        #expect(WeatherAppearance.day.highlight == .Wind.strongValue)
        #expect(WeatherAppearance.day.badgeText == .Wind.badgeText)
    }

    @Test func nightUsesNightCardsAndLightText() {
        #expect(WeatherAppearance.night.card == .Weather.nightCard)
        #expect(WeatherAppearance.night.text == .Weather.onNight)
        #expect(WeatherAppearance.night.secondaryText == .Weather.nightSecondary)
        #expect(WeatherAppearance.night.accent == .Weather.nightAccent)
        #expect(WeatherAppearance.night.selection == .Weather.nightCard)
        #expect(WeatherAppearance.night.symbolAccent == .Weather.onNight)
        #expect(WeatherAppearance.night.highlight == .Weather.nightAccent)
        #expect(WeatherAppearance.night.badgeText == .Weather.onNight)
    }
}
