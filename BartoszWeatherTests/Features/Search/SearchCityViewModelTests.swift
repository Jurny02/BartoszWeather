import Testing
@testable import BartoszWeather

/// Tests the search screen's state as the query changes, searches answer, the history loads or is edited,
/// and the user retries or picks a city.
struct SearchCityViewModelTests {
    private let clock = ImmediateClock()
    private let krakowEntry = SearchHistoryEntry(city: .krakow, forecast: nil)
    private let helEntry = SearchHistoryEntry(city: .hel, forecast: nil)

    private func makeViewModel(
        service: FakeCitySearchService = FakeCitySearchService(cities: []),
        history: FakeSearchHistoryRepository = FakeSearchHistoryRepository(),
        onSelectCity: @escaping (City) -> Void = { _ in }
    ) -> SearchCityViewModel {
        SearchCityViewModel(service: service, clock: clock, history: history, onSelectCity: onSelectCity)
    }

    @Test func startsWithThePrompt() {
        let viewModel = makeViewModel(service: FakeCitySearchService(cities: []))

        #expect(viewModel.query.isEmpty)
        #expect(viewModel.content == .prompt)
    }

    @Test(arguments: [
        ("", SearchCityContent.prompt),
        ("K", .prompt),
        ("Krak1", .invalidInput),
        ("Krak", .loading),
    ])
    func showsTheStateForTheTypedTextAtOnce(text: String, expected: SearchCityContent) {
        let viewModel = makeViewModel(service: FakeCitySearchService(cities: []))

        viewModel.query = text

        #expect(viewModel.content == expected)
    }

    @Test func searchesTheNormalizedQueryAfterTheDebounce() async {
        let service = FakeCitySearchService(cities: [.krakow])
        let viewModel = makeViewModel(service: service)
        viewModel.query = "  Krak "

        await viewModel.search()

        #expect(clock.sleepDurations == [.milliseconds(350)])
        #expect(service.queries == ["Krak"])
        #expect(viewModel.content == .results(query: "Krak", cities: [.krakow]))
    }

    @Test(arguments: ["", "K", "Krak1"])
    func doesNotSearchTextThatCannotMatch(text: String) async {
        let service = FakeCitySearchService(cities: [.krakow])
        let viewModel = makeViewModel(service: service)
        viewModel.query = text

        await viewModel.search()

        #expect(service.queries.isEmpty)
        #expect(clock.sleepDurations.isEmpty)
    }

    @Test func doesNotSearchAgainWhenTheQueryIsAlreadyAnswered() async {
        let service = FakeCitySearchService(cities: [.krakow])
        let viewModel = makeViewModel(service: service)
        viewModel.query = "Krak"
        await viewModel.search()

        await viewModel.search()

        #expect(service.queries == ["Krak"])
        #expect(viewModel.content == .results(query: "Krak", cities: [.krakow]))
    }

    @Test func keepsTheResultsWhenAnEditLeavesTheNormalizedQueryUnchanged() async {
        let viewModel = makeViewModel(service: FakeCitySearchService(cities: [.krakow]))
        viewModel.query = "Krak"
        await viewModel.search()

        viewModel.query = "Krak  "

        #expect(viewModel.cityQuery == .valid("Krak"))
        #expect(viewModel.content == .results(query: "Krak", cities: [.krakow]))
    }

    @Test func reportsNoResults() async {
        let viewModel = makeViewModel(service: FakeCitySearchService(cities: []))
        viewModel.query = "Xqzzqx"

        await viewModel.search()

        #expect(viewModel.content == .noResults(query: "Xqzzqx"))
    }

    @Test(arguments: [
        (APIError.offline, SearchCityContent.offline),
        (.server(status: 429, reason: nil), .rateLimited),
        (.server(status: 500, reason: nil), .failure),
    ])
    func reportsFailures(error: APIError, expected: SearchCityContent) async {
        let viewModel = makeViewModel(service: FakeCitySearchService(error: error))
        viewModel.query = "Krak"

        await viewModel.search()

        #expect(viewModel.content == expected)
    }

    @Test func retriesWithoutTheDebounce() async {
        let service = FakeCitySearchService(cities: [.krakow])
        let viewModel = makeViewModel(service: service)
        viewModel.query = "Krak"

        await viewModel.retry()

        #expect(clock.sleepDurations.isEmpty)
        #expect(service.queries == ["Krak"])
        #expect(viewModel.content == .results(query: "Krak", cities: [.krakow]))
    }

    @Test func showsLoadingWhileRetrying() async {
        let service = FakeCitySearchService(cities: [.krakow], holdsResponses: true)
        let viewModel = makeViewModel(service: service)
        viewModel.query = "Krak"
        let retry = Task { await viewModel.retry() }

        _ = await service.nextRequest()
        #expect(viewModel.content == .loading)
        service.releaseResponse()
        await retry.value

        #expect(viewModel.content == .results(query: "Krak", cities: [.krakow]))
    }

