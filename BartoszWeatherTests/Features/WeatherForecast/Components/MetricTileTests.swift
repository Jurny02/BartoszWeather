import Testing
@testable import BartoszWeather

struct MetricTileTests {
    @Test func readsTitleValueAndCaption() {
        let tile = MetricTile(icon: .cloudFill, title: "Cloud cover", value: "42%", caption: "Partly cloudy")
        #expect(tile.displayedValue == "42%")
        #expect(tile.displayedCaption == "Partly cloudy")
        #expect(tile.accessibilityLabel == "Cloud cover, 42%, Partly cloudy")
    }

    @Test func showsPlaceholderAndNoDataWhenValueIsMissing() {
        let tile = MetricTile(icon: .dropFill, title: "Chance of rain", value: nil, caption: "Next hour")
        #expect(tile.displayedValue == "—")
        #expect(tile.displayedCaption == "No data")
        #expect(tile.accessibilityLabel == "Chance of rain, no data")
    }

    @Test func readsWindDirectionByName() {
        let tile = MetricTile(
            icon: .wind,
            title: "Wind",
            value: "14 km/h",
            caption: "Gusts 22 km/h",
            direction: WindDirection(degrees: 315)
        )
        #expect(tile.accessibilityLabel == "Wind, 14 km/h, northwest, Gusts 22 km/h")
    }

    @Test func usesAccessibilityTitleWhenGiven() {
        let tile = MetricTile(
            icon: .wind,
            title: "Wind",
            accessibilityTitle: "Strong wind",
            value: "52 km/h",
            caption: "Gusts 78 km/h",
            direction: WindDirection(degrees: 315),
            isHighlighted: true
        )
        #expect(tile.accessibilityLabel == "Strong wind, 52 km/h, northwest, Gusts 78 km/h")
    }
}
