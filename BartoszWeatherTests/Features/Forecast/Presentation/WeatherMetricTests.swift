import Foundation
import Testing
@testable import BartoszWeather

struct WeatherMetricTests {
    private func current(
        cloudCover: Int? = 0, precipitation: Int? = 0, humidity: Int? = 40, wind: Wind? = nil
    ) -> CurrentWeather {
        CurrentWeather(
            date: Date(timeIntervalSince1970: 1_784_117_100), condition: .clearSky, isDay: true, temperature: 24,
            apparentTemperature: 25, humidity: humidity, cloudCover: cloudCover,
            precipitationProbability: precipitation, wind: wind
        )
    }

    @Test func buildsTheFourTilesInOrder() {
        let wind = Wind(speed: 8, gusts: 20, direction: 315)

        let metrics = WeatherMetric.metrics(for: current(cloudCover: 10, precipitation: 20, humidity: 30, wind: wind))

        #expect(metrics == [.cloudCover(10), .precipitation(20), .wind(wind), .humidity(30)])
    }

    @Test func hasDistinctIdentifiers() {
        let ids = WeatherMetric.metrics(for: current()).map(\.id)

        #expect(Set(ids).count == 4)
    }

    @Test func usesTheTileIcons() {
        #expect(WeatherMetric.cloudCover(0).icon == .cloudFill)
        #expect(WeatherMetric.precipitation(0).icon == .dropFill)
        #expect(WeatherMetric.wind(nil).icon == .wind)
        #expect(WeatherMetric.humidity(0).icon == .humidityFill)
    }

    @Test func usesTheTileTitles() {
        #expect(WeatherMetric.cloudCover(0).title == "Cloud cover")
        #expect(WeatherMetric.precipitation(0).title == "Chance of rain")
        #expect(WeatherMetric.wind(nil).title == "Wind")
        #expect(WeatherMetric.humidity(0).title == "Humidity")
    }

    @Test func formatsValues() {
        #expect(WeatherMetric.cloudCover(0).value == "0%")
        #expect(WeatherMetric.precipitation(30).value == "30%")
        #expect(WeatherMetric.wind(Wind(speed: 7.6, gusts: nil, direction: nil)).value == "8 km/h")
        #expect(WeatherMetric.humidity(40).value == "40%")
    }

    @Test(arguments: [
        (0, "Clear sky"), (10, "Clear sky"), (11, "Partly cloudy"), (50, "Partly cloudy"),
        (51, "Mostly cloudy"), (85, "Mostly cloudy"), (86, "Overcast"), (100, "Overcast"),
    ])
    func describesCloudCover(percent: Int, expected: String) {
        #expect(WeatherMetric.cloudCover(percent).caption == expected)
    }

    @Test func captionsTheOtherTiles() {
        #expect(WeatherMetric.precipitation(30).caption == "Next hour")
        #expect(WeatherMetric.humidity(40).caption == "Relative humidity")
        #expect(WeatherMetric.wind(Wind(speed: 8, gusts: 78, direction: nil)).caption == "Gusts 78 km/h")
        #expect(WeatherMetric.wind(Wind(speed: 8, gusts: nil, direction: nil)).caption == "Gusts —")
    }

    @Test func showsDashAndNoDataForMissingValues() {
        let missing: [WeatherMetric] = [.cloudCover(nil), .precipitation(nil), .wind(nil), .humidity(nil)]

        #expect(missing.allSatisfy { $0.value == "—" && $0.caption == "No data" })
    }

    @Test func showsTheWindDirectionOnlyForWindWithABearing() {
        #expect(WeatherMetric.wind(Wind(speed: 8, gusts: nil, direction: 315)).direction == .northWest)
        #expect(WeatherMetric.wind(Wind(speed: 8, gusts: nil, direction: nil)).direction == nil)
        #expect(WeatherMetric.wind(nil).direction == nil)
        #expect(WeatherMetric.humidity(40).direction == nil)
    }

    @Test func highlightsOnlyStrongWind() {
        #expect(WeatherMetric.wind(Wind(speed: 52, gusts: 78, direction: nil)).isHighlighted)
        #expect(!WeatherMetric.wind(Wind(speed: 8, gusts: 20, direction: nil)).isHighlighted)
        #expect(!WeatherMetric.wind(nil).isHighlighted)
        #expect(!WeatherMetric.cloudCover(100).isHighlighted)
    }

    @Test func readsAWindTileWithDirectionAndGusts() {
        let wind = WeatherMetric.wind(Wind(speed: 8, gusts: 20, direction: 315))

        #expect(wind.accessibilityLabel == "Wind, 8 km/h, from northwest, Gusts 20 km/h")
    }

    @Test func readsStrongWindAsStrong() {
        let wind = WeatherMetric.wind(Wind(speed: 52, gusts: 78, direction: nil))

        #expect(wind.accessibilityLabel == "Wind, 52 km/h, Gusts 78 km/h, strong wind")
    }

    @Test func readsOtherTilesAsTitleValueAndCaption() {
        #expect(WeatherMetric.humidity(40).accessibilityLabel == "Humidity, 40%, Relative humidity")
        #expect(WeatherMetric.cloudCover(nil).accessibilityLabel == "Cloud cover, —, No data")
    }
}