    @Test func ignoresAnAnswerForAQueryThatChangedMeanwhile() async {
        let service = FakeCitySearchService(cities: [.krakow], holdsResponses: true)
        let viewModel = makeViewModel(service: service)
        viewModel.query = "Krak"
        let search = Task { await viewModel.search() }

        _ = await service.nextRequest()
        viewModel.query = "Krak1"
        service.releaseResponse()
        await search.value

        #expect(viewModel.content == .invalidInput)
    }

    @Test func keepsTheStateWhenTheSearchIsCancelled() async {
        let service = FakeCitySearchService(cities: [.krakow], holdsResponses: true)
        let viewModel = makeViewModel(service: service)
        viewModel.query = "Krak"
        let search = Task { await viewModel.search() }

        _ = await service.nextRequest()
        search.cancel()
        await search.value

        #expect(viewModel.content == .loading)
    }

    @Test func keepsTheStateWhenACancelledSearchFailsAnyway() async {
        let service = FakeCitySearchService(holdsResponses: true, checksCancellation: false) { _ in
            throw APIError.offline
        }
        let viewModel = makeViewModel(service: service)
        viewModel.query = "Krak"
        let search = Task { await viewModel.search() }

        _ = await service.nextRequest()
        search.cancel()
        await search.value

        #expect(viewModel.content == .loading)
    }

    @Test func skipsTheSearchWhenCancelledDuringTheDebounce() async {
        let service = FakeCitySearchService(cities: [.krakow])
        let viewModel = makeViewModel(service: service)
        viewModel.query = "Krak"
        let search = Task { await viewModel.search() }

        search.cancel()
        await search.value

        #expect(service.queries.isEmpty)
        #expect(viewModel.content == .loading)
    }

    @Test func resetFromResultsShowsThePrompt() async {
        let viewModel = makeViewModel(service: FakeCitySearchService(cities: [.krakow]))
        viewModel.query = "Krak"
        await viewModel.search()

        viewModel.resetSearch()

        #expect(viewModel.query.isEmpty)
        #expect(viewModel.content == .prompt)
    }

    @Test func resetFromInvalidInputShowsThePrompt() {
        let viewModel = makeViewModel(service: FakeCitySearchService(cities: []))
        viewModel.query = "Krak1"

        viewModel.resetSearch()

        #expect(viewModel.query.isEmpty)
        #expect(viewModel.content == .prompt)
    }

    @Test func ignoresAnAnswerThatArrivesAfterTheReset() async {
        let service = FakeCitySearchService(cities: [.krakow], holdsResponses: true)
        let viewModel = makeViewModel(service: service)
        viewModel.query = "Krak"
        let search = Task { await viewModel.search() }

        _ = await service.nextRequest()
        viewModel.resetSearch()
        service.releaseResponse()
        await search.value

        #expect(viewModel.content == .prompt)
    }

    @Test func reportsTheSelectedCity() {
        var selected: [City] = []
        let viewModel = makeViewModel { selected.append($0) }

        viewModel.select(.hel)

        #expect(selected == [.hel])
    }

    @Test(arguments: ["", "K"])
    func showsTheHistoryWhileTheQueryCannotBeSearched(text: String) async {
        let viewModel = makeViewModel(history: FakeSearchHistoryRepository(entries: [krakowEntry, helEntry]))
        viewModel.query = text

        await viewModel.loadHistory()

        #expect(viewModel.content == .history([krakowEntry, helEntry]))
    }

    @Test func showsThePromptWithoutHistory() async {
        let viewModel = makeViewModel()

        await viewModel.loadHistory()

        #expect(viewModel.content == .prompt)
    }

    @Test func showsThePromptWhenTheHistoryCannotBeRead() async {
        let viewModel = makeViewModel(history: FakeSearchHistoryRepository(readError: HistoryFailure()))

        await viewModel.loadHistory()

        #expect(viewModel.content == .prompt)
    }

    @Test(arguments: [
        ("Krak", SearchCityContent.loading),
        ("Krak1", .invalidInput),
    ])
    func hidesTheHistoryWhileTyping(text: String, expected: SearchCityContent) async {
        let viewModel = makeViewModel(history: FakeSearchHistoryRepository(entries: [krakowEntry]))
        await viewModel.loadHistory()

        viewModel.query = text

        #expect(viewModel.content == expected)
    }

    @Test func bringsTheHistoryBackWhenTheTextIsClearedWithoutReadingAgain() async {
        let history = FakeSearchHistoryRepository(entries: [krakowEntry])
        let viewModel = makeViewModel(history: history)
        await viewModel.loadHistory()
        viewModel.query = "Krak"

        viewModel.query = ""

        #expect(viewModel.content == .history([krakowEntry]))
        #expect(history.readCount == 1)
    }

