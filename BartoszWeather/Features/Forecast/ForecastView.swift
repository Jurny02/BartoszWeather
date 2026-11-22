import SwiftUI

/// The forecast screen for one city: current conditions, metrics, the next hours and the next days.
struct ForecastView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private let city: City
    private let forecast: Forecast
    private let now: Date

    init(city: City, forecast: Forecast, now: Date = .now) {
        self.city = city
        self.forecast = forecast
        self.now = now
    }

    var body: some View {
        let current = forecast.current
        let appearance = WeatherAppearance(isDay: current.isDay)
        ScrollView {
            VStack(spacing: Spacing.small) {
                CurrentWeatherHeader(city: city, current: current)
                metrics(for: current)
                hourlyCard
                dailyCard
                attribution(appearance: appearance)
            }
            .padding(.horizontal, Spacing.large)
            .padding(.top, Spacing.xSmall)
            .padding(.bottom, Spacing.small)
        }
        .background {
            Sky(condition: current.condition).gradient(isNight: !current.isDay).ignoresSafeArea()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(current.isDay ? nil : .dark, for: .navigationBar)
        .environment(\.timeZone, forecast.timeZone)
        .environment(\.weatherAppearance, appearance)
        .environment(\.forecastNow, now)
    }

    private func metrics(for current: CurrentWeather) -> some View {
        let columnCount = dynamicTypeSize.isAccessibilitySize ? 1 : 2
        return LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.small), count: columnCount),
            spacing: Spacing.small
        ) {
            ForEach(WeatherMetric.metrics(for: current)) { metric in
                MetricTile(metric: metric)
            }
        }
    }

    private var hourlyCard: some View {
        let hours = forecast.hours(from: now, count: 24)
        return ForecastCard(title: "Next hours", detail: WeatherFormatter.hourCount(hours.count)) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: Spacing.xSmall) {
                    ForEach(hours) { hour in
                        HourlyCell(hour: hour, isNow: hour.id == hours.first?.id)
                    }
                }
            }
        }
    }

    private var dailyCard: some View {
        let range = DailyForecast.temperatureRange(of: forecast.daily)
        return ForecastCard(title: "Next days") {
            VStack(spacing: Spacing.small) {
                ForEach(forecast.daily) { day in
                    DailyRow(day: day, temperatureRange: range)
                }
            }
        }
    }

    private func attribution(appearance: WeatherAppearance) -> some View {
        VStack(spacing: Spacing.xxSmall) {
            Text("Weather data by Open-Meteo.com")
            Text(WeatherFormatter(timeZone: forecast.timeZone).updated(forecast.updatedAt))
        }
        .typography(.caption)
        .foregroundStyle(Color(appearance.secondaryText))
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG
#Preview("Day") {
    NavigationStack {
        ForecastView(city: .krakow, forecast: .krakowDay, now: Forecast.krakowNow)
    }
}

#Preview("Night") {
    NavigationStack {
        ForecastView(city: .zakopane, forecast: .zakopaneNight, now: Forecast.zakopaneNow)
    }
}

#Preview("Strong wind") {
    NavigationStack {
        ForecastView(city: .hel, forecast: .helStrongWind, now: Forecast.helNow)
    }
}

#Preview("Partial data") {
    NavigationStack {
        ForecastView(city: .krakow, forecast: .partialData, now: Forecast.krakowNow)
    }
}

#Preview("Dark") {
    NavigationStack {
        ForecastView(city: .krakow, forecast: .krakowDay, now: Forecast.krakowNow)
    }
    .preferredColorScheme(.dark)
}

#Preview("Large Dynamic Type") {
    NavigationStack {
        ForecastView(city: .krakow, forecast: .krakowDay, now: Forecast.krakowNow)
    }
    .dynamicTypeSize(.accessibility3)
}
#endif
