import SwiftUI

struct TemperatureRangeBar: View {
    private let segment: ClosedRange<Double>
    @ScaledMetric(relativeTo: .body) private var maximumWidth: CGFloat = 64
    private let minimumWidth: CGFloat = 24
    private let height: CGFloat = 4

    init(low: Double, high: Double, bounds: ClosedRange<Double>?) {
        segment = Self.segment(low: low, high: high, bounds: bounds)
    }

    nonisolated static func segment(low: Double, high: Double, bounds: ClosedRange<Double>?) -> ClosedRange<Double> {
        guard let bounds, bounds.upperBound > bounds.lowerBound else { return 0...1 }
        let span = bounds.upperBound - bounds.lowerBound
        let start = ((low - bounds.lowerBound) / span).clamped(to: 0...1)
        let end = ((high - bounds.lowerBound) / span).clamped(to: start...1)
        return start...end
    }

    var body: some View {
        Capsule()
            .fill(Color(.separatorLine))
            .overlay(alignment: .leading) {
                GeometryReader { proxy in
                    Capsule()
                        .fill(Color(.accent))
                        .frame(width: proxy.size.width * (segment.upperBound - segment.lowerBound))
                        .offset(x: proxy.size.width * segment.lowerBound)
                }
            }
            .frame(minWidth: minimumWidth, maxWidth: maximumWidth)
            .frame(height: height)
            .accessibilityHidden(true)
    }
}

private extension Double {
    nonisolated func clamped(to range: ClosedRange<Double>) -> Double {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
