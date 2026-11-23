import SwiftUI

/// The navigation stack driven by `AppCoordinator`, with the search screen at its root
/// and a forecast screen pushed for each selected city.
struct AppCoordinatorView: View {
    @Bindable private var coordinator: AppCoordinator
    private let searchViewModel: SearchCityViewModel
    private let forecastRepository: any ForecastRepository

    init(
        coordinator: AppCoordinator,
        searchViewModel: SearchCityViewModel,
        forecastRepository: any ForecastRepository
    ) {
        self.coordinator = coordinator
        self.searchViewModel = searchViewModel
        self.forecastRepository = forecastRepository
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            SearchCityScreen(viewModel: searchViewModel)
                .navigationDestination(for: City.self) { city in
                    ForecastScreen(viewModel: ForecastViewModel(city: city, repository: forecastRepository))
                }
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
            history: PreviewSearchHistoryRepository(entries: SearchHistoryEntry.previewEntries),
            onSelectCity: coordinator.showForecast(for:)
        ),
        forecastRepository: PreviewForecastRepository(result: .success(.krakowDay))
    )
}
#endif
