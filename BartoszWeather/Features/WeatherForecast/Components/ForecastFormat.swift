import Foundation

nonisolated enum ForecastFormat {
    static let placeholder = "—"
    static let noData = String(localized: "No data")
    static let plausibleTemperatureLimit: Double = 1_000

    static func plausibleTemperature(_ celsius: Double?) -> Double? {
        guard let celsius, celsius.isFinite, abs(celsius) < plausibleTemperatureLimit else { return nil }
        return celsius
    }

    static func temperature(_ celsius: Double?) -> String {
        guard let celsius = plausibleTemperature(celsius) else { return placeholder }
        return "\(Int(celsius.rounded()))°"
    }

    static func percentage(_ value: Int?) -> String {
        guard let value else { return placeholder }
        return "\(min(max(value, 0), 100))%"
    }
}
