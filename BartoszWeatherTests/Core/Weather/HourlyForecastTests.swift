import Foundation
import Testing
@testable import BartoszWeather

struct HourlyForecastTests {
    @Test(arguments: [(-1.0, false), (0, true), (1_800, true), (3_599, true), (3_600, false)])
    func containsOnlyMomentsWithinItsHour(offset: TimeInterval, expected: Bool) {
        let hour = HourlyForecast(
            date: Date(timeIntervalSince1970: 1_784_117_100), condition: .clearSky, isDay: true,
            temperature: 24, precipitationProbability: 30
        )

        #expect(hour.contains(hour.date.addingTimeInterval(offset)) == expected)
    }
}
