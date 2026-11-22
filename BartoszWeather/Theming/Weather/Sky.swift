import SwiftUI

/// The kind of sky behind the forecast, which selects the screen's background gradient.
public enum Sky: CaseIterable, Sendable {
    case clear
    case overcast
    case snow
    case storm

    /// Creates the sky that matches a weather condition.
    public init(condition: WeatherCondition) {
        self = switch condition {
        case .clearSky, .mainlyClear, .partlyCloudy: .clear
        case .snow, .snowGrains, .snowShowers: .snow
        case .thunderstorm, .thunderstormWithHail: .storm
        case .overcast, .fog, .drizzle, .freezingDrizzle, .rain, .heavyRain, .freezingRain, .rainShowers, .unknown:
            .overcast
        }
    }

    /// Gradient colors from the Figma `Weather/<sky>/<day|night>` variables.
    public func colors(isNight: Bool) -> (start: ColorResource, end: ColorResource) {
        switch (self, isNight) {
        case (.clear, false): (.Weather.Clear.dayStart, .Weather.Clear.dayEnd)
        case (.clear, true): (.Weather.Clear.nightStart, .Weather.Clear.nightEnd)
        case (.overcast, false): (.Weather.Overcast.dayStart, .Weather.Overcast.dayEnd)
        case (.overcast, true): (.Weather.Overcast.nightStart, .Weather.Overcast.nightEnd)
        case (.snow, false): (.Weather.Snow.dayStart, .Weather.Snow.dayEnd)
        case (.snow, true): (.Weather.Snow.nightStart, .Weather.Snow.nightEnd)
        case (.storm, false): (.Weather.Storm.dayStart, .Weather.Storm.dayEnd)
        case (.storm, true): (.Weather.Storm.nightStart, .Weather.Storm.nightEnd)
        }
    }

    /// `true` when the gradient runs corner to corner, as Figma draws it for a clear sky; other skies run top to bottom.
    public var isDiagonal: Bool {
        self == .clear
    }

    public func gradient(isNight: Bool) -> LinearGradient {
        let colors = colors(isNight: isNight)
        return LinearGradient(
            colors: [Color(colors.start), Color(colors.end)],
            startPoint: isDiagonal ? .topLeading : .top,
            endPoint: isDiagonal ? .bottomTrailing : .bottom
        )
    }
}
