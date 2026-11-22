import Testing
@testable import BartoszWeather

struct CompassDirectionTests {
    @Test(arguments: [
        (0.0, CompassDirection.north),
        (44, .northEast),
        (90, .east),
        (135, .southEast),
        (180, .south),
        (225, .southWest),
        (270, .west),
        (315, .northWest),
        (337, .northWest),
        (338, .north),
        (360, .north),
        (-45, .northWest),
        (405, .northEast),
    ])
    func roundsABearingToTheNearestPoint(degrees: Double, expected: CompassDirection) {
        #expect(CompassDirection(degrees: degrees) == expected)
    }

    @Test func abbreviatesEachPoint() {
        #expect(CompassDirection.allCases.map(\.abbreviation) == ["N", "NE", "E", "SE", "S", "SW", "W", "NW"])
    }

    @Test func speaksEachPoint() {
        #expect(
            CompassDirection.allCases.map(\.spokenName)
                == ["north", "northeast", "east", "southeast", "south", "southwest", "west", "northwest"]
        )
    }

    @Test func rotatesTheArrowInSteps() {
        #expect(CompassDirection.north.arrowRotation == 0)
        #expect(CompassDirection.northWest.arrowRotation == 315)
    }
}
