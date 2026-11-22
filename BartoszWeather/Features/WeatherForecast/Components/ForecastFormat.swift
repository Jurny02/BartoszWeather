import Foundation

nonisolated enum ForecastFormat {
    static let placeholder = "—"
    static let noData = String(localized: "No data")

    static func temperature(_ celsius: Double?) -> String {
        guard let celsius else { return placeholder }
        return "\(Int(celsius.rounded()))°"
    }

    static func percentage(_ value: Int?) -> String {
        guard let value else { return placeholder }
        return "\(value)%"
    }
}
