import SwiftUI

struct HourlyCell: View {
    static let minimumVisiblePrecipitationChance = 10

    private let time: String
    private let icon: Icon
    private let temperature: Double?
    private let precipitationChance: Int?
    private let isHighlighted: Bool
    @ScaledMetric(relativeTo: .headline) private var minimumWidth: CGFloat = 52
    private let symbolSize: CGFloat = 25

    init(time: String, icon: Icon, temperature: Double?, precipitationChance: Int?, isHighlighted: Bool = false) {
        self.time = time
        self.icon = icon
        self.temperature = temperature
        self.precipitationChance = precipitationChance
        self.isHighlighted = isHighlighted
    }

    var displayedTemperature: String {
        ForecastFormat.temperature(temperature)
    }

    var displayedPrecipitation: String? {
        guard let precipitationChance else { return ForecastFormat.placeholder }
        guard precipitationChance >= Self.minimumVisiblePrecipitationChance else { return nil }
        return ForecastFormat.percentage(precipitationChance)
    }

    var accessibilityLabel: String {
        let noData = ForecastFormat.noData.lowercased()
        let temperatureLabel = temperature == nil ? noData : displayedTemperature
        let precipitationLabel: String? = switch (precipitationChance, displayedPrecipitation) {
        case (nil, _): String(localized: "chance of rain \(noData)")
        case (_, nil): nil
        case let (_, precipitation?): String(localized: "chance of rain \(precipitation)")
        }
        return [time, temperatureLabel, precipitationLabel]
            .compactMap { $0 }
            .joined(separator: ", ")
    }

    var body: some View {
        VStack(spacing: Spacing.xSmall) {
            Text(time)
                .typography(.footnote)
                .foregroundStyle(Color(.Weather.text))
            WeatherSymbol(icon: icon, size: symbolSize, relativeTo: .headline)
            Text(displayedTemperature)
                .typography(.headline)
                .foregroundStyle(Color(.Weather.text))
            Text(displayedPrecipitation ?? " ")
                .typography(.caption)
                .foregroundStyle(Color(.accent))
        }
        .lineLimit(1)
        .padding(.vertical, Spacing.xSmall)
        .frame(minWidth: minimumWidth)
        .background(
            isHighlighted ? Color(.Surface.selected) : .clear,
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

#Preview("Large Dynamic Type") {
    HourlyCellPreview()
        .dynamicTypeSize(.accessibility3)
}

private struct HourlyCellPreview: View {
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: Spacing.xSmall) {
                HourlyCell(time: "Now", icon: .cloudSunFill, temperature: 14, precipitationChance: 20, isHighlighted: true)
                HourlyCell(time: "15:00", icon: .cloudSunFill, temperature: 14, precipitationChance: 20)
                HourlyCell(time: "16:00", icon: .sunMaxFill, temperature: -12, precipitationChance: 0)
                HourlyCell(time: "17:00", icon: .cloudSunFill, temperature: nil, precipitationChance: nil)
            }
            .padding(Spacing.medium)
            .background(Color(.Weather.card), in: .rect(cornerRadius: Radius.large))
            .padding(Spacing.large)
        }
        .background(Color(.background))
    }
}
