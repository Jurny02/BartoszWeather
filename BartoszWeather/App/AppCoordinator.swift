import Observation

/// Owns the app's navigation: the search screen at the root and a forecast pushed for each selected city.
@Observable
final class AppCoordinator {
    /// The cities whose forecasts are stacked above the search screen, oldest first.
    var path: [City] = []

    func showForecast(for city: City) {
        path.append(city)
    }
}
