import Foundation

/// Why stored forecast data cannot be read back.
nonisolated enum StoredForecastError: Error, Equatable {
    /// The data was written in a format version this build does not read.
    case unsupportedVersion(Int)
    /// Neither the time zone identifier nor the UTC offset gives a valid time zone.
    case invalidTimeZone
}

/// The versioned JSON form in which a `Forecast` is kept on disk.
///
/// Weather conditions are stored under fixed keys, so renaming a `WeatherCondition` case does not break saved data;
/// an unknown key reads as `.unknown`. The time zone is stored by identifier, with its UTC offset as a fallback.
nonisolated struct StoredForecast: Codable, Equatable {
    static let currentVersion = 1

    let version: Int
    let current: StoredCurrentWeather
    let hourly: [StoredHourlyForecast]
    let daily: [StoredDailyForecast]
    let timeZoneIdentifier: String
    let secondsFromGMT: Int
    let updatedAt: Date

    init(_ forecast: Forecast) {
        version = Self.currentVersion
        current = StoredCurrentWeather(forecast.current)
        hourly = forecast.hourly.map(StoredHourlyForecast.init)
        daily = forecast.daily.map(StoredDailyForecast.init)
        timeZoneIdentifier = forecast.timeZone.identifier
        secondsFromGMT = forecast.timeZone.secondsFromGMT(for: forecast.updatedAt)
        updatedAt = forecast.updatedAt
    }

    /// Reads stored data.
    ///
    /// Throws `StoredForecastError.unsupportedVersion` for data of another format version,
    /// and a `DecodingError` for data that is not a stored forecast.
    static func decode(_ data: Data) throws -> StoredForecast {
        let decoder = JSONDecoder()
        let header = try decoder.decode(VersionHeader.self, from: data)
        guard header.version == currentVersion else {
            throw StoredForecastError.unsupportedVersion(header.version)
        }
        return try decoder.decode(StoredForecast.self, from: data)
    }

    func encoded() throws -> Data {
        try JSONEncoder().encode(self)
    }

    /// The domain forecast. Throws `StoredForecastError.invalidTimeZone` when no time zone can be restored.
    func forecast() throws(StoredForecastError) -> Forecast {
        guard let timeZone = TimeZone(identifier: timeZoneIdentifier) ?? TimeZone(secondsFromGMT: secondsFromGMT) else {
            throw .invalidTimeZone
        }
        return Forecast(
            current: current.currentWeather,
            hourly: hourly.map(\.hourlyForecast),
            daily: daily.map(\.dailyForecast),
            timeZone: timeZone,
            updatedAt: updatedAt
        )
    }

    private struct VersionHeader: Decodable {
        let version: Int
    }
}

/// The stored form of `CurrentWeather`.
nonisolated struct StoredCurrentWeather: Codable, Equatable {
    let date: Date
    let condition: String
    let isDay: Bool
    let temperature: Double?
    let apparentTemperature: Double?
    let humidity: Int?
    let cloudCover: Int?
    let precipitationProbability: Int?
    let windSpeed: Double?
    let windGusts: Double?
    let windDirection: Double?

    init(_ weather: CurrentWeather) {
        date = weather.date
        condition = weather.condition.storageKey
        isDay = weather.isDay
        temperature = weather.temperature
        apparentTemperature = weather.apparentTemperature
        humidity = weather.humidity
        cloudCover = weather.cloudCover
        precipitationProbability = weather.precipitationProbability
        windSpeed = weather.wind?.speed
        windGusts = weather.wind?.gusts
        windDirection = weather.wind?.direction
    }

    var currentWeather: CurrentWeather {
        CurrentWeather(
            date: date,
            condition: WeatherCondition(storageKey: condition),
            isDay: isDay,
            temperature: temperature,
            apparentTemperature: apparentTemperature,
            humidity: humidity,
            cloudCover: cloudCover,
            precipitationProbability: precipitationProbability,
            wind: windSpeed.map { Wind(speed: $0, gusts: windGusts, direction: windDirection) }
        )
    }
}

/// The stored form of `HourlyForecast`.
nonisolated struct StoredHourlyForecast: Codable, Equatable {
    let date: Date
    let condition: String
    let isDay: Bool
    let temperature: Double?
    let precipitationProbability: Int?

    init(_ hour: HourlyForecast) {
        date = hour.date
        condition = hour.condition.storageKey
        isDay = hour.isDay
        temperature = hour.temperature
        precipitationProbability = hour.precipitationProbability
    }

    var hourlyForecast: HourlyForecast {
        HourlyForecast(
            date: date,
            condition: WeatherCondition(storageKey: condition),
            isDay: isDay,
            temperature: temperature,
            precipitationProbability: precipitationProbability
        )
    }
}

/// The stored form of `DailyForecast`.
nonisolated struct StoredDailyForecast: Codable, Equatable {
    let date: Date
    let condition: String
    let minTemperature: Double?
    let maxTemperature: Double?
    let precipitationProbability: Int?

    init(_ day: DailyForecast) {
        date = day.date
        condition = day.condition.storageKey
        minTemperature = day.minTemperature
        maxTemperature = day.maxTemperature
        precipitationProbability = day.precipitationProbability
    }

    var dailyForecast: DailyForecast {
        DailyForecast(
            date: date,
            condition: WeatherCondition(storageKey: condition),
            minTemperature: minTemperature,
            maxTemperature: maxTemperature,
            precipitationProbability: precipitationProbability
        )
    }
}

nonisolated private extension WeatherCondition {
    /// The fixed key under which the condition is stored. Never change an existing key: saved data uses it.
    var storageKey: String {
        switch self {
        case .clearSky: "clearSky"
        case .mainlyClear: "mainlyClear"
        case .partlyCloudy: "partlyCloudy"
        case .overcast: "overcast"
        case .fog: "fog"
        case .drizzle: "drizzle"
        case .freezingDrizzle: "freezingDrizzle"
        case .rain: "rain"
        case .heavyRain: "heavyRain"
        case .freezingRain: "freezingRain"
        case .snow: "snow"
        case .snowGrains: "snowGrains"
        case .rainShowers: "rainShowers"
        case .snowShowers: "snowShowers"
        case .thunderstorm: "thunderstorm"
        case .thunderstormWithHail: "thunderstormWithHail"
        case .unknown: "unknown"
        }
    }

    init(storageKey: String) {
        self = switch storageKey {
        case "clearSky": .clearSky
        case "mainlyClear": .mainlyClear
        case "partlyCloudy": .partlyCloudy
        case "overcast": .overcast
        case "fog": .fog
        case "drizzle": .drizzle
        case "freezingDrizzle": .freezingDrizzle
        case "rain": .rain
        case "heavyRain": .heavyRain
        case "freezingRain": .freezingRain
        case "snow": .snow
        case "snowGrains": .snowGrains
        case "rainShowers": .rainShowers
        case "snowShowers": .snowShowers
        case "thunderstorm": .thunderstorm
        case "thunderstormWithHail": .thunderstormWithHail
        default: .unknown
        }
    }
}
