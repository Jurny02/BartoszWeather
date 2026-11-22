import SwiftUI

/// The top of the forecast screen: city, current temperature, condition and feels-like temperature.
struct CurrentWeatherHeader: View {
    @Environment(\.weatherAppearance) private var appearance
    private let city: City
    private let current: CurrentWeather

    init(city: City, current: CurrentWeather) {
        self.city = city
        self.current = current
    }

    var body: some View {
        VStack(spacing: Spacing.xxSmall) {
            Text(city.name)
                .typography(.cityTitle)
                .foregroundStyle(Color(appearance.text))
            if let regionAndCountry = city.regionAndCountry {
                Text(regionAndCountry)
                    .typography(.footnote)
                    .foregroundStyle(Color(appearance.secondaryText))
            }
            HStack(spacing: Spacing.small) {
                WeatherSymbol(icon: current.condition.icon(isDay: current.isDay), size: 76, relativeTo: .largeTitle)
                Text(current.temperatureText)
                    .typography(.heroTemperature)
                    .foregroundStyle(Color(appearance.text))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            Text(current.condition.localizedDescription)
                .typography(.headline)
                .foregroundStyle(Color(appearance.text))
            if current.showsStrongWindBadge {
                StrongWindBadge()
            }
            Text(current.feelsLikeText)
                .typography(.footnote)
                .foregroundStyle(Color(appearance.secondaryText))
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(current.accessibilityLabel(city: city))
    }
}
