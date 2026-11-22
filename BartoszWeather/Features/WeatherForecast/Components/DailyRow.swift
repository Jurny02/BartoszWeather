import SwiftUI

struct DailyRow: View {
    @Environment(\.weatherAppearance) private var appearance
    private let day: String
    private let icon: Icon
    private let precipitationChance: Int?
    private let low: Double?
    private let high: Double?
    private let temperatureBounds: ClosedRange<Double>?
    @ScaledMetric(relativeTo: .body) private var temperatureWidth: CGFloat = 36
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private let minimumScaleFactor = 0.7
    private let symbolSize: CGFloat = 24

    init(
        day: String,
        icon: Icon,
        precipitationChance: Int?,
        low: Double?,
        high: Double?,
        temperatureBounds: ClosedRange<Double>? = nil
    ) {
        self.day = day
        self.icon = icon
        self.precipitationChance = precipitationChance
        self.low = low
        self.high = high
        self.temperatureBounds = temperatureBounds
    }

    var displayedPrecipitation: String {
        ForecastFormat.percentage(precipitationChance)
    }

    var displayedLow: String {
        ForecastFormat.temperature(low)
    }

    var displayedHigh: String {
        ForecastFormat.temperature(high)
    }

    var accessibilityLabel: String {
        let noData = ForecastFormat.noData.lowercased()
        guard precipitationChance != nil || low != nil || high != nil else {
            return "\(day), \(noData)"
        }
        let precipitation = precipitationChance == nil ? noData : displayedPrecipitation
        let lowLabel = low == nil ? noData : displayedLow
        let highLabel = high == nil ? noData : displayedHigh
        return [
            day,
            String(localized: "chance of rain \(precipitation)"),
            String(localized: "low \(lowLabel)"),
            String(localized: "high \(highLabel)"),
        ].joined(separator: ", ")
    }

    var body: some View {
        let isStacked = dynamicTypeSize >= .xxLarge
        let layout = isStacked
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: Spacing.xxSmall))
            : AnyLayout(HStackLayout(spacing: Spacing.small))
        layout {
            Text(day)
                .typography(.body)
                .foregroundStyle(Color(appearance.text))
                .frame(maxWidth: isStacked ? .infinity : nil, alignment: .leading)
                .layoutPriority(1)
            HStack(spacing: Spacing.small) {
                WeatherSymbol(icon: icon, size: symbolSize, relativeTo: .body)
                Text(displayedPrecipitation)
                    .typography(.caption)
                    .foregroundStyle(Color(appearance.accent))
                    .fixedSize(horizontal: !isStacked, vertical: false)
                Text(displayedLow)
                    .typography(.body)
                    .foregroundStyle(Color(appearance.secondaryText))
                    .frame(minWidth: isStacked ? nil : temperatureWidth, alignment: .trailing)
                    .fixedSize(horizontal: !isStacked, vertical: false)
                if !isStacked {
                    rangeBar
                }
                Text(displayedHigh)
                    .typography(.body)
                    .foregroundStyle(Color(appearance.text))
                    .frame(minWidth: isStacked ? nil : temperatureWidth, alignment: .leading)
                    .fixedSize(horizontal: !isStacked, vertical: false)
            }
            .frame(maxWidth: .infinity, alignment: isStacked ? .leading : .trailing)
        }
        .lineLimit(1)
        .minimumScaleFactor(minimumScaleFactor)
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

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                DailyRow(day: "Today", icon: .cloudSunFill, precipitationChance: 20, low: 8, high: 15)
                DailyRow(
                    day: "Wednesday",
                    icon: .cloudRainFill,
                    precipitationChance: 80,
                    low: 4,
                    high: 9,
                    temperatureBounds: 2...18
                )
                DailyRow(day: "Tuesday", icon: .cloudSunFill, precipitationChance: nil, low: nil, high: nil)
            }
            .padding(.horizontal, Spacing.medium)
            .background(Color(appearance.card), in: .rect(cornerRadius: Radius.large))
            .padding(Spacing.large)
        }
        .background(Color(appearance == .night ? .Weather.Clear.nightStart : .background))
    }
}
