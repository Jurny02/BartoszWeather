import Foundation
import Testing
@testable import BartoszWeather

/// Tests the texts, symbols, colors and VoiceOver label derived from a history entry.
struct SearchHistoryEntryPresentationTests {
    private let city = City(
        id: 3_094_802, name: "Kraków", region: "Małopolskie", district: nil, country: "Poland",
        coordinate: Coordinate(latitude: 50.06, longitude: 19.94)
    )
    private let date = Date(timeIntervalSince1970: 1_784_117_100)

    private func entry(
        condition: WeatherCondition = .clearSky,
        isDay: Bool = true,
        temperature: Double? = 24,
        wind: Wind? = nil,
        low: Double? = 14,
        high: Double? = 26,
        hasDays: Bool = true
    ) -> SearchHistoryEntry {
        let current = CurrentWeather(
            date: date, condition: condition, isDay: isDay, temperature: temperature, apparentTemperature: 25,
            humidity: 40, cloudCover: 0, precipitationProbability: 0, wind: wind
        )
        let today = DailyForecast(
            date: date, condition: condition, minTemperature: low, maxTemperature: high, precipitationProbability: 0
        )
        let forecast = Forecast(
            current: current, hourly: [], daily: hasDays ? [today] : [], timeZone: .gmt, updatedAt: date
        )
        return SearchHistoryEntry(city: city, forecast: forecast)
    }

    private let strongWind = Wind(speed: 52, gusts: 78, direction: nil)

    @Test func isIdentifiedByItsCity() {
        #expect(entry().id == city.id)
    }

    @Test func formatsTheCurrentTemperature() {
        #expect(entry(temperature: 24.2).temperatureText == "24°")
        #expect(entry(temperature: -12).temperatureText == "−12°")
        #expect(entry(temperature: nil).temperatureText == "—")
    }

    @Test func describesTheCondition() {
        #expect(entry().conditionText == "Clear sky")
    }

    @Test func putsStrongWindBeforeTheCondition() {
        #expect(entry(condition: .overcast, wind: strongWind).conditionText == "Strong wind · Overcast")
    }

    @Test func showsTodaysRange() {
        #expect(entry().rangeText == "14° – 26°")
        #expect(entry(low: -14, high: -3).rangeText == "−14° – −3°")
    }

    @Test func showsDashesForAMissingRange() {
        #expect(entry(low: nil, high: 26).rangeText == "— – 26°")
        #expect(entry(hasDays: false).rangeText == "— – —")
    }

    @Test func usesTheConditionSymbolForTheCitysTimeOfDay() {
        #expect(entry(isDay: true).icon == .sunMaxFill)
        #expect(entry(isDay: false).icon == .moonStarsFill)
    }

    @Test func usesTheWindSymbolForStrongWind() {
        #expect(entry(condition: .overcast, wind: strongWind).icon == .wind)
    }

    @Test func followsDayAndNightAtTheCity() {
        #expect(entry(isDay: true).appearance == .day)
        #expect(entry(isDay: false).appearance == .night)
    }

    @Test func picksTheSkyFromTheCondition() {
        #expect(entry(condition: .clearSky).sky == .clear)
        #expect(entry(condition: .overcast).sky == .overcast)
    }

    @Test func readsTheWholeCard() {
        #expect(
            entry().accessibilityLabel
                == "Kraków, Małopolskie, Poland. 24 degrees. Clear sky. Low 14 degrees, high 26 degrees."
        )
    }

    @Test func readsStrongWindAndBelowZeroTemperatures() {
        #expect(
            entry(condition: .overcast, temperature: -12, wind: strongWind, low: -14, high: -3).accessibilityLabel
                == "Kraków, Małopolskie, Poland. minus 12 degrees. Strong wind. Overcast. "
                + "Low minus 14 degrees, high minus 3 degrees."
        )
    }

    @Test func readsMissingValuesAsNoData() {
        #expect(
            entry(temperature: nil, hasDays: false).accessibilityLabel
                == "Kraków, Małopolskie, Poland. No data. Clear sky. Low No data, high No data."
        )
    }

    @Test func showsDashesWithoutAForecast() {
        let entry = SearchHistoryEntry(city: city, forecast: nil)
        #expect(entry.temperatureText == "—")
        #expect(entry.conditionText == "No data")
        #expect(entry.rangeText == "— – —")
    }

    @Test func usesTheUnknownConditionLookWithoutAForecast() {
        let entry = SearchHistoryEntry(city: city, forecast: nil)
        #expect(entry.icon == .exclamationmarkIcloud)
        #expect(entry.appearance == .day)
        #expect(entry.sky == .overcast)
    }

    @Test func readsOnlyTheCityWithoutAForecast() {
        #expect(
            SearchHistoryEntry(city: city, forecast: nil).accessibilityLabel
                == "Kraków, Małopolskie, Poland. No data."
        )
    }
}
