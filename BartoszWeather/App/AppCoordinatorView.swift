import SwiftUI

/// The navigation stack driven by `AppCoordinator`, with the search screen at its root.
struct AppCoordinatorView: View {
    @Bindable private var coordinator: AppCoordinator
    private let searchViewModel: SearchCityViewModel
    private let mockSearch: MockSearchData

    init(coordinator: AppCoordinator, searchViewModel: SearchCityViewModel, mockSearch: MockSearchData) {
        self.coordinator = coordinator
        self.searchViewModel = searchViewModel
        self.mockSearch = mockSearch
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            SearchCityScreen(viewModel: searchViewModel)
                .navigationDestination(for: City.self) { city in
                    forecastScreen(for: city)
                }
        }
    }

    @ViewBuilder
    private func forecastScreen(for city: City) -> some View {
        if let forecast = mockSearch.forecast(for: city) {
            ForecastView(city: city, forecast: forecast, now: forecast.current.date)
        } else {
            StateView(
                icon: .exclamationmarkTriangle,
                title: String(localized: "Something went wrong"),
                message: String(localized: "We couldn't load the data. Please try again.")
            )
        }
    }
}

#if DEBUG
#Preview {
    let coordinator = AppCoordinator()
    AppCoordinatorView(
        coordinator: coordinator,
        searchViewModel: SearchCityViewModel(
            service: PreviewCitySearchService(),
            clock: ContinuousClock(),
            onSelectCity: coordinator.showForecast(for:)
        ),
        mockSearch: MockSearchData()
    )
}
#endif