    @Test func keepsTheResultsWhenTheHistoryLoadsDuringASearch() async {
        let viewModel = makeViewModel(
            service: FakeCitySearchService(cities: [.krakow]),
            history: FakeSearchHistoryRepository(entries: [krakowEntry])
        )
        viewModel.query = "Krak"
        await viewModel.search()

        await viewModel.loadHistory()

        #expect(viewModel.content == .results(query: "Krak", cities: [.krakow]))
    }

    @Test func showsTheHistoryAfterAResetAndALoad() async {
        let history = FakeSearchHistoryRepository(entries: [krakowEntry])
        let viewModel = makeViewModel(service: FakeCitySearchService(cities: [.krakow]), history: history)
        viewModel.query = "Krak"
        await viewModel.search()
        history.store([helEntry, krakowEntry])

        viewModel.resetSearch()
        await viewModel.loadHistory()

        #expect(viewModel.query.isEmpty)
        #expect(viewModel.content == .history([helEntry, krakowEntry]))
    }

    @Test func showsTheLastLoadedHistoryAtOnceOnAReset() async {
        let viewModel = makeViewModel(history: FakeSearchHistoryRepository(entries: [krakowEntry]))
        await viewModel.loadHistory()
        viewModel.query = "Krak1"

        viewModel.resetSearch()

        #expect(viewModel.content == .history([krakowEntry]))
    }

    @Test func deletesAHistoryEntry() async {
        let history = FakeSearchHistoryRepository(entries: [krakowEntry, helEntry])
        let viewModel = makeViewModel(history: history)
        await viewModel.loadHistory()

        await viewModel.deleteHistoryEntry(krakowEntry)

        #expect(history.removedCityIDs == [City.krakow.id])
        #expect(history.storedEntries == [helEntry])
        #expect(viewModel.content == .history([helEntry]))
    }

    @Test func showsThePromptAfterDeletingTheLastEntry() async {
        let viewModel = makeViewModel(history: FakeSearchHistoryRepository(entries: [krakowEntry]))
        await viewModel.loadHistory()

        await viewModel.deleteHistoryEntry(krakowEntry)

        #expect(viewModel.content == .prompt)
    }

    @Test func reloadsTheHistoryWhenADeleteFails() async {
        let history = FakeSearchHistoryRepository(entries: [krakowEntry, helEntry], writeError: HistoryFailure())
        let viewModel = makeViewModel(history: history)
        await viewModel.loadHistory()

        await viewModel.deleteHistoryEntry(krakowEntry)

        #expect(history.readCount == 2)
        #expect(viewModel.content == .history([krakowEntry, helEntry]))
    }

    @Test func clearsTheHistory() async {
        let history = FakeSearchHistoryRepository(entries: [krakowEntry, helEntry])
        let viewModel = makeViewModel(history: history)
        await viewModel.loadHistory()

        await viewModel.clearHistory()

        #expect(history.removeAllCount == 1)
        #expect(history.storedEntries.isEmpty)
        #expect(viewModel.content == .prompt)
    }

    @Test func reloadsTheHistoryWhenClearingFails() async {
        let history = FakeSearchHistoryRepository(entries: [krakowEntry, helEntry], writeError: HistoryFailure())
        let viewModel = makeViewModel(history: history)
        await viewModel.loadHistory()

        await viewModel.clearHistory()

        #expect(history.readCount == 2)
        #expect(viewModel.content == .history([krakowEntry, helEntry]))
    }

    @Test func ignoresALoadThatStartedBeforeADelete() async {
        let history = FakeSearchHistoryRepository(entries: [krakowEntry, helEntry], holdsReads: true)
        let viewModel = makeViewModel(history: history)
        let firstLoad = Task { await viewModel.loadHistory() }
        await history.nextRead()
        history.releaseRead()
        await firstLoad.value
        let staleLoad = Task { await viewModel.loadHistory() }
        await history.nextRead()

        await viewModel.deleteHistoryEntry(krakowEntry)
        history.store([krakowEntry, helEntry])
        history.releaseRead()
        await staleLoad.value

        #expect(viewModel.content == .history([helEntry]))
    }

    @Test func keepsTheHistoryWhenALoadIsCancelled() async {
        let history = FakeSearchHistoryRepository(entries: [krakowEntry], holdsReads: true)
        let viewModel = makeViewModel(history: history)
        let firstLoad = Task { await viewModel.loadHistory() }
        await history.nextRead()
        history.releaseRead()
        await firstLoad.value
        let cancelledLoad = Task { await viewModel.loadHistory() }
        await history.nextRead()

        cancelledLoad.cancel()
        history.releaseRead()
        await cancelledLoad.value

        #expect(viewModel.content == .history([krakowEntry]))
    }
}

/// A failure of the history store.
private struct HistoryFailure: Error {}
