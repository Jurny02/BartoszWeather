import Foundation

/// Asks Open-Meteo for the weather at one coordinate: the chosen current, hourly and daily variables.
///
/// Times come back as Unix seconds, with hours and days starting on the coordinate's local boundaries;
/// the response's `timezone` and `utcOffsetSeconds` give the zone for display.
/// Temperatures are in degrees Celsius and wind speeds in kilometers per hour.
nonisolated public struct ForecastEndpoint: OpenMeteoEndpoint {
    public typealias Response = ForecastResponseDTO

    public let coordinate: Coordinate
    public let current: [ForecastVariable.Current]
    public let hourly: [ForecastVariable.Hourly]
    public let daily: [ForecastVariable.Daily]
    /// Hourly steps counted from the current hour; `nil` lets the server choose.
    public let forecastHours: Int?
    /// Days counted from today, 0–16; `nil` lets the server choose. The server answers 400 outside that range.
    public let forecastDays: Int?

    public init(
        coordinate: Coordinate,
        current: [ForecastVariable.Current],
        hourly: [ForecastVariable.Hourly],
        daily: [ForecastVariable.Daily],
        forecastHours: Int?,
        forecastDays: Int?
    ) {
        self.coordinate = coordinate
        self.current = current
        self.hourly = hourly
        self.daily = daily
        self.forecastHours = forecastHours
        self.forecastDays = forecastDays
    }

    /// Everything the forecast screen shows: current conditions, the next 24 hours and the next 7 days.
    public static func detail(for coordinate: Coordinate) -> ForecastEndpoint {
        ForecastEndpoint(
            coordinate: coordinate,
            current: ForecastVariable.Current.allCases,
            hourly: ForecastVariable.Hourly.allCases,
            daily: ForecastVariable.Daily.allCases,
            forecastHours: 24,
            forecastDays: 7
        )
    }

    public var baseURL: URL { URL(string: "https://api.open-meteo.com")! }
    public var path: String { "/v1/forecast" }

    public var queryItems: [URLQueryItem] {
        var items = [
            URLQueryItem(name: "latitude", value: String(coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(coordinate.longitude)),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "timeformat", value: "unixtime"),
            URLQueryItem(name: "temperature_unit", value: "celsius"),
            URLQueryItem(name: "wind_speed_unit", value: "kmh"),
        ]
        items.append(variables: current.map(\.rawValue), named: "current")
        items.append(variables: hourly.map(\.rawValue), named: "hourly")
        items.append(count: forecastHours, named: "forecast_hours")
        items.append(variables: daily.map(\.rawValue), named: "daily")
        items.append(count: forecastDays, named: "forecast_days")
        return items
    }
}

nonisolated private extension [URLQueryItem] {
    mutating func append(variables: [String], named name: String) {
        guard !variables.isEmpty else { return }
        append(URLQueryItem(name: name, value: variables.joined(separator: ",")))
    }

    mutating func append(count: Int?, named name: String) {
        guard let count else { return }
        append(URLQueryItem(name: name, value: String(count)))
    }
}
