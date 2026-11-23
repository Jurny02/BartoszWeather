import Observation

/// What the forecast screen shows.
nonisolated public enum ForecastScreenState: Hashable, Sendable {
    /// No forecast yet; the first load is in flight or was cut off.
    case loading
    /// A forecast, with the issue that stopped the last refresh, if any.
    case loaded(Forecast, issue: ForecastIssue?)
    /// The first load failed and nothing can be shown.
    case failed(ForecastIssue)
}

/// Owns the forecast screen's state for one city: the first load, retries after a failure and pull-to-refresh.
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

    /// Loads the forecast while the screen is still loading; a cancelled load can be finished by calling it again.
    /// Does nothing once a forecast is shown or the load has failed.
    public func load() async {
        guard state == .loading else { return }
        await fetch()
    }

    /// Shows the loading state and loads the forecast again.
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
            newState = .failed(ForecastIssue(error: error))
        }
        commit(newState, for: request)
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
