import SwiftUI

/// The navigation stack driven by `AppCoordinator`, with the search screen at its root.
struct AppCoordinatorView: View {
    @Bindable private var coordinator: AppCoordinator
    @State private var query = ""
    private let mockSearch: MockSearchData

    init(coordinator: AppCoordinator, mockSearch: MockSearchData) {
        self.coordinator = coordinator
        self.mockSearch = mockSearch
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            SearchCityView(
                query: $query,
                content: mockSearch.content(for: query),
                onSelectCity: coordinator.showForecast(for:),
                onDeleteHistoryEntry: { _ in },
                onClearHistory: {},
                onRetry: {}
            )
            .navigationDestination(for: City.self) { city in
                forecastScreen(for: city)
            }
        }
    }

    @ViewBuilder
    private func forecastScreen(for city: City) -> some View {
        if let forecast = mockSearch.forecast(for: city) {
            ForecastView(city: city, forecast: forecast)
        } else {
            StateView(
                icon: .exclamationmarkTriangle,
                title: String(localized: "Something went wrong"),
                message: String(localized: "We couldn't load the data. Please try again.")
            )
        }
    }
}

#Preview {
    AppCoordinatorView(coordinator: AppCoordinator(), mockSearch: MockSearchData())
}
