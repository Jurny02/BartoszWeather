import Testing
import UIKit
@testable import BartoszWeather

struct ColorTokensTests {
    struct Token {
        let name: String
        let resource: ColorResource
        let light: String
        let dark: String
    }

    let tokens: [Token] = [
        Token(name: "background", resource: .background, light: "F2F4F8", dark: "0B1019"),
        Token(name: "accent", resource: .accent, light: "0068D8", dark: "78B8FF"),
        Token(name: "on-accent", resource: .onAccent, light: "FFFFFF", dark: "08192B"),
        Token(name: "error", resource: .error, light: "C52F3F", dark: "FF7E86"),
        Token(name: "separator", resource: .separatorLine, light: "E3E8F0", dark: "293447"),
        Token(name: "text/primary", resource: .Text.primary, light: "152538", dark: "F4F7FC"),
        Token(name: "text/secondary", resource: .Text.secondary, light: "5F6F82", dark: "A6B4C7"),
        Token(name: "surface/card", resource: .Surface.card, light: "FFFFFF", dark: "171F2C"),
        Token(name: "surface/field", resource: .Surface.field, light: "E7EBF1", dark: "1B2534"),
        Token(name: "surface/selected", resource: .Surface.selected, light: "D6E8FF", dark: "263D5C"),
        Token(name: "weather/card", resource: .Weather.card, light: "FFFFFF", dark: "1B2F48"),
        Token(name: "weather/text", resource: .Weather.text, light: "142E44", dark: "F5F8FF"),
        Token(name: "weather/secondary", resource: .Weather.secondary, light: "304A60", dark: "D7E3F3"),
        Token(name: "weather/sun", resource: .Weather.sun, light: "D39618", dark: "FFD271"),
        Token(name: "weather/night-card", resource: .Weather.nightCard, light: "243B5C", dark: "132138"),
        Token(name: "weather/night-accent", resource: .Weather.nightAccent, light: "78B8FF", dark: "78B8FF"),
        Token(name: "weather/on-night", resource: .Weather.onNight, light: "F5F8FF", dark: "F5F8FF"),
        Token(name: "weather/night-secondary", resource: .Weather.nightSecondary, light: "DFE8F8", dark: "DFE8F8"),
        Token(name: "weather/clear/day/start", resource: .Weather.Clear.dayStart, light: "A9D5F4", dark: "142C4B"),
        Token(name: "weather/clear/day/end", resource: .Weather.Clear.dayEnd, light: "EDF5FC", dark: "233F5E"),
        Token(name: "weather/clear/night/start", resource: .Weather.Clear.nightStart, light: "142849", dark: "0A1328"),
        Token(name: "weather/clear/night/end", resource: .Weather.Clear.nightEnd, light: "344B70", dark: "1C2C49"),
        Token(name: "weather/overcast/day/start", resource: .Weather.Overcast.dayStart, light: "C6DCEB", dark: "1C3048"),
        Token(name: "weather/overcast/day/end", resource: .Weather.Overcast.dayEnd, light: "EFF4F7", dark: "31485E"),
        Token(name: "weather/overcast/night/start", resource: .Weather.Overcast.nightStart, light: "263448", dark: "101B2C"),
        Token(name: "weather/overcast/night/end", resource: .Weather.Overcast.nightEnd, light: "44566D", dark: "26364A"),
        Token(name: "weather/snow/day/start", resource: .Weather.Snow.dayStart, light: "D7E5F2", dark: "283E59"),
        Token(name: "weather/snow/day/end", resource: .Weather.Snow.dayEnd, light: "F5F8FD", dark: "3A526B"),
        Token(name: "weather/snow/night/start", resource: .Weather.Snow.nightStart, light: "29364F", dark: "141F36"),
        Token(name: "weather/snow/night/end", resource: .Weather.Snow.nightEnd, light: "4B5B76", dark: "2D3E58"),
        Token(name: "weather/storm/day/start", resource: .Weather.Storm.dayStart, light: "AAB9D2", dark: "252E49"),
        Token(name: "weather/storm/day/end", resource: .Weather.Storm.dayEnd, light: "D6DFEC", dark: "3A4561"),
        Token(name: "weather/storm/night/start", resource: .Weather.Storm.nightStart, light: "282B48", dark: "14172B"),
        Token(name: "weather/storm/night/end", resource: .Weather.Storm.nightEnd, light: "494C6F", dark: "2D3050"),
        Token(name: "wind/badge-text", resource: .Wind.badgeText, light: "163953", dark: "EDF5FF"),
        Token(name: "wind/strong-value", resource: .Wind.strongValue, light: "0058B8", dark: "A9D2FF"),
    ]

    @Test func lightValuesMatchFigma() {
        for token in tokens {
            #expect(hex(of: token.resource, in: .light) == token.light, "\(token.name)")
        }
    }

    @Test func darkValuesMatchFigma() {
        for token in tokens {
            #expect(hex(of: token.resource, in: .dark) == token.dark, "\(token.name)")
        }
    }

    private func hex(of resource: ColorResource, in style: UIUserInterfaceStyle) -> String {
        let color = UIColor(resource: resource)
            .resolvedColor(with: UITraitCollection(userInterfaceStyle: style))
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [red, green, blue]
            .map { String(format: "%02X", Int(($0 * 255).rounded())) }
            .joined()
    }
}
