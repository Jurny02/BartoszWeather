import SwiftUI

/// The navigation stack driven by `AppCoordinator`, with the search screen at its root
/// and a forecast screen pushed for each selected city.
struct AppCoordinatorView: View {
    @Bindable private var coordinator: AppCoordinator
    private let searchViewModel: SearchCityViewModel
    private let makeForecastViewModel: (City) -> ForecastViewModel

    init(
        coordinator: AppCoordinator,
        searchViewModel: SearchCityViewModel,
        makeForecastViewModel: @escaping (City) -> ForecastViewModel
    ) {
        self.coordinator = coordinator
        self.searchViewModel = searchViewModel
        self.makeForecastViewModel = makeForecastViewModel
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            SearchCityScreen(viewModel: searchViewModel)
                .navigationDestination(for: City.self) { city in
                    ForecastScreen(viewModel: makeForecastViewModel(city))
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
            onSelectCity: coordinator.showForecast(for:)
        ),
        makeForecastViewModel: { city in
            ForecastViewModel(city: city, repository: PreviewForecastRepository(result: .success(.krakowDay)))
        }
    )
}
#endif
