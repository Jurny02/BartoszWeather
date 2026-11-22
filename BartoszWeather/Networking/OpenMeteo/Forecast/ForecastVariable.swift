/// The weather variables a forecast request can ask for, named as the Open-Meteo API names them.
nonisolated public enum ForecastVariable {
    /// A variable of the `current` block: conditions now, in 15-minute steps.
    public enum Current: String, CaseIterable, Sendable {
        case temperature = "temperature_2m"
        case apparentTemperature = "apparent_temperature"
        case relativeHumidity = "relative_humidity_2m"
        case isDay = "is_day"
        case weatherCode = "weather_code"
        case cloudCover = "cloud_cover"
        case precipitationProbability = "precipitation_probability"
        case windSpeed = "wind_speed_10m"
        case windGusts = "wind_gusts_10m"
        case windDirection = "wind_direction_10m"
    }

    /// A variable of the `hourly` block: one value per hour.
    public enum Hourly: String, CaseIterable, Sendable {
        case temperature = "temperature_2m"
        case precipitationProbability = "precipitation_probability"
        case weatherCode = "weather_code"
        case isDay = "is_day"
    }

    /// A variable of the `daily` block: one value per local day.
    public enum Daily: String, CaseIterable, Sendable {
        case weatherCode = "weather_code"
        case maxTemperature = "temperature_2m_max"
        case minTemperature = "temperature_2m_min"
        case maxPrecipitationProbability = "precipitation_probability_max"
    }
}
