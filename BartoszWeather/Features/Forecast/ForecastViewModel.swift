import Observation

/// What the forecast screen shows.
nonisolated public enum ForecastScreenState: Hashable, Sendable {
    /// No forecast yet; the first load is in flight or was cut off.
    case loading
    /// A forecast, with the issue that stopped the last load or refresh, if any.
    /// After a failed load, the forecast is the city's stored one.
    case loaded(Forecast, issue: ForecastIssue?)
    /// The first load failed and no stored forecast can be shown.
    case failed(ForecastIssue)
}

/// Owns the forecast screen's state for one city: the first load, retries after a failure and pull-to-refresh.
/// When a load fails, the city's stored forecast is shown with the issue, if there is one.
///
/// Only the most recently started load or refresh changes the state; a cancelled or superseded one never does.
/// A cancelled request still supersedes the older ones, so the next call to `load()` or `retry()` finishes the work.
@Observable
public final class ForecastViewModel {
    public let city: City
    public private(set) var state = ForecastScreenState.loading

    private let repository: any ForecastRepository
    private var latestRequest = 0

    public init(city: City, repository: any ForecastRepository) {
        self.city = city
        self.repository = repository
    }

    /// Loads the forecast while the screen is still loading, falling back to the stored forecast if that fails;
    /// a cancelled load can be finished by calling it again.
    /// Does nothing once a forecast is shown or the load has failed.
    public func load() async {
        guard state == .loading else { return }
        await fetch()
    }

    /// Shows the loading state and loads the forecast again, falling back to the stored forecast if that fails.
    public func retry() async {
        state = .loading
        await fetch()
    }

    /// Reloads a shown forecast. A failure keeps the forecast and reports the issue alongside it.
    /// Does nothing before a forecast is loaded.
    public func refresh() async {
        guard case .loaded(let forecast, _) = state else { return }
        let request = startRequest()
        let newState: ForecastScreenState
        do {
            newState = .loaded(try await repository.forecast(for: city), issue: nil)
        } catch is CancellationError {
            return
        } catch {
            newState = .loaded(forecast, issue: ForecastIssue(error: error))
        }
        commit(newState, for: request)
    }

    private func fetch() async {
        let request = startRequest()
        let newState: ForecastScreenState
        do {
            newState = .loaded(try await repository.forecast(for: city), issue: nil)
        } catch is CancellationError {
            return
        } catch {
            newState = await fallbackState(after: error)
        }
        commit(newState, for: request)
    }

    private func fallbackState(after error: any Error) async -> ForecastScreenState {
        let issue = ForecastIssue(error: error)
        guard let cached = await repository.cachedForecast(for: city) else {
            return .failed(issue)
        }
        return .loaded(cached, issue: issue)
    }

    private func startRequest() -> Int {
        latestRequest += 1
        return latestRequest
    }

    private func commit(_ newState: ForecastScreenState, for request: Int) {
        guard !Task.isCancelled, request == latestRequest else { return }
        state = newState
    }
}
