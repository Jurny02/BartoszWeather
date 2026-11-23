import Foundation
import SwiftUI

/// The composition root: creates the app's dependencies once and hands them to the root view.
@main
struct BartoszWeatherApp: App {
    @State private var coordinator: AppCoordinator
    @State private var searchViewModel: SearchCityViewModel
    private let forecastService: any ForecastService

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
        forecastService = OpenMeteoForecastService(client: client, now: Date.init)
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(
                coordinator: coordinator,
                searchViewModel: searchViewModel,
                makeForecastViewModel: { [forecastService] city in
                    ForecastViewModel(city: city, service: forecastService)
                }
            )
        }
    }
}
