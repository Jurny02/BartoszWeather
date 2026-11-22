import SwiftUI

/// Public color tokens from the Figma `Color` collection, usable as `Color(.Text.primary)`.
///
/// Xcode generates the asset symbols under `ColorResource.Palette` as `internal`,
/// so this layer is the API other modules see.
extension ColorResource {
    public static let background = Palette.background
    public static let accent = Palette.accent
    public static let onAccent = Palette.onAccent
    public static let error = Palette.error
    public static let separatorLine = Palette.separatorLine

    public enum Text {
        public static let primary = Palette.Text.primary
        public static let secondary = Palette.Text.secondary
    }

    public enum Surface {
        public static let card = Palette.Surface.card
        public static let field = Palette.Surface.field
        public static let selected = Palette.Surface.selected
    }

    public enum Weather {
        public static let card = Palette.Weather.card
        public static let text = Palette.Weather.text
        public static let secondary = Palette.Weather.secondary
        public static let sun = Palette.Weather.sun
        public static let nightCard = Palette.Weather.nightCard
        public static let nightAccent = Palette.Weather.nightAccent
        public static let onNight = Palette.Weather.onNight
        public static let nightSecondary = Palette.Weather.nightSecondary

        public enum Clear {
            public static let dayStart = Palette.Weather.Clear.Day.start
            public static let dayEnd = Palette.Weather.Clear.Day.end
            public static let nightStart = Palette.Weather.Clear.Night.start
            public static let nightEnd = Palette.Weather.Clear.Night.end
        }

        public enum Overcast {
            public static let dayStart = Palette.Weather.Overcast.Day.start
            public static let dayEnd = Palette.Weather.Overcast.Day.end
            public static let nightStart = Palette.Weather.Overcast.Night.start
            public static let nightEnd = Palette.Weather.Overcast.Night.end
        }

        public enum Snow {
            public static let dayStart = Palette.Weather.Snow.Day.start
            public static let dayEnd = Palette.Weather.Snow.Day.end
            public static let nightStart = Palette.Weather.Snow.Night.start
            public static let nightEnd = Palette.Weather.Snow.Night.end
        }

        public enum Storm {
            public static let dayStart = Palette.Weather.Storm.Day.start
            public static let dayEnd = Palette.Weather.Storm.Day.end
            public static let nightStart = Palette.Weather.Storm.Night.start
            public static let nightEnd = Palette.Weather.Storm.Night.end
        }
    }

    public enum Wind {
        public static let badgeText = Palette.Wind.badgeText
        public static let strongValue = Palette.Wind.strongValue
    }
}
