import SwiftUI

extension EnvironmentValues {
    /// The moment the forecast screen treats as "now", so day names such as "Today" follow it.
    @Entry var forecastNow: Date = .now
}
