import Observation

/// Owns the search screen's state: validates the typed text, searches cities after a debounce
/// and reports the chosen city for navigation.
@Observable
public final class SearchCityViewModel {
    public var query = "" {
        didSet {
            guard cityQuery != CityQuery(oldValue) else { return }
            content = Self.content(for: cityQuery)
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
    private let onSelectCity: (City) -> Void

    public init(
        service: any CitySearchService,
        clock: any Clock<Duration>,
        debounce: Duration = .milliseconds(350),
        onSelectCity: @escaping (City) -> Void
    ) {
        self.service = service
        self.clock = clock
        self.debounce = debounce
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

    private static func content(for query: CityQuery) -> SearchCityContent {
        switch query {
        case .empty, .tooShort: .prompt
        case .invalid: .invalidInput
        case .valid: .loading
        }
    }
}
