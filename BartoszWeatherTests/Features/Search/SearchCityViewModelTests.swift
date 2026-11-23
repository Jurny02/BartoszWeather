import Testing
@testable import BartoszWeather

/// Tests the search screen's state as the query changes, searches answer and the user retries or picks a city.
struct SearchCityViewModelTests {
    private let clock = ImmediateClock()

    private func makeViewModel(
        service: FakeCitySearchService,
        onSelectCity: @escaping (City) -> Void = { _ in }
    ) -> SearchCityViewModel {
        SearchCityViewModel(service: service, clock: clock, onSelectCity: onSelectCity)
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

    @Test func reportsTheSelectedCity() {
        var selected: [City] = []
        let viewModel = makeViewModel(service: FakeCitySearchService(cities: [])) { selected.append($0) }

        viewModel.select(.hel)

        #expect(selected == [.hel])
    }
}
