import Testing
@testable import BartoszWeather

struct WindDirectionTests {
    @Test(arguments: [
        (0.0, "N", "north"),
        (44.0, "NE", "northeast"),
        (90.0, "E", "east"),
        (135.0, "SE", "southeast"),
        (180.0, "S", "south"),
        (225.0, "SW", "southwest"),
        (270.0, "W", "west"),
        (315.0, "NW", "northwest"),
        (338.0, "N", "north"),
        (360.0, "N", "north"),
        (-45.0, "NW", "northwest"),
    ])
    func namesTheNearestCompassPoint(degrees: Double, abbreviation: String, spokenName: String) {
        let direction = WindDirection(degrees: degrees)
        #expect(direction.abbreviation == abbreviation)
        #expect(direction.spokenName == spokenName)
    }
}
