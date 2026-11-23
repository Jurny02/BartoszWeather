import Foundation
import SwiftUI

/// The composition root: creates the app's dependencies once and hands them to the root view.
@main
struct BartoszWeatherApp: App {
    @State private var coordinator: AppCoordinator
    @State private var searchViewModel: SearchCityViewModel
    private let forecastRepository: any ForecastRepository

    init() {
        let coordinator = AppCoordinator()
        let client = URLSessionAPIClient()
        let language = Locale.current.language.languageCode?.identifier ?? "en"
        let history = SwiftDataHistoryRepository.onDiskOrInMemory(now: Date.init)
        _coordinator = State(initialValue: coordinator)
        _searchViewModel = State(initialValue: SearchCityViewModel(
            service: OpenMeteoCitySearchService(client: client, language: language),
            clock: ContinuousClock(),
            history: history,
            onSelectCity: coordinator.showForecast(for:)
        ))
        forecastRepository = DefaultForecastRepository(
            service: OpenMeteoForecastService(client: client, now: Date.init),
            store: history
        )
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(
                coordinator: coordinator,
                searchViewModel: searchViewModel,
                makeForecastViewModel: { [forecastRepository] city in
                    ForecastViewModel(city: city, repository: forecastRepository)
                }
            )
        }
    }
}
