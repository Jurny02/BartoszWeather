import Foundation

/// Loads forecasts with the Open-Meteo detail preset and maps the response to `Forecast`.
///
/// Values outside their physical range are read as not reported, and a missing day/night flag reads as day.
/// At most 384 hours and 16 days are kept. A response without current conditions or without any time zone
/// fails with `APIError.decoding`.
nonisolated public struct OpenMeteoForecastService: ForecastService {
    private let client: any APIClient
    private let now: @Sendable () -> Date

    /// - Parameter now: The moment a forecast is stamped as updated.
    public init(client: any APIClient, now: @escaping @Sendable () -> Date) {
        self.client = client
        self.now = now
    }

    public func forecast(for city: City) async throws -> Forecast {
        let response = try await client.send(ForecastEndpoint.detail(for: city.coordinate))
        return try Forecast(response: response, updatedAt: now())
    }
}

nonisolated private extension Forecast {
    init(response: ForecastResponseDTO, updatedAt: Date) throws(APIError) {
        guard let current = response.current else {
            throw .decoding(description: "The forecast has no current conditions")
        }
        guard let timeZone = response.timezone.flatMap(TimeZone.init(identifier:))
            ?? response.utcOffsetSeconds.flatMap(TimeZone.init(secondsFromGMT:)) else {
            throw .decoding(description: "The forecast has no time zone")
        }
        self.init(
            current: CurrentWeather(current),
            hourly: response.hourly.map([HourlyForecast].init) ?? [],
            daily: response.daily.map([DailyForecast].init) ?? [],
            timeZone: timeZone,
            updatedAt: updatedAt
        )
    }
}

nonisolated private extension CurrentWeather {
    init(_ current: ForecastCurrentDTO) {
        self.init(
            date: Date(timeIntervalSince1970: TimeInterval(current.time)),
            condition: WeatherCondition(code: current.weatherCode),
            isDay: Self.isDay(current.isDay),
            temperature: current.temperature2m,
            apparentTemperature: current.apparentTemperature,
            humidity: Self.percent(current.relativeHumidity2m),
            cloudCover: Self.percent(current.cloudCover),
            precipitationProbability: Self.percent(current.precipitationProbability),
            wind: Wind(speed: current.windSpeed10m, gusts: current.windGusts10m, direction: current.windDirection10m)
        )
    }
}

nonisolated private extension [HourlyForecast] {
    static let maxCount = 384

    init(_ hourly: ForecastHourlyDTO) {
        self = hourly.time.prefix(Self.maxCount).indices.map { index in
            HourlyForecast(
                date: Date(timeIntervalSince1970: TimeInterval(hourly.time[index])),
                condition: WeatherCondition(code: hourly.weatherCode.element(at: index)),
                isDay: CurrentWeather.isDay(hourly.isDay.element(at: index)),
                temperature: hourly.temperature2m.element(at: index),
                precipitationProbability: CurrentWeather.percent(hourly.precipitationProbability.element(at: index))
            )
        }
    }
}

nonisolated private extension [DailyForecast] {
    static let maxCount = 16

    init(_ daily: ForecastDailyDTO) {
        self = daily.time.prefix(Self.maxCount).indices.map { index in
            DailyForecast(
                date: Date(timeIntervalSince1970: TimeInterval(daily.time[index])),
                condition: WeatherCondition(code: daily.weatherCode.element(at: index)),
                minTemperature: daily.temperature2mMin.element(at: index),
                maxTemperature: daily.temperature2mMax.element(at: index),
                precipitationProbability: CurrentWeather.percent(daily.precipitationProbabilityMax.element(at: index))
            )
        }
    }
}

nonisolated private extension CurrentWeather {
    static func isDay(_ value: Int?) -> Bool {
        value != 0
    }

    static func percent(_ value: Int?) -> Int? {
        value.flatMap { (0...100).contains($0) ? $0 : nil }
    }
}

nonisolated private extension WeatherCondition {
    init(code: Int?) {
        self = code.map(WeatherCondition.init(wmoCode:)) ?? .unknown
    }
}

nonisolated private extension Wind {
    init?(speed: Double?, gusts: Double?, direction: Double?) {
        guard let speed, speed >= 0 else { return nil }
        self.init(
            speed: speed,
            gusts: gusts.flatMap { $0 >= 0 ? $0 : nil },
            direction: direction.flatMap { (0...360).contains($0) ? $0 : nil }
        )
    }
}

nonisolated private extension Optional {
    func element<Value>(at index: Int) -> Value? where Wrapped == [Value?] {
        guard let array = self, array.indices.contains(index) else { return nil }
        return array[index]
    }
}
