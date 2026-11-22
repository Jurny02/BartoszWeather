import SwiftUI

/// A day's temperature span drawn as a segment of a track that represents the span of all days.
struct TemperatureRangeBar: View {
    @Environment(\.weatherAppearance) private var appearance
    @ScaledMetric private var trackWidth = 64.0
    private let day: DailyForecast
    private let range: ClosedRange<Double>?

    init(day: DailyForecast, range: ClosedRange<Double>?) {
        self.day = day
        self.range = range
    }

    var body: some View {
        Capsule()
            .fill(Color(appearance.secondaryText).opacity(0.25))
            .frame(width: trackWidth, height: 4)
            .opacity(segment == nil ? 0 : 1)
            .overlay(alignment: .leading) {
                if let segment {
                    Capsule()
                        .fill(Color(appearance.accent))
                        .frame(width: trackWidth * (segment.end - segment.start), height: 4)
                        .offset(x: trackWidth * segment.start)
                }
            }
            .accessibilityHidden(true)
    }

    private var segment: TemperatureRangeSegment? {
        TemperatureRangeSegment(low: day.minTemperature, high: day.maxTemperature, within: range)
    }
}

#Preview {
    let day = DailyForecast(
        date: .now, condition: .clearSky, minTemperature: 8, maxTemperature: 15, precipitationProbability: 0
    )
    VStack(spacing: Spacing.small) {
        TemperatureRangeBar(day: day, range: 3...21)
        TemperatureRangeBar(day: day, range: nil)
    }
    .padding(Spacing.medium)
}
