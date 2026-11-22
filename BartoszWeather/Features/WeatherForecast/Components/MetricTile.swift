import SwiftUI

struct MetricTile: View {
    @Environment(\.weatherAppearance) private var appearance
    private let icon: Icon
    private let title: String
    private let accessibilityTitle: String
    private let value: String?
    private let caption: String
    private let direction: WindDirection?
    private let isHighlighted: Bool
    @ScaledMetric(relativeTo: .footnote) private var iconSize: CGFloat = 16
    @ScaledMetric(relativeTo: .caption) private var arrowSize: CGFloat = 12
    private let highlightBorderWidth: CGFloat = 1

    init(
        icon: Icon,
        title: String,
        accessibilityTitle: String? = nil,
        value: String?,
        caption: String,
        direction: WindDirection? = nil,
        isHighlighted: Bool = false
    ) {
        self.icon = icon
        self.title = title
        self.accessibilityTitle = accessibilityTitle ?? title
        self.value = value
        self.caption = caption
        self.direction = direction
        self.isHighlighted = isHighlighted
    }

    var displayedValue: String {
        value ?? ForecastFormat.placeholder
    }

    var displayedCaption: String {
        value == nil ? ForecastFormat.noData : caption
    }

    var accessibilityLabel: String {
        guard let value else {
            return "\(accessibilityTitle), \(ForecastFormat.noData.lowercased())"
        }
        return [accessibilityTitle, value, direction?.spokenName, caption]
            .compactMap { $0 }
            .joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxSmall) {
            heading
            Text(displayedValue)
                .typography(.metricValue)
                .foregroundStyle(Color(isHighlighted ? appearance.highlight : appearance.text))
            Text(displayedCaption)
                .typography(.caption)
                .foregroundStyle(Color(appearance.secondaryText))
        }
        .padding(.horizontal, Spacing.medium)
        .padding(.vertical, Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(appearance.card), in: .rect(cornerRadius: Radius.large))
        .overlay {
            if isHighlighted {
                RoundedRectangle(cornerRadius: Radius.large)
                    .strokeBorder(Color(appearance.highlight), lineWidth: highlightBorderWidth)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var heading: some View {
        HStack(spacing: Spacing.xSmall) {
            Image(icon: icon)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
            Text(title)
                .typography(.footnote)
            if let direction {
                Image(icon: .locationNorthFill)
                    .resizable()
                    .scaledToFit()
                    .frame(width: arrowSize, height: arrowSize)
                    .rotationEffect(.degrees(direction.degrees))
                Text(direction.abbreviation)
                    .typography(.caption)
            }
        }
        .foregroundStyle(Color(appearance.secondaryText))
    }
}

#Preview("Light") {
    MetricTilePreview()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    MetricTilePreview()
        .preferredColorScheme(.dark)
}

#Preview("Night") {
    MetricTilePreview()
        .environment(\.weatherAppearance, .night)
}

#Preview("Large Dynamic Type") {
    MetricTilePreview()
        .dynamicTypeSize(.accessibility3)
}

private struct MetricTilePreview: View {
    @Environment(\.weatherAppearance) private var appearance

    private let columns = [GridItem(.flexible(), spacing: Spacing.small), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Spacing.small) {
                MetricTile(icon: .cloudFill, title: "Cloud cover", value: "42%", caption: "Partly cloudy")
                MetricTile(icon: .dropFill, title: "Chance of rain", value: "20%", caption: "Next hour")
                MetricTile(
                    icon: .wind,
                    title: "Wind",
                    value: "14 km/h",
                    caption: "Gusts 22 km/h",
                    direction: WindDirection(degrees: 315)
                )
                MetricTile(icon: .humidityFill, title: "Humidity", value: "68%", caption: "Comfortable")
                MetricTile(
                    icon: .wind,
                    title: "Wind",
                    accessibilityTitle: "Strong wind",
                    value: "52 km/h",
                    caption: "Gusts 78 km/h",
                    direction: WindDirection(degrees: 315),
                    isHighlighted: true
                )
                MetricTile(icon: .cloudFill, title: "Cloud cover", value: nil, caption: "Partly cloudy")
            }
            .padding(Spacing.large)
        }
        .background(Color(appearance == .night ? .Weather.Clear.nightStart : .background))
    }
}
