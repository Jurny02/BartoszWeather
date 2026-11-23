import Observation
import os

/// Owns the search screen's state: validates the typed text, searches cities after a debounce,
/// shows and edits the search history while nothing is searched, and reports the chosen city for navigation.
@Observable
public final class SearchCityViewModel {
    public var query = "" {
        didSet {
            guard cityQuery != CityQuery(oldValue) else { return }
            content = content(for: cityQuery)
        }
    }

    /// The query as it is searched: normalized and classified. Edits that leave it unchanged keep the results.
    public var cityQuery: CityQuery {
        CityQuery(query)
    }

    public private(set) var content = SearchCityContent.prompt

    private let service: any CitySearchService
    private let clock: any Clock<Duration>
    private let debounce: Duration
    private let history: any SearchHistoryRepository
    private let onSelectCity: (City) -> Void
    private let logger = Logger(subsystem: "com.jurny02.BartoszWeather", category: "Search")
    private var historyEntries: [SearchHistoryEntry] = []
    private var historyVersion = 0

    public init(
        service: any CitySearchService,
        clock: any Clock<Duration>,
        debounce: Duration = .milliseconds(350),
        history: any SearchHistoryRepository,
        onSelectCity: @escaping (City) -> Void
    ) {
        self.service = service
        self.clock = clock
        self.debounce = debounce
        self.history = history
        self.onSelectCity = onSelectCity
    }

    /// Searches the current query once the debounce has passed, unless it is already answered.
    ///
    /// Call it again for every change of `cityQuery` and cancel the previous call:
    /// a cancelled search stops without changing `content`, so calling `search()` later finishes it.
    public func search() async {
        guard case .valid = cityQuery, content == .loading else { return }
        do {
            try await clock.sleep(for: debounce)
        } catch {
            return
        }
        await fetch()
    }

    /// Searches the current query again at once, after a failure.
    public func retry() async {
        await fetch()
    }

    /// Clears the query, so the screen starts over with the last loaded history or the prompt;
    /// a search still in flight is ignored when it answers.
    public func resetSearch() {
        query = ""
    }

    /// Reads the search history and shows it while nothing is searched.
    ///
    /// A failed read is logged and leaves no history, so the prompt shows instead of an error.
    /// A cancelled load, or one overtaken by a newer load or edit, changes nothing.
    public func loadHistory() async {
        let version = nextHistoryVersion()
        let entries: [SearchHistoryEntry]
        do {
            entries = try await history.entries()
        } catch is CancellationError {
            return
        } catch {
            logger.error("Loading the search history failed: \(error, privacy: .public)")
            entries = []
        }
        guard !Task.isCancelled, version == historyVersion else { return }
        showHistory(entries)
    }

    /// Removes the entry from the shown history at once and then from the store.
    ///
    /// When the store cannot be written, the failure is logged and the history is read again.
    public func deleteHistoryEntry(_ entry: SearchHistoryEntry) async {
        nextHistoryVersion()
        showHistory(historyEntries.filter { $0.id != entry.id })
        do {
            try await history.remove(cityID: entry.id)
        } catch {
            logger.error("Deleting a search history entry failed: \(error, privacy: .public)")
            await loadHistory()
        }
    }

    /// Empties the shown history at once and then the store.
    ///
    /// When the store cannot be written, the failure is logged and the history is read again.
    public func clearHistory() async {
        nextHistoryVersion()
        showHistory([])
        do {
            try await history.removeAll()
        } catch {
            logger.error("Clearing the search history failed: \(error, privacy: .public)")
            await loadHistory()
        }
    }

    public func select(_ city: City) {
        onSelectCity(city)
    }

    private func fetch() async {
        guard case .valid(let text) = cityQuery else { return }
        content = .loading
        let newContent: SearchCityContent
        do {
            let cities = try await service.cities(matching: text)
            newContent = cities.isEmpty ? .noResults(query: text) : .results(query: text, cities: cities)
        } catch is CancellationError {
            return
        } catch {
            newContent = SearchCityContent(error: error)
        }
        guard !Task.isCancelled, cityQuery == .valid(text) else { return }
        content = newContent
    }

    @discardableResult
    private func nextHistoryVersion() -> Int {
        historyVersion += 1
        return historyVersion
    }

    private func showHistory(_ entries: [SearchHistoryEntry]) {
        historyEntries = entries
        switch cityQuery {
        case .empty, .tooShort: content = content(for: cityQuery)
        case .invalid, .valid: break
        }
    }

    private func content(for query: CityQuery) -> SearchCityContent {
        switch query {
        case .empty, .tooShort: historyEntries.isEmpty ? .prompt : .history(historyEntries)
        case .invalid: .invalidInput
        case .valid: .loading
        }
    }
}
