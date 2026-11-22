import Testing
@testable import BartoszWeather

/// Tests the navigation path the app coordinator keeps.
struct AppCoordinatorTests {
    private let krakow = City(
        id: 3_094_802, name: "Kraków", region: "Małopolskie", district: nil, country: "Poland",
        coordinate: Coordinate(latitude: 50.06, longitude: 19.94)
    )
    private let hel = City(
        id: 3_099_539, name: "Hel", region: "Pomorskie", district: nil, country: "Poland",
        coordinate: Coordinate(latitude: 54.61, longitude: 18.80)
    )

    @Test func startsOnTheSearchScreen() {
        #expect(AppCoordinator().path.isEmpty)
    }

    @Test func pushesTheForecastOfTheSelectedCity() {
        let coordinator = AppCoordinator()
        coordinator.showForecast(for: krakow)
        coordinator.showForecast(for: hel)
        #expect(coordinator.path == [krakow, hel])
    }
}
