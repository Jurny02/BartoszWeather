import SwiftUI

/// A card for one current-conditions metric: heading, large value and a short caption.
struct MetricTile: View {
    @Environment(\.weatherAppearance) private var appearance
    @ScaledMetric private var iconSize = 16.0
    @ScaledMetric private var arrowSize = 12.0
    private let metric: WeatherMetric

    init(metric: WeatherMetric) {
        self.metric = metric
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxSmall) {
            heading
            Text(metric.value)
                .typography(.metricValue)
                .foregroundStyle(Color(metric.isHighlighted ? appearance.highlight : appearance.text))
            Text(metric.caption)
                .typography(.caption)
                .foregroundStyle(Color(appearance.secondaryText))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.medium)
        .padding(.vertical, Spacing.small)
        .background(Color(appearance.card), in: .rect(cornerRadius: Radius.large))
        .overlay {
            if metric.isHighlighted {
                RoundedRectangle(cornerRadius: Radius.large).strokeBorder(Color(appearance.highlight), lineWidth: 1)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(metric.accessibilityLabel)
    }

    private var heading: some View {
        HStack(spacing: Spacing.xSmall) {
            Image(icon: metric.icon)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
            Text(metric.title)
                .typography(.footnote)
            if let direction = metric.direction {
                Image(icon: .locationNorthFill)
                    .resizable()
                    .scaledToFit()
                    .frame(width: arrowSize, height: arrowSize)
                    .rotationEffect(.degrees(direction.arrowRotation))
                Text(direction.abbreviation)
                    .typography(.caption)
            }
        }
        .foregroundStyle(Color(appearance.secondaryText))
    }
}

#Preview {
    let strongWind = Wind(speed: 52, gusts: 78, direction: 315)
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.small) {
        MetricTile(metric: .cloudCover(0))
        MetricTile(metric: .precipitation(30))
        MetricTile(metric: .wind(Wind(speed: 8, gusts: 20, direction: 315)))
        MetricTile(metric: .humidity(40))
        MetricTile(metric: .wind(strongWind))
        MetricTile(metric: .humidity(nil))
    }
    .padding(Spacing.large)
    .background(Color(.Weather.Clear.dayEnd))
}
