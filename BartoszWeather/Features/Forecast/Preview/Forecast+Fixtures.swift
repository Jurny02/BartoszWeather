#if DEBUG
import Foundation

extension City {
    /// Fixture city for previews.
    static let krakow = City(
        id: 3_094_802, name: "Kraków", region: "Małopolskie", district: nil, country: "Poland",
        coordinate: Coordinate(latitude: 50.06, longitude: 19.94)
    )

    /// Fixture city for previews.
    static let zakopane = City(
        id: 3_080_165, name: "Zakopane", region: "Małopolskie", district: nil, country: "Poland",
        coordinate: Coordinate(latitude: 49.30, longitude: 19.95)
    )

    /// Fixture city for previews.
    static let hel = City(
        id: 3_099_539, name: "Hel", region: "Pomorskie", district: nil, country: "Poland",
        coordinate: Coordinate(latitude: 54.61, longitude: 18.80)
    )
}

/// Builds deterministic forecasts for previews: fixed local start times in the Europe/Warsaw time zone.
private struct ForecastFixture {
    static let timeZone = TimeZone(identifier: "Europe/Warsaw")!

    let start: Date
    let isDayHours: Range<Int>

    init(year: Int, month: Int, day: Int, hour: Int, isDayHours: Range<Int>) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = Self.timeZone
        start = calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
        self.isDayHours = isDayHours
    }

    var updatedAt: Date {
        start.addingTimeInterval(5 * 60)
    }

    func hourly(
        temperatures: [Double?], conditions: [WeatherCondition], precipitation: [Int?]
    ) -> [HourlyForecast] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = Self.timeZone
        return temperatures.indices.map { index in
            let date = start.addingTimeInterval(TimeInterval(index) * 3600)
            return HourlyForecast(
                date: date,
                condition: conditions[index % conditions.count],
                isDay: isDayHours.contains(calendar.component(.hour, from: date)),
                temperature: temperatures[index],
                precipitationProbability: precipitation[index % precipitation.count]
            )
        }
    }

    func daily(_ days: [(WeatherCondition, Double?, Double?, Int?)]) -> [DailyForecast] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = Self.timeZone
        let midnight = calendar.startOfDay(for: start)
        return days.enumerated().map { index, day in
            DailyForecast(
                date: calendar.date(byAdding: .day, value: index, to: midnight)!,
                condition: day.0, minTemperature: day.1, maxTemperature: day.2, precipitationProbability: day.3
            )
        }
    }
}

private let krakowFixture = ForecastFixture(year: 2026, month: 7, day: 15, hour: 14, isDayHours: 5..<21)
private let zakopaneFixture = ForecastFixture(year: 2027, month: 1, day: 15, hour: 23, isDayHours: 8..<16)
private let helFixture = ForecastFixture(year: 2026, month: 10, day: 20, hour: 14, isDayHours: 7..<18)

extension Forecast {
    /// The moment `krakowDay` and `partialData` treat as "now".
    static let krakowNow = krakowFixture.start

    /// The moment `zakopaneNight` treats as "now".
    static let zakopaneNow = zakopaneFixture.start

    /// The moment `helStrongWind` treats as "now".
    static let helNow = helFixture.start

    /// Clear summer afternoon, matching the Figma day screen.
    static let krakowDay = Forecast(
        current: CurrentWeather(
            date: krakowFixture.start, condition: .clearSky, isDay: true, temperature: 24, apparentTemperature: 25,
            humidity: 40, cloudCover: 0, precipitationProbability: 0,
            wind: Wind(speed: 8, gusts: 18, direction: 315)
        ),
        hourly: krakowFixture.hourly(
            temperatures: [24, 25, 25, 24, 23, 22, 20, 18, 17, 16, 15, 14, 14, 14, 15, 16, 17, 19, 21, 22, 23, 24, 25, 25],
            conditions: [.clearSky, .clearSky, .partlyCloudy, .partlyCloudy, .rainShowers, .rain, .rain, .overcast],
            precipitation: [0, 0, 5, 10, 30, 60, 40, 10]
        ),
        daily: krakowFixture.daily([
            (.clearSky, 14, 26, 0),
            (.partlyCloudy, 15, 27, 10),
            (.rain, 13, 21, 60),
            (.rainShowers, 12, 19, 40),
            (.partlyCloudy, 11, 22, 10),
            (.clearSky, 10, 24, 0),
            (.mainlyClear, 12, 25, 0),
        ]),
        timeZone: ForecastFixture.timeZone,
        updatedAt: krakowFixture.updatedAt
    )

