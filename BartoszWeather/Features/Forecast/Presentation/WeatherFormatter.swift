import Foundation

/// Turns weather values into the short texts shown on the forecast screen, and into the sentences VoiceOver reads.
///
/// Values that do not depend on place are static; times and weekdays are shown in `timeZone`.
nonisolated public struct WeatherFormatter: Sendable {
    /// Shown instead of a value the forecast source did not report.
    public static let missingValue = "—"

    /// Captions and VoiceOver use this text instead of a value the forecast source did not report.
    public static var noData: String {
        String(localized: "No data")
    }

    public let timeZone: TimeZone
    public let locale: Locale

    public init(timeZone: TimeZone, locale: Locale = .current) {
        self.timeZone = timeZone
        self.locale = locale
    }

    /// Whole degrees with a degree sign and a typographic minus sign (U+2212), such as "14°" or "−12°".
    public static func temperature(_ value: Double?) -> String {
        guard let value else { return missingValue }
        let degrees = Int(value.rounded())
        return degrees < 0 ? "−\(-degrees)°" : "\(degrees)°"
    }

    /// A number of hours such as "24 hours" or "1 hour".
    public static func hourCount(_ count: Int) -> String {
        count == 1 ? String(localized: "1 hour") : String(localized: "\(count) hours")
    }

    /// A percentage such as "30%".
    public static func percent(_ value: Int?) -> String {
        guard let value else { return missingValue }
        return "\(value)%"
    }

    /// A speed in whole kilometers per hour, such as "8 km/h".
    public static func speed(_ value: Double?) -> String {
        guard let value else { return missingValue }
        return "\(Int(value.rounded())) km/h"
    }

    /// A temperature as VoiceOver should read it, such as "24 degrees" or "minus 12 degrees".
    public static func spokenTemperature(_ value: Double?) -> String {
        guard let value else { return noData }
        let degrees = Int(value.rounded())
        let unit = abs(degrees) == 1 ? String(localized: "degree") : String(localized: "degrees")
        let sign = degrees < 0 ? String(localized: "minus") + " " : ""
        return "\(sign)\(abs(degrees)) \(unit)"
    }

    /// The hour on a 24-hour clock in the city's time zone, such as "15:00".
    public func hour(_ date: Date) -> String {
        format(date, pattern: "HH:mm")
    }

    /// The day name in the city's time zone: "Today" when `date` falls on the same day as `now`, otherwise "Wed".
    public func dayName(_ date: Date, now: Date) -> String {
        calendar.isDate(date, inSameDayAs: now) ? String(localized: "Today") : format(date, pattern: "EEE")
    }

    /// The time of the last update, such as "Updated 14:05".
    public func updated(_ date: Date) -> String {
        String(localized: "Updated \(hour(date))")
    }

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        calendar.locale = locale
        return calendar
    }

    private func format(_ date: Date, pattern: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.dateFormat = pattern
        return formatter.string(from: date)
    }
}
