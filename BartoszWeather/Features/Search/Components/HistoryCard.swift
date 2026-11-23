import SwiftUI

/// A recently opened city drawn on its sky gradient, with the current temperature, condition and today's range.
///
/// At accessibility text sizes the temperature moves below the city and the range below the condition,
/// so every line can wrap instead of being truncated.
struct HistoryCard: View {
    private static let symbolSpacing: CGFloat = 6

    private let entry: SearchHistoryEntry
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .largeTitle) private var minHeight = 132.0

    init(entry: SearchHistoryEntry) {
        self.entry = entry
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: Spacing.xSmall) {
                    location
                    temperature
                }
                VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                    condition
                    range
                }
            } else {
                HStack(spacing: Spacing.small) {
                    location
                    Spacer(minLength: 0)
                    temperature
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                Spacer(minLength: 0)
                HStack(spacing: Self.symbolSpacing) {
                    condition
                        .lineLimit(1)
                    Spacer(minLength: Spacing.xSmall)
                    range
                        .lineLimit(1)
                }
            }
        }
        .multilineTextAlignment(.leading)
        .padding(Spacing.medium)
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .leading)
        .background(gradient, in: .rect(cornerRadius: Radius.large))
        .overlay {
            if appearance == .day {
                RoundedRectangle(cornerRadius: Radius.large)
                    .strokeBorder(Color(.Text.secondary), lineWidth: 1)
            }
        }
        .contentShape(.rect(cornerRadius: Radius.large))
        .environment(\.weatherAppearance, appearance)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(entry.accessibilityLabel)
    }

    private var appearance: WeatherAppearance {
        entry.appearance
    }

    private var location: some View {
        VStack(alignment: .leading, spacing: Spacing.xxSmall) {
            Text(entry.city.name)
                .typography(.cardCity)
                .foregroundStyle(Color(appearance.text))
            if let regionAndCountry = entry.city.regionAndCountry {
                Text(regionAndCountry)
                    .typography(.footnote)
                    .foregroundStyle(Color(appearance.secondaryText))
            }
        }
    }

    private var temperature: some View {
        Text(entry.temperatureText)
            .typography(.cardTemperature)
            .foregroundStyle(Color(appearance.text))
    }

    private var condition: some View {
        HStack(spacing: Self.symbolSpacing) {
            WeatherSymbol(icon: entry.icon, size: 18, relativeTo: .footnote)
            Text(entry.conditionText)
                .typography(.cardCaption)
                .foregroundStyle(Color(appearance.text))
        }
    }

    private var range: some View {
        Text(entry.rangeText)
            .typography(.cardCaption)
            .foregroundStyle(Color(appearance.secondaryText))
    }

    private var gradient: LinearGradient {
        let colors = entry.sky.colors(isNight: entry.appearance == .night)
        return LinearGradient(colors: [Color(colors.start), Color(colors.end)], startPoint: .top, endPoint: .bottom)
    }
}

#if DEBUG
#Preview {
    ScrollView {
        VStack(spacing: Spacing.small) {
            ForEach(SearchHistoryEntry.previewEntries + [.expiredEntry]) { entry in
                HistoryCard(entry: entry)
            }
        }
        .padding(Spacing.large)
    }
    .background(Color(.background))
}
#endif
