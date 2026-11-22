import SwiftUI

struct DailyRow: View {
    @Environment(\.weatherAppearance) private var appearance
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private let day: DailyForecast
    private let dayLabel: String
    private let temperatureBounds: ClosedRange<Double>?
    @ScaledMetric(relativeTo: .body) private var temperatureWidth: CGFloat = 36
    @ScaledMetric(relativeTo: .caption) private var precipitationWidth: CGFloat = 32
    private let minimumScaleFactor = 0.7
    private let symbolSize: CGFloat = 24

    init(day: DailyForecast, dayLabel: String, temperatureBounds: ClosedRange<Double>? = nil) {
        self.day = day
        self.dayLabel = dayLabel
        self.temperatureBounds = temperatureBounds
    }

    nonisolated static func temperatureBounds(for days: [DailyForecast]) -> ClosedRange<Double>? {
        let lows = days.compactMap { ForecastFormat.plausibleTemperature($0.minTemperature) }
        let highs = days.compactMap { ForecastFormat.plausibleTemperature($0.maxTemperature) }
        guard let lowest = lows.min(), let highest = highs.max(), lowest <= highest else { return nil }
        return lowest...highest
    }

    private var low: Double? {
        ForecastFormat.plausibleTemperature(day.minTemperature)
    }

    private var high: Double? {
        ForecastFormat.plausibleTemperature(day.maxTemperature)
    }

    var icon: Icon {
        day.condition.icon(isDay: true)
    }

    var displayedPrecipitation: String {
        ForecastFormat.percentage(day.precipitationProbability)
    }

    var displayedLow: String {
        ForecastFormat.temperature(low)
    }

    var displayedHigh: String {
        ForecastFormat.temperature(high)
    }

    var showsRangeBar: Bool {
        low != nil && high != nil
    }

    var accessibilityLabel: String {
        let noData = ForecastFormat.noData.lowercased()
        let condition = day.condition.spokenDescription
        guard day.precipitationProbability != nil || low != nil || high != nil else {
            return [dayLabel, condition, noData].compactMap { $0 }.joined(separator: ", ")
        }
        let precipitation = day.precipitationProbability == nil ? noData : displayedPrecipitation
        return [
            dayLabel,
            condition,
            String(localized: "chance of rain \(precipitation)"),
            String(localized: "low \(low == nil ? noData : displayedLow)"),
            String(localized: "high \(high == nil ? noData : displayedHigh)"),
        ]
        .compactMap { $0 }
        .joined(separator: ", ")
    }

    var body: some View {
        let isStacked = dynamicTypeSize >= .xLarge
        let layout = isStacked
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: Spacing.xxSmall))
            : AnyLayout(HStackLayout(spacing: Spacing.small))
        layout {
            Text(dayLabel)
                .typography(.body)
                .foregroundStyle(Color(appearance.text))
                .frame(maxWidth: .infinity, alignment: .leading)
                .minimumScaleFactor(minimumScaleFactor)
            HStack(spacing: Spacing.xSmall) {
                WeatherSymbol(icon: icon, size: symbolSize, relativeTo: .body)
                Text(displayedPrecipitation)
                    .typography(.caption)
                    .foregroundStyle(Color(appearance.accent))
                    .frame(minWidth: isStacked ? nil : precipitationWidth, alignment: .leading)
                Text(displayedLow)
                    .typography(.body)
                    .foregroundStyle(Color(appearance.secondaryText))
                    .frame(minWidth: isStacked ? nil : temperatureWidth, alignment: .trailing)
                if !isStacked {
                    rangeBar
                }
                Text(displayedHigh)
                    .typography(.body)
                    .foregroundStyle(Color(appearance.text))
                    .frame(minWidth: isStacked ? nil : temperatureWidth, alignment: .leading)
            }
            .fixedSize(horizontal: !isStacked, vertical: false)
            .minimumScaleFactor(isStacked ? minimumScaleFactor : 1)
        }
        .lineLimit(1)
        .monospacedDigit()
        .padding(.vertical, Spacing.small)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    @ViewBuilder
    private var rangeBar: some View {
        if let low, let high {
            TemperatureRangeBar(low: low, high: high, bounds: temperatureBounds)
        } else {
            TemperatureRangeBar(low: 0, high: 0, bounds: nil)
                .hidden()
        }
    }
}

#Preview("Light") {
    DailyRowPreview()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    DailyRowPreview()
        .preferredColorScheme(.dark)
}

#Preview("Night") {
    DailyRowPreview()
        .environment(\.weatherAppearance, .night)
}

#Preview("Large Dynamic Type") {
    DailyRowPreview()
        .dynamicTypeSize(.accessibility3)
}

private struct DailyRowPreview: View {
    @Environment(\.weatherAppearance) private var appearance
    private let days: [(label: String, forecast: DailyForecast)] = [
        ("Today", .preview(.partlyCloudy, low: 8, high: 15, chance: 20)),
        ("Wed", .preview(.heavyRain, low: 4, high: 9, chance: 80)),
        ("Thu", .preview(.snow, low: -6, high: 1, chance: 100)),
        ("Fri", .preview(.unknown, low: nil, high: nil, chance: nil)),
    ]

    var body: some View {
        let bounds = DailyRow.temperatureBounds(for: days.map(\.forecast))
        ScrollView {
            VStack(spacing: 0) {
                ForEach(days, id: \.label) { day in
                    DailyRow(day: day.forecast, dayLabel: day.label, temperatureBounds: bounds)
                }
            }
            .padding(.horizontal, Spacing.medium)
            .background(Color(appearance.card), in: .rect(cornerRadius: Radius.large))
            .padding(Spacing.large)
        }
        .background(Color(appearance == .night ? .Weather.Clear.nightStart : .background))
    }
}

private extension DailyForecast {
    static func preview(_ condition: WeatherCondition, low: Double?, high: Double?, chance: Int?) -> DailyForecast {
        DailyForecast(
            date: .now,
            condition: condition,
            minTemperature: low,
            maxTemperature: high,
            precipitationProbability: chance
        )
    }
}
