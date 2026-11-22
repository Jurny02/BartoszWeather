import Testing
@testable import BartoszWeather

struct WindTests {
    @Test(arguments: [
        (39.9, nil, false),
        (39.9, 59.9, false),
        (40, nil, true),
        (10, 60, true),
    ] as [(Double, Double?, Bool)])
    func isStrongFromSpeedOrGusts(speed: Double, gusts: Double?, isStrong: Bool) {
        #expect(Wind(speed: speed, gusts: gusts, direction: nil).isStrong == isStrong)
    }
}
