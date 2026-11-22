import Testing
@testable import BartoszWeather

struct BartoszWeatherAppTests {
    @Test func appModuleIsTestable() {
        #expect(String(describing: BartoszWeatherApp.self) == "BartoszWeatherApp")
    }
}
