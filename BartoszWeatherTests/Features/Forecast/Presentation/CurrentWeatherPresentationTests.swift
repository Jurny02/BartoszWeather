import Foundation
import Testing
@testable import BartoszWeather

struct CurrentWeatherPresentationTests {
    private let city = City(
        id: 3_094_802, name: "Kraków", region: "Małopolskie", district: nil, country: "Poland",
        coordinate: Coordinate(latitude: 50.06, longitude: 19.94)
    )

    private func current(
        temperature: Double? = 24, apparent: Double? = 25, wind: Wind? = nil
    ) -> CurrentWeather {
        CurrentWeather(
            date: Date(timeIntervalSince1970: 1_784_117_100), condition: .clearSky, isDay: true,
            temperature: temperature, apparentTemperature: apparent, humidity: 40, cloudCover: 0,
            precipitationProbability: 0, wind: wind
        )
    }

    @Test func formatsTemperature() {
        #expect(current(temperature: 24.2).temperatureText == "24°")
        #expect(current(temperature: nil).temperatureText == "—")
    }

    @Test func describesTheApparentTemperature() {
        #expect(current(apparent: 25).feelsLikeText == "Feels like 25°")
        #expect(current(apparent: nil).feelsLikeText == "Feels like —")
    }

    @Test func showsTheBadgeOnlyForStrongWind() {
        #expect(current(wind: Wind(speed: 52, gusts: 78, direction: nil)).showsStrongWindBadge)
        #expect(!current(wind: Wind(speed: 8, gusts: 20, direction: nil)).showsStrongWindBadge)
        #expect(!current(wind: nil).showsStrongWindBadge)
    }

    @Test func readsTheWholeHeader() {
        #expect(
            current().accessibilityLabel(city: city)
                == "Kraków, Małopolskie, Poland. 24 degrees, Clear sky. Feels like 25 degrees."
        )
    }

    @Test func readsBelowZeroTemperaturesInWords() {
        #expect(
            current(temperature: -12, apparent: -17).accessibilityLabel(city: city)
                == "Kraków, Małopolskie, Poland. minus 12 degrees, Clear sky. Feels like minus 17 degrees."
        )
    }

    @Test func readsMissingValuesAsNoData() {
        #expect(
            current(temperature: nil, apparent: nil).accessibilityLabel(city: city)
                == "Kraków, Małopolskie, Poland. No data, Clear sky. Feels like No data."
        )
    }

    @Test func mentionsStrongWind() {
        let label = current(wind: Wind(speed: 52, gusts: 78, direction: nil)).accessibilityLabel(city: city)

        #expect(label.hasSuffix("Strong wind."))
    }

    @Test func leavesOutMissingRegionAndCountry() {
        let bare = City(id: 1, name: "Hel", region: nil, district: nil, country: " ", coordinate: city.coordinate)

        #expect(current().accessibilityLabel(city: bare).hasPrefix("Hel. 24 degrees"))
    }
}
