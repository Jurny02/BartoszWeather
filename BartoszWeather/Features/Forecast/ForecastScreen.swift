import SwiftUI

/// Shows the forecast view model's state: loading, a full-screen error with a retry,
/// or the forecast with pull-to-refresh and a status line when the last refresh failed.
///
/// A retry is cancelled when the screen disappears, like the first load.
struct ForecastScreen: View {
    @State private var viewModel: ForecastViewModel
    @State private var retryTask: Task<Void, Never>?
    private let now: Date?

    /// - Parameter now: The moment the hourly forecast starts from; `nil` uses the current time on every render.
    ///   Previews pass the fixture's own time.
    init(viewModel: ForecastViewModel, now: Date? = nil) {
        _viewModel = State(initialValue: viewModel)
        self.now = now
    }

    var body: some View {
        content
            .task {
                await viewModel.load()
            }
            .onDisappear {
                retryTask?.cancel()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            loadingView
        case .failed(let issue):
            failedView(issue.message)
        case .loaded(let forecast, let issue):
            ForecastView(city: viewModel.city, forecast: forecast, now: now ?? .now)
                .refreshable {
                    await viewModel.refresh()
                }
                .safeAreaInset(edge: .top) {
                    if let issue {
                        statusLine(issue, forecast: forecast)
                    }
                }
        }
    }

    private var loadingView: some View {
        VStack(spacing: Spacing.small) {
            ProgressView()
            Text("Loading forecast…")
                .typography(.footnote)
                .foregroundStyle(Color(.Text.secondary))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.background).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    private func failedView(_ message: ForecastStateMessage) -> some View {
        ScrollView {
            StateView(icon: message.icon, title: message.title, message: message.message) {
                RetryButton(action: retry)
            }
            .padding(.horizontal, Spacing.large)
            .frame(maxWidth: .infinity)
            .containerRelativeFrame(.vertical)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(.background).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    private func statusLine(_ issue: ForecastIssue, forecast: Forecast) -> some View {
        Label {
            Text(issue.statusText(lastUpdated: forecast.updatedAt, timeZone: forecast.timeZone))
        } icon: {
            Image(icon: issue.statusIcon)
        }
        .typography(.footnote)
        .foregroundStyle(Color(.Text.primary))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.medium)
        .padding(.vertical, Spacing.xSmall)
        .background(.regularMaterial, in: .rect(cornerRadius: Radius.medium))
        .padding(.horizontal, Spacing.large)
    }

    private func retry() {
        retryTask?.cancel()
        retryTask = Task { await viewModel.retry() }
    }
}

#if DEBUG
#Preview("Loaded") {
    NavigationStack {
        ForecastScreen(
            viewModel: ForecastViewModel(city: .krakow, service: PreviewForecastService(result: .success(.krakowDay))),
            now: Forecast.krakowNow
        )
    }
}

#Preview("Offline") {
    NavigationStack {
        ForecastScreen(viewModel: ForecastViewModel(city: .krakow, service: PreviewForecastService(result: .failure(.offline))))
    }
}

#Preview("Service unavailable") {
    NavigationStack {
        ForecastScreen(viewModel: ForecastViewModel(
            city: .krakow,
            service: PreviewForecastService(result: .failure(.server(status: 503, reason: nil)))
        ))
    }
}
#endif
