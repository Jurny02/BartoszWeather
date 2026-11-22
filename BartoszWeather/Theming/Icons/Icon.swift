import SwiftUI

/// Every SF Symbol used in the Figma design, so symbol names are checked by the compiler.
nonisolated public enum Icon: String, CaseIterable, Sendable {
    case magnifyingGlass = "magnifyingglass"
    case xmarkCircleFill = "xmark.circle.fill"
    case chevronLeft = "chevron.left"
    case chevronRight = "chevron.right"
    case arrowClockwise = "arrow.clockwise"
    case trash = "trash"
    case clock = "clock"
    case clockBadgeExclamationmark = "clock.badge.exclamationmark"
    case hourglass = "hourglass"
    case wifiSlash = "wifi.slash"
    case antennaRadiowavesLeftAndRight = "antenna.radiowaves.left.and.right"
    case exclamationmarkTriangle = "exclamationmark.triangle"
    case exclamationmarkTriangleFill = "exclamationmark.triangle.fill"
    case exclamationmarkIcloud = "exclamationmark.icloud"
    case dropFill = "drop.fill"
    case humidityFill = "humidity.fill"
    case wind = "wind"
    case locationNorthFill = "location.north.fill"
    case sunMaxFill = "sun.max.fill"
    case moonStarsFill = "moon.stars.fill"
    case cloudSunFill = "cloud.sun.fill"
    case cloudMoonFill = "cloud.moon.fill"
    case cloudFill = "cloud.fill"
    case cloudFogFill = "cloud.fog.fill"
    case cloudDrizzleFill = "cloud.drizzle.fill"
    case cloudRainFill = "cloud.rain.fill"
    case cloudHeavyrainFill = "cloud.heavyrain.fill"
    case cloudSunRainFill = "cloud.sun.rain.fill"
    case cloudMoonRainFill = "cloud.moon.rain.fill"
    case cloudSleetFill = "cloud.sleet.fill"
    case cloudSnowFill = "cloud.snow.fill"
    case cloudBoltRainFill = "cloud.bolt.rain.fill"
    case cloudHailFill = "cloud.hail.fill"
}

extension Image {
    public init(icon: Icon) {
        self.init(systemName: icon.rawValue)
    }
}

#Preview {
    ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 96))], spacing: Spacing.medium) {
            ForEach(Icon.allCases, id: \.self) { icon in
                VStack(spacing: Spacing.xSmall) {
                    Image(icon: icon)
                        .font(.title2)
                        .foregroundStyle(Color(.Text.primary))
                    Text(icon.rawValue)
                        .typography(.caption)
                        .foregroundStyle(Color(.Text.secondary))
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(Spacing.medium)
    }
    .background(Color(.background))
}
