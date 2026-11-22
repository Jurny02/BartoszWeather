import SwiftUI

/// The search screen: a title, the city name field, and below it history, results, loading or an empty or error state.
struct SearchCityView: View {
    private static let emptyStateBottomInset: CGFloat = 108
    private static let clearButtonMinWidth: CGFloat = 64
    private static let minTapTargetHeight: CGFloat = 44

    @Binding private var query: String
    private let content: SearchCityContent
    private let onSelectCity: (City) -> Void
    private let onDeleteHistoryEntry: (SearchHistoryEntry) -> Void
    private let onClearHistory: () -> Void
    private let onRetry: () -> Void
    @ScaledMetric(relativeTo: .footnote) private var validationAreaHeight = 40.0
    @ScaledMetric(relativeTo: .title) private var invalidHintIconSize = 40.0

    init(
        query: Binding<String>,
        content: SearchCityContent,
        onSelectCity: @escaping (City) -> Void,
        onDeleteHistoryEntry: @escaping (SearchHistoryEntry) -> Void,
        onClearHistory: @escaping () -> Void,
        onRetry: @escaping () -> Void
    ) {
        _query = query
        self.content = content
        self.onSelectCity = onSelectCity
        self.onDeleteHistoryEntry = onDeleteHistoryEntry
        self.onClearHistory = onClearHistory
        self.onRetry = onRetry
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(Color(.background).ignoresSafeArea())
        .navigationTitle("Weather")
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text("Weather")
                .typography(.largeTitle)
                .foregroundStyle(Color(.Text.primary))
                .accessibilityAddTraits(.isHeader)
            SearchField(text: $query, isInvalid: content.isInputInvalid)
            if content.reservesValidationArea {
                Text(content.validationMessage ?? "")
                    .typography(.footnote)
                    .foregroundStyle(Color(.error))
                    .frame(maxWidth: .infinity, minHeight: validationAreaHeight, alignment: .topLeading)
                    .accessibilityHidden(content.validationMessage == nil)
            }
        }
        .padding(.horizontal, Spacing.large)
        .padding(.top, Spacing.small)
    }

    @ViewBuilder
    private var contentView: some View {
        switch content {
        case .history(let entries):
            history(entries)
        case .loading:
            SearchLoadingView()
                .padding(.horizontal, Spacing.large)
        case .results(let query, let cities):
            results(cities, query: query)
        case .invalidInput:
            centered(invalidInputHint)
        case .prompt, .noResults, .offline, .failure:
            if let message = content.stateMessage {
                centered(stateView(message))
            }
        }
    }

    private func history(_ entries: [SearchHistoryEntry]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            SearchSectionHeader(title: "Recent") {
                Button("Clear", action: onClearHistory)
                    .typography(.body)
                    .foregroundStyle(Color(.accent))
                    .frame(minWidth: Self.clearButtonMinWidth, minHeight: Self.minTapTargetHeight, alignment: .trailing)
                    .accessibilityLabel("Clear search history")
            }
            .padding(.horizontal, Spacing.large)
            List {
                ForEach(entries) { entry in
                    Button {
                        onSelectCity(entry.city)
                    } label: {
                        HistoryCard(entry: entry)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(
                        EdgeInsets(top: Spacing.small / 2, leading: Spacing.large, bottom: Spacing.small / 2, trailing: Spacing.large)
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing) {
                        Button("Delete", role: .destructive) {
                            onDeleteHistoryEntry(entry)
                        }
                    }
                    .accessibilityAction(named: "Delete") {
                        onDeleteHistoryEntry(entry)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    private func results(_ cities: [City], query: String) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.small) {
                SearchSectionHeader(title: "Cities") {
                    Text(SearchCityContent.resultCountText(cities.count))
                        .typography(.footnote)
                        .foregroundStyle(Color(.Text.secondary))
                }
                CityResultList(cities: cities, query: query, onSelect: onSelectCity)
            }
            .padding(.horizontal, Spacing.large)
            .padding(.bottom, Spacing.large)
        }
    }

    private func stateView(_ message: SearchStateMessage) -> some View {
        StateView(icon: message.icon, title: message.title, message: message.message) {
            if message.showsRetry {
                RetryButton(action: onRetry)
            }
        }
    }

    private var invalidInputHint: some View {
        VStack(spacing: Spacing.small) {
            Image(icon: .magnifyingGlass)
                .resizable()
                .scaledToFit()
                .frame(width: invalidHintIconSize, height: invalidHintIconSize)
                .foregroundStyle(Color(.Text.secondary))
                .accessibilityHidden(true)
            Text(SearchCityContent.invalidInputHint)
                .typography(.body)
                .foregroundStyle(Color(.Text.secondary))
                .multilineTextAlignment(.center)
        }
    }

    private func centered(_ content: some View) -> some View {
        ScrollView {
            content
                .padding(.horizontal, Spacing.large)
                .padding(.bottom, Self.emptyStateBottomInset)
                .frame(maxWidth: .infinity)
                .containerRelativeFrame(.vertical)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

#if DEBUG
#Preview("No history") {
    SearchCityPreview(query: "", content: .prompt)
}

#Preview("History") {
    SearchCityPreview(query: "", content: .history(SearchHistoryEntry.previewEntries))
}

#Preview("Loading") {
    SearchCityPreview(query: "Krak", content: .loading)
}

#Preview("Results") {
    SearchCityPreview(query: "Krak", content: .results(query: "Krak", cities: City.searchResults))
}

#Preview("Invalid input") {
    SearchCityPreview(query: "Kraków123", content: .invalidInput)
}

#Preview("No results") {
    SearchCityPreview(query: "Xyz", content: .noResults(query: "Xyz"))
}

#Preview("Offline") {
    SearchCityPreview(query: "", content: .offline)
}

#Preview("API error") {
    SearchCityPreview(query: "", content: .failure)
}

#Preview("Dark") {
    SearchCityPreview(query: "", content: .history(SearchHistoryEntry.previewEntries))
        .preferredColorScheme(.dark)
}

#Preview("Large Dynamic Type") {
    SearchCityPreview(query: "Krak", content: .results(query: "Krak", cities: City.searchResults))
        .dynamicTypeSize(.accessibility3)
}

/// Hosts the search screen in previews with an editable query and no-op actions.
private struct SearchCityPreview: View {
    @State var query: String
    let content: SearchCityContent

    var body: some View {
        NavigationStack {
            SearchCityView(
                query: $query,
                content: content,
                onSelectCity: { _ in },
                onDeleteHistoryEntry: { _ in },
                onClearHistory: {},
                onRetry: {}
            )
        }
    }
}
#endif
