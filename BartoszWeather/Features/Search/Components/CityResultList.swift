import SwiftUI

/// Found cities in one rounded group, separated by thin lines; tapping a row selects its city.
struct CityResultList: View {
    private let cities: [City]
    private let query: String
    private let onSelect: (City) -> Void

    init(cities: [City], query: String, onSelect: @escaping (City) -> Void) {
        self.cities = cities
        self.query = query
        self.onSelect = onSelect
    }

    var body: some View {
        VStack(spacing: 1) {
            ForEach(cities) { city in
                Button {
                    onSelect(city)
                } label: {
                    CityResultRow(city: city, query: query)
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color(.separatorLine))
        .clipShape(.rect(cornerRadius: Radius.large))
    }
}

/// One found city: the name with the typed part emphasized, the line that tells same-name places apart, and a chevron.
struct CityResultRow: View {
    private let city: City
    private let query: String
    @ScaledMetric(relativeTo: .body) private var chevronSize = 12.0

    init(city: City, query: String) {
        self.city = city
        self.query = query
    }

    var body: some View {
        HStack(spacing: Spacing.small) {
            VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                Text(highlightedName)
                    .typography(.headline)
                    .lineLimit(1)
                if let subtitle = city.resultSubtitle {
                    Text(subtitle)
                        .typography(.footnote)
                        .foregroundStyle(Color(.Text.secondary))
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
            Image(icon: .chevronRight)
                .resizable()
                .scaledToFit()
                .frame(width: chevronSize, height: chevronSize)
                .foregroundStyle(Color(.Text.secondary))
                .accessibilityHidden(true)
        }
        .padding(Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.Surface.card))
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }

    private var highlightedName: AttributedString {
        var name = AttributedString(city.name)
        guard let match = city.highlightedNameRange(matching: query), let range = Range(match, in: name) else {
            name.foregroundColor = Color(.Text.primary)
            return name
        }
        name.foregroundColor = Color(.Text.secondary)
        name[range].foregroundColor = Color(.Text.primary)
        return name
    }
}

#if DEBUG
#Preview {
    CityResultList(cities: City.searchResults, query: "Krak") { _ in }
        .padding(Spacing.large)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(.background))
}
#endif
