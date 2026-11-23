import SwiftUI

/// The forecast screen while the first forecast loads: the city's name with skeleton blocks
/// shaped like the current conditions, the metric tiles and the next hours.
struct ForecastLoadingView: View {
    private static let metricCount = 4
    private static let hourCount = 6
    private static let metricTileHeight: CGFloat = 98
    private static let hourlyCellWidth: CGFloat = 52
    private static let hourlyCellSpacing: CGFloat = 14

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private let city: City

    init(city: City) {
        self.city = city
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.small) {
                header
                metrics
                hourlyCard
                footer
            }
            .padding(.horizontal, Spacing.large)
            .padding(.top, Spacing.xSmall)
            .padding(.bottom, Spacing.small)
        }
        .scrollDisabled(true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Loading forecast for \(city.name)")
    }

    private var header: some View {
        VStack(spacing: Spacing.xxSmall) {
            Text(city.name)
                .typography(.cityTitle)
                .foregroundStyle(Color(.Text.primary))
            if let regionAndCountry = city.regionAndCountry {
                Text(regionAndCountry)
                    .typography(.footnote)
                    .foregroundStyle(Color(.Text.secondary))
            }
            VStack(spacing: Spacing.xxSmall) {
                HStack(spacing: Spacing.medium) {
                    SkeletonBlock(width: 64, height: 64)
                    SkeletonBlock(width: 120, height: 80)
                }
                .padding(.vertical, Spacing.small)
                SkeletonBlock(width: 130, height: 18)
                SkeletonBlock(width: 100, height: 14)
            }
            .skeletonPulse()
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }

    private var metrics: some View {
        let columnCount = dynamicTypeSize.isAccessibilitySize ? 1 : 2
        return LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.small), count: columnCount),
            spacing: Spacing.small
        ) {
            ForEach(0..<Self.metricCount, id: \.self) { _ in
                metricTile
            }
        }
    }

    private var metricTile: some View {
        VStack(alignment: .leading, spacing: Spacing.xSmall) {
            SkeletonBlock(width: 100, height: 12)
            SkeletonBlock(width: 66, height: 24)
            SkeletonBlock(width: 90, height: 10)
        }
        .skeletonPulse()
        .padding(Spacing.medium)
        .frame(maxWidth: .infinity, minHeight: Self.metricTileHeight, alignment: .topLeading)
        .background(Color(.Surface.card), in: .rect(cornerRadius: Radius.large))
    }

    private var hourlyCard: some View {
        VStack(alignment: .leading, spacing: Spacing.xSmall) {
            HStack {
                Text("Next hours")
                    .typography(.headline)
                    .foregroundStyle(Color(.Text.primary))
                Spacer(minLength: Spacing.xSmall)
                Text(WeatherFormatter.hourCount(24))
                    .typography(.footnote)
                    .foregroundStyle(Color(.Text.secondary))
            }
            HStack(alignment: .top, spacing: Spacing.xSmall) {
                ForEach(0..<Self.hourCount, id: \.self) { _ in
                    hourlyCell
                }
            }
            .fixedSize(horizontal: true, vertical: false)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .clipped()
            .skeletonPulse()
        }
        .padding(.horizontal, Spacing.medium)
        .padding(.vertical, Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.Surface.card), in: .rect(cornerRadius: Radius.large))
    }

    private var hourlyCell: some View {
        VStack(spacing: Self.hourlyCellSpacing) {
            SkeletonBlock(width: 26, height: 12)
            SkeletonBlock(width: 28, height: 25)
            SkeletonBlock(width: 24, height: 14)
            SkeletonBlock(width: 22, height: 10)
        }
        .padding(.vertical, Spacing.xSmall)
        .frame(width: Self.hourlyCellWidth)
    }

    private var footer: some View {
        VStack(spacing: Spacing.xxSmall) {
            Text("Weather data by Open-Meteo.com")
            Text("Loading forecast…")
        }
        .typography(.caption)
        .foregroundStyle(Color(.Text.secondary))
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG
#Preview("Light") {
    NavigationStack {
        ForecastLoadingView(city: .krakow)
            .background(Color(.background))
    }
}

#Preview("Dark") {
    NavigationStack {
        ForecastLoadingView(city: .krakow)
            .background(Color(.background))
    }
    .preferredColorScheme(.dark)
}

#Preview("Large Dynamic Type") {
    NavigationStack {
        ForecastLoadingView(city: .krakow)
            .background(Color(.background))
    }
    .dynamicTypeSize(.accessibility3)
}
#endif
