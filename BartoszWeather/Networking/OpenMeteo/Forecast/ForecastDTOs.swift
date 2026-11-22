/// The body of a successful forecast request. A block is `nil` when none of its variables was requested.
nonisolated public struct ForecastResponseDTO: Decodable, Equatable, Sendable {
    /// The offset of the coordinate's time zone from GMT, a fallback when `timezone` is unknown to the device.
    public let utcOffsetSeconds: Int?
    /// The coordinate's time zone identifier, such as "Europe/Warsaw".
    public let timezone: String?
    public let current: ForecastCurrentDTO?
    public let hourly: ForecastHourlyDTO?
    public let daily: ForecastDailyDTO?

    public init(
        utcOffsetSeconds: Int?, timezone: String?,
        current: ForecastCurrentDTO?, hourly: ForecastHourlyDTO?, daily: ForecastDailyDTO?
    ) {
        self.utcOffsetSeconds = utcOffsetSeconds
        self.timezone = timezone
        self.current = current
        self.hourly = hourly
        self.daily = daily
    }

    /// Maps the API's snake_case field names to Swift names.
    private enum CodingKeys: String, CodingKey {
        case utcOffsetSeconds = "utc_offset_seconds"
        case timezone
        case current
        case hourly
        case daily
    }
}

/// Conditions now. Any value can be `nil`: not requested, or not reported by the weather model.
nonisolated public struct ForecastCurrentDTO: Decodable, Equatable, Sendable {
    /// Unix seconds, on a 15-minute boundary.
    public let time: Int
    public let temperature2m: Double?
    public let apparentTemperature: Double?
    public let relativeHumidity2m: Int?
    /// 1 for day and 0 for night at the coordinate.
    public let isDay: Int?
    /// A WMO weather interpretation code.
    public let weatherCode: Int?
    public let cloudCover: Int?
    public let precipitationProbability: Int?
    public let windSpeed10m: Double?
    public let windGusts10m: Double?
    public let windDirection10m: Double?

    public init(
        time: Int, temperature2m: Double?, apparentTemperature: Double?, relativeHumidity2m: Int?,
        isDay: Int?, weatherCode: Int?, cloudCover: Int?, precipitationProbability: Int?,
        windSpeed10m: Double?, windGusts10m: Double?, windDirection10m: Double?
    ) {
        self.time = time
        self.temperature2m = temperature2m
        self.apparentTemperature = apparentTemperature
        self.relativeHumidity2m = relativeHumidity2m
        self.isDay = isDay
        self.weatherCode = weatherCode
        self.cloudCover = cloudCover
        self.precipitationProbability = precipitationProbability
        self.windSpeed10m = windSpeed10m
        self.windGusts10m = windGusts10m
        self.windDirection10m = windDirection10m
    }

    /// Maps the API's snake_case field names to Swift names.
    private enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case apparentTemperature = "apparent_temperature"
        case relativeHumidity2m = "relative_humidity_2m"
        case isDay = "is_day"
        case weatherCode = "weather_code"
        case cloudCover = "cloud_cover"
        case precipitationProbability = "precipitation_probability"
        case windSpeed10m = "wind_speed_10m"
        case windGusts10m = "wind_gusts_10m"
        case windDirection10m = "wind_direction_10m"
    }
}

/// Hourly values as arrays parallel to `time`. An array is `nil` when not requested
/// and may be shorter than `time`, and any element can be `nil`.
nonisolated public struct ForecastHourlyDTO: Decodable, Equatable, Sendable {
    /// Unix seconds at the start of each hour.
    public let time: [Int]
    public let temperature2m: [Double?]?
    public let precipitationProbability: [Int?]?
    public let weatherCode: [Int?]?
    public let isDay: [Int?]?

    public init(
        time: [Int], temperature2m: [Double?]?, precipitationProbability: [Int?]?,
        weatherCode: [Int?]?, isDay: [Int?]?
    ) {
        self.time = time
        self.temperature2m = temperature2m
        self.precipitationProbability = precipitationProbability
        self.weatherCode = weatherCode
        self.isDay = isDay
    }

    /// Maps the API's snake_case field names to Swift names.
    private enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case precipitationProbability = "precipitation_probability"
        case weatherCode = "weather_code"
        case isDay = "is_day"
    }
}

/// Daily values as arrays parallel to `time`. An array is `nil` when not requested
/// and may be shorter than `time`, and any element can be `nil`.
nonisolated public struct ForecastDailyDTO: Decodable, Equatable, Sendable {
    /// Unix seconds at local midnight of each day in the coordinate's time zone.
    public let time: [Int]
    public let weatherCode: [Int?]?
    public let temperature2mMax: [Double?]?
    public let temperature2mMin: [Double?]?
    public let precipitationProbabilityMax: [Int?]?

    public init(
        time: [Int], weatherCode: [Int?]?, temperature2mMax: [Double?]?, temperature2mMin: [Double?]?,
        precipitationProbabilityMax: [Int?]?
    ) {
        self.time = time
        self.weatherCode = weatherCode
        self.temperature2mMax = temperature2mMax
        self.temperature2mMin = temperature2mMin
        self.precipitationProbabilityMax = precipitationProbabilityMax
    }

    /// Maps the API's snake_case field names to Swift names.
    private enum CodingKeys: String, CodingKey {
        case time
        case weatherCode = "weather_code"
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
        case precipitationProbabilityMax = "precipitation_probability_max"
    }
}
