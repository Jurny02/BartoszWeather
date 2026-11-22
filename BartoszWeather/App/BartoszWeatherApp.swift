import SwiftUI

/// The composition root: creates the app's dependencies once and hands them to the root view.
@main
struct BartoszWeatherApp: App {
    @State private var coordinator = AppCoordinator()
    private let mockSearch = MockSearchData()

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(coordinator: coordinator, mockSearch: mockSearch)
        }
    }
}
