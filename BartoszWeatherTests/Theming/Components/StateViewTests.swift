import Testing
@testable import BartoszWeather

struct StateViewTests {
    @Test func readsTitleAndMessageAsOneAccessibilityElement() {
        let view = StateView(
            icon: .wifiSlash,
            title: "No internet connection",
            message: "Check your connection and try again."
        )
        #expect(view.accessibilityLabel == "No internet connection, Check your connection and try again.")
    }
}
