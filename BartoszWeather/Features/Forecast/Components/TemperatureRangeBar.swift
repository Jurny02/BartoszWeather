import SwiftUI

/// A day's temperature span drawn as a segment of a track that represents the span of all days.
struct TemperatureRangeBar: View {
    private static let barHeight: CGFloat = 4

    @Environment(\.weatherAppearance) private var appearance
    @ScaledMetric private var trackWidth = 64.0
    private let segment: TemperatureRangeSegment?

    init(day: DailyForecast, range: ClosedRange<Double>?) {
        segment = TemperatureRangeSegment(low: day.minTemperature, high: day.maxTemperature, within: range)
    }

    var body: some View {
        track
            .opacity(segment == nil ? 0 : 1)
            .overlay(alignment: .leading) {
                if segment != nil {
                    fill
                }
            }
            .accessibilityHidden(true)
    }

    private var track: some View {
        Capsule()
            .fill(Color(appearance.secondaryText).opacity(0.25))
            .frame(width: trackWidth, height: Self.barHeight)
    }

    private var fill: some View {
        Capsule()
            .fill(Color(appearance.accent))
            .frame(width: fillWidth, height: Self.barHeight)
            .offset(x: fillOffset)
    }

    private var fillWidth: CGFloat {
        trackWidth * (segment?.length ?? 0)
    }

    private var fillOffset: CGFloat {
        trackWidth * (segment?.start ?? 0)
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
