/// Where a day's temperature span sits within the span shared by all days, as fractions from 0 to 1 of the bar width.
nonisolated public struct TemperatureRangeSegment: Equatable, Sendable {
    public let start: Double
    public let end: Double

    /// How much of the bar the segment covers, from 0 to 1.
    public var length: Double {
        end - start
    }

    /// Creates the segment for a day, or `nil` when the day or the shared range lacks a temperature.
    ///
    /// A shared range of a single temperature fills the whole bar.
    public init?(low: Double?, high: Double?, within range: ClosedRange<Double>?) {
        guard let low, let high, let range else { return nil }
        let span = range.upperBound - range.lowerBound
        guard span > 0 else {
            start = 0
            end = 1
            return
        }
        let first = Self.fraction(min(low, high), in: range, span: span)
        let last = Self.fraction(max(low, high), in: range, span: span)
        start = first
        end = last
    }

    private static func fraction(_ value: Double, in range: ClosedRange<Double>, span: Double) -> Double {
        min(max((value - range.lowerBound) / span, 0), 1)
    }
}
