import SwiftUI

struct HourlyCell: View {
    static let minimumVisiblePrecipitationChance = 10

    @Environment(\.weatherAppearance) private var appearance
    private let hour: HourlyForecast
    private let timeLabel: String
    private let isNow: Bool
    @ScaledMetric(relativeTo: .headline) private var minimumWidth: CGFloat = 52
    private let symbolSize: CGFloat = 25

    init(hour: HourlyForecast, timeLabel: String, isNow: Bool = false) {
        self.hour = hour
        self.timeLabel = timeLabel
        self.isNow = isNow
    }

    var icon: Icon {
        hour.condition.icon(isDay: hour.isDay)
    }

    var displayedTemperature: String {
        ForecastFormat.temperature(hour.temperature)
    }

    var displayedPrecipitation: String? {
        guard let chance = hour.precipitationProbability else { return ForecastFormat.placeholder }
        guard chance >= Self.minimumVisiblePrecipitationChance else { return nil }
        return ForecastFormat.percentage(chance)
    }

    var accessibilityLabel: String {
        let noData = ForecastFormat.noData.lowercased()
        let hasTemperature = ForecastFormat.plausibleTemperature(hour.temperature) != nil
        let precipitationLabel: String? = switch (hour.precipitationProbability, displayedPrecipitation) {
        case (nil, _): String(localized: "chance of rain \(noData)")
        case (_, nil): nil
        case let (_, precipitation?): String(localized: "chance of rain \(precipitation)")
        }
        return [
            timeLabel,
            hour.condition.spokenDescription,
            hasTemperature ? displayedTemperature : noData,
            precipitationLabel,
        ]
        .compactMap { $0 }
        .joined(separator: ", ")
    }

    var body: some View {
        VStack(spacing: Spacing.xSmall) {
            Text(timeLabel)
                .typography(.footnote)
                .foregroundStyle(Color(appearance.text))
            WeatherSymbol(icon: icon, size: symbolSize, relativeTo: .headline)
            Text(displayedTemperature)
                .typography(.headline)
                .foregroundStyle(Color(appearance.text))
            Text(displayedPrecipitation ?? " ")
                .typography(.caption)
                .foregroundStyle(Color(appearance.accent))
        }
        .lineLimit(1)
        .monospacedDigit()
        .padding(.vertical, Spacing.xSmall)
        .frame(minWidth: minimumWidth)
        .background(
            isNow ? Color(appearance.selection) : .clear,
            in: .rect(cornerRadius: Radius.medium)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview("Light") {
    HourlyCellPreview()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    HourlyCellPreview()
        .preferredColorScheme(.dark)
}

#Preview("Night") {
    HourlyCellPreview()
        .environment(\.weatherAppearance, .night)
}

#Preview("Large Dynamic Type") {
    HourlyCellPreview()
        .dynamicTypeSize(.accessibility3)
}

private struct HourlyCellPreview: View {
    @Environment(\.weatherAppearance) private var appearance

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: Spacing.xSmall) {
                HourlyCell(hour: .preview(.partlyCloudy, temperature: 14, chance: 20), timeLabel: "Now", isNow: true)
                HourlyCell(hour: .preview(.rainShowers, temperature: 13, chance: 60), timeLabel: "15:00")
                HourlyCell(hour: .preview(.clearSky, isDay: false, temperature: -12, chance: 0), timeLabel: "22:00")
                HourlyCell(hour: .preview(.overcast, temperature: nil, chance: nil), timeLabel: "23:00")
            }
            .padding(Spacing.medium)
            .background(Color(appearance.card), in: .rect(cornerRadius: Radius.large))
            .padding(Spacing.large)
        }
        .background(Color(appearance == .night ? .Weather.Clear.nightStart : .background))
    }
}

private extension HourlyForecast {
    static func preview(
        _ condition: WeatherCondition,
        isDay: Bool = true,
        temperature: Double?,
        chance: Int?
    ) -> HourlyForecast {
        HourlyForecast(
            date: .now,
            condition: condition,
            isDay: isDay,
            temperature: temperature,
            precipitationProbability: chance
        )
    }
}