    /// Freezing clear night, matching the Figma night screen.
    static let zakopaneNight = Forecast(
        current: CurrentWeather(
            date: zakopaneFixture.start, condition: .clearSky, isDay: false, temperature: -12,
            apparentTemperature: -17, humidity: 75, cloudCover: 0, precipitationProbability: 0,
            wind: Wind(speed: 6, gusts: 12, direction: 315)
        ),
        hourly: zakopaneFixture.hourly(
            temperatures: [-12, -13, -13, -14, -14, -15, -15, -14, -12, -10, -8, -7, -6, -6, -7, -9, -10, -11, -12, -12, -13, -13, -14, -14],
            conditions: [.clearSky, .clearSky, .mainlyClear, .partlyCloudy, .snowShowers, .snow],
            precipitation: [0, 0, 0, 5, 30, 50]
        ),
        daily: zakopaneFixture.daily([
            (.clearSky, -15, -6, 0),
            (.snow, -12, -5, 70),
            (.snowShowers, -13, -7, 40),
            (.partlyCloudy, -16, -8, 10),
            (.clearSky, -18, -9, 0),
            (.overcast, -14, -4, 20),
            (.snow, -10, -2, 60),
        ]),
        timeZone: ForecastFixture.timeZone,
        updatedAt: zakopaneFixture.updatedAt
    )

    /// Rainy autumn day with a strong wind, matching the Figma Hel screen.
    static let helStrongWind = Forecast(
        current: CurrentWeather(
            date: helFixture.start, condition: .overcast, isDay: true, temperature: 7, apparentTemperature: 1,
            humidity: 85, cloudCover: 100, precipitationProbability: 30,
            wind: Wind(speed: 52, gusts: 78, direction: 315)
        ),
        hourly: helFixture.hourly(
            temperatures: [7, 7, 6, 6, 6, 5, 5, 5, 4, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 7, 7, 6, 6, 6],
            conditions: [.overcast, .rain, .rain, .heavyRain, .rainShowers, .overcast],
            precipitation: [30, 50, 60, 70, 40, 10]
        ),
        daily: helFixture.daily([
            (.rain, 4, 8, 60),
            (.overcast, 3, 7, 20),
            (.rainShowers, 4, 9, 50),
            (.partlyCloudy, 3, 10, 10),
            (.overcast, 5, 10, 10),
            (.rain, 6, 11, 60),
            (.thunderstorm, 7, 12, 80),
        ]),
        timeZone: ForecastFixture.timeZone,
        updatedAt: helFixture.updatedAt
    )

    /// A forecast in which the source left out many values.
    static let partialData = Forecast(
        current: CurrentWeather(
            date: krakowFixture.start, condition: .partlyCloudy, isDay: true, temperature: nil,
            apparentTemperature: nil, humidity: nil, cloudCover: 40, precipitationProbability: nil,
            wind: Wind(speed: 5, gusts: nil, direction: nil)
        ),
        hourly: krakowFixture.hourly(
            temperatures: [nil, 22, nil, 21, 20, nil, 18, 17, nil, 15, 14, 14],
            conditions: [.partlyCloudy, .unknown, .overcast],
            precipitation: [nil, 0, 20, nil]
        ),
        daily: krakowFixture.daily([
            (.partlyCloudy, nil, nil, nil),
            (.unknown, 12, nil, 10),
            (.rain, nil, 20, nil),
            (.clearSky, 10, 24, 0),
        ]),
        timeZone: ForecastFixture.timeZone,
        updatedAt: krakowFixture.updatedAt
    )
}
#endif
