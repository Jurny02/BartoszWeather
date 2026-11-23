import SwiftUI

/// One day of the forecast: day name, symbol, chance of precipitation and the temperature span.
struct DailyRow: View {
    @Environment(\.weatherAppearance) private var appearance
    @Environment(\.timeZone) private var timeZone
    @Environment(\.forecastNow) private var now
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric private var valueWidth = 36.0
    private let day: DailyForecast
    private let temperatureRange: ClosedRange<Double>?

    init(day: DailyForecast, temperatureRange: ClosedRange<Double>?) {
        self.day = day
        self.temperatureRange = temperatureRange
    }

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: Spacing.xSmall) {
                    dayLabel(dayName)
                    values
                }
            } else {
                HStack(spacing: Spacing.small) {
                    dayLabel(dayName)
                    values
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(day.accessibilityLabel(dayLabel: dayName))
    }

    private func dayLabel(_ name: String) -> some View {
        Text(name)
            .typography(.headline)
            .fontWeight(.regular)
            .foregroundStyle(Color(appearance.text))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var values: some View {
        let columnWidth: CGFloat? = dynamicTypeSize.isAccessibilitySize ? nil : valueWidth
        return HStack(spacing: Spacing.xSmall) {
            WeatherSymbol(icon: day.condition.icon(isDay: true), size: 24, relativeTo: .title3)
            Text(day.precipitationText)
                .typography(.caption)
                .foregroundStyle(Color(appearance.accent))
                .frame(width: columnWidth)
            Text(day.lowText)
                .typography(.headline)
                .fontWeight(.regular)
                .foregroundStyle(Color(appearance.secondaryText))
                .frame(width: columnWidth, alignment: .trailing)
            if !dynamicTypeSize.isAccessibilitySize {
                TemperatureRangeBar(day: day, range: temperatureRange)
            }
            Text(day.highText)
                .typography(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(Color(appearance.text))
                .frame(width: columnWidth, alignment: .leading)
        }
    }

    private var dayName: String {
        WeatherFormatter(timeZone: timeZone).dayName(day.date, now: now)
    }
}

#Preview {
    let day = DailyForecast(
        date: Date(timeIntervalSince1970: 1_784_117_100), condition: .rain,
        minTemperature: 8, maxTemperature: 15, precipitationProbability: 30
    )
    VStack(spacing: Spacing.small) {
        DailyRow(day: day, temperatureRange: 3...21)
        DailyRow(day: day, temperatureRange: nil)
    }
    .environment(\.timeZone, TimeZone(identifier: "Europe/Warsaw")!)
    .environment(\.forecastNow, Date(timeIntervalSince1970: 1_784_117_100))
    .padding(Spacing.medium)
    .background(Color(.Weather.card))
}
