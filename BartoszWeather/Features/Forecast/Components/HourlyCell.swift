import SwiftUI

/// One hour of the forecast: time, weather symbol, temperature and chance of precipitation.
struct HourlyCell: View {
    @Environment(\.weatherAppearance) private var appearance
    @Environment(\.timeZone) private var timeZone
    @ScaledMetric private var width = 52.0
    private let hour: HourlyForecast
    private let isNow: Bool

    init(hour: HourlyForecast, isNow: Bool) {
        self.hour = hour
        self.isNow = isNow
    }

    var body: some View {
        let timeLabel = isNow ? String(localized: "Now") : WeatherFormatter(timeZone: timeZone).hour(hour.date)
        VStack(spacing: Spacing.xSmall) {
            Text(timeLabel)
                .typography(.footnote)
                .foregroundStyle(Color(appearance.text))
            WeatherSymbol(icon: hour.condition.icon(isDay: hour.isDay), size: 25, relativeTo: .title3)
            Text(hour.temperatureText)
                .typography(.headline)
                .foregroundStyle(Color(appearance.text))
            Text(hour.precipitationText)
                .typography(.caption)
                .foregroundStyle(Color(appearance.accent))
                .opacity(hour.showsPrecipitation ? 1 : 0)
        }
        .padding(.vertical, Spacing.xSmall)
        .frame(width: width)
        .background(isNow ? Color(appearance.selection) : .clear, in: .rect(cornerRadius: Radius.medium))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(hour.accessibilityLabel(timeLabel: timeLabel))
    }
}

#Preview {
    let hour = HourlyForecast(
        date: Date(timeIntervalSince1970: 1_784_117_100), condition: .partlyCloudy, isDay: true,
        temperature: 24, precipitationProbability: 30
    )
    HStack(spacing: Spacing.xSmall) {
        HourlyCell(hour: hour, isNow: true)
        HourlyCell(hour: hour, isNow: false)
    }
    .environment(\.timeZone, TimeZone(identifier: "Europe/Warsaw")!)
    .padding(Spacing.medium)
    .background(Color(.Weather.card))
}
