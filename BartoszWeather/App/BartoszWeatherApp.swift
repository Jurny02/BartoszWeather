import Foundation
import SwiftUI

/// The composition root: creates the app's dependencies once and hands them to the root view.
@main
struct BartoszWeatherApp: App {
    @State private var coordinator: AppCoordinator
    @State private var searchViewModel: SearchCityViewModel
    private let mockSearch = MockSearchData()

    init() {
        let coordinator = AppCoordinator()
        let client = URLSessionAPIClient()
        let language = Locale.current.language.languageCode?.identifier ?? "en"
        _coordinator = State(initialValue: coordinator)
        _searchViewModel = State(initialValue: SearchCityViewModel(
            service: OpenMeteoCitySearchService(client: client, language: language),
            clock: ContinuousClock(),
            onSelectCity: coordinator.showForecast(for:)
        ))
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(coordinator: coordinator, searchViewModel: searchViewModel, mockSearch: mockSearch)
        }
    }
}
