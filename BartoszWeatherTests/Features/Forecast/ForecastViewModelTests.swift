import Testing
@testable import BartoszWeather

/// Tests the forecast screen's state as the forecast loads, fails, is retried and is refreshed.
struct ForecastViewModelTests {
    @Test func startsLoading() {
        let viewModel = ForecastViewModel(city: .krakow, repository: FakeForecastRepository(forecast: .krakowDay))

        #expect(viewModel.city == .krakow)
        #expect(viewModel.state == .loading)
    }

    @Test func loadsTheForecastOfItsCity() async {
        let repository = FakeForecastRepository(forecast: .krakowDay)
        let viewModel = ForecastViewModel(city: .krakow, repository: repository)

        await viewModel.load()

        #expect(repository.requestedCities == [.krakow])
        #expect(viewModel.state == .loaded(.krakowDay, issue: nil))
    }

    @Test(arguments: [
        (APIError.offline, ForecastIssue.offline),
        (.server(status: 429, reason: nil), .rateLimited),
        (.server(status: 503, reason: nil), .serviceUnavailable),
        (.server(status: 400, reason: nil), .failure),
    ])
    func reportsAFailedLoad(error: APIError, issue: ForecastIssue) async {
        let viewModel = ForecastViewModel(city: .krakow, repository: FakeForecastRepository(error: error))

        await viewModel.load()

        #expect(viewModel.state == .failed(issue))
    }

    @Test(arguments: [
        (APIError.offline, ForecastIssue.offline),
        (.server(status: 503, reason: nil), .serviceUnavailable),
    ])
    func showsTheStoredForecastWhenTheFirstLoadFails(error: APIError, issue: ForecastIssue) async {
        let repository = FakeForecastRepository(error: error, cached: .krakowDay)
        let viewModel = ForecastViewModel(city: .krakow, repository: repository)

        await viewModel.load()

        #expect(repository.cachedForecastRequests == [.krakow])
        #expect(viewModel.state == .loaded(.krakowDay, issue: issue))
    }

    @Test func doesNotLookUpTheStoredForecastAfterASuccessfulLoad() async {
        let repository = FakeForecastRepository(results: [.success(.partialData)], cached: .krakowDay)
        let viewModel = ForecastViewModel(city: .krakow, repository: repository)

        await viewModel.load()

        #expect(repository.cachedForecastRequests.isEmpty)
        #expect(viewModel.state == .loaded(.partialData, issue: nil))
    }

    @Test func keepsTheShownForecastWhenARefreshFails() async {
        let repository = FakeForecastRepository(
            results: [.success(.partialData), .failure(.offline)], cached: .krakowDay
        )
        let viewModel = ForecastViewModel(city: .krakow, repository: repository)
        await viewModel.load()

        await viewModel.refresh()

        #expect(repository.cachedForecastRequests.isEmpty)
        #expect(viewModel.state == .loaded(.partialData, issue: .offline))
    }

    @Test func ignoresTheStoredForecastOfALoadThatARetryReplaced() async {
        let repository = FakeForecastRepository(
            results: [.failure(.offline), .success(.partialData)], cached: .krakowDay, holdsResponses: true
        )
        let viewModel = ForecastViewModel(city: .krakow, repository: repository)
        let load = Task { await viewModel.load() }
        _ = await repository.nextRequest()
        let retry = Task { await viewModel.retry() }
        _ = await repository.nextRequest()

        repository.releaseResponse()
        await load.value
        #expect(viewModel.state == .loading)

        repository.releaseResponse()
        await retry.value
        #expect(viewModel.state == .loaded(.partialData, issue: nil))
    }

    @Test func keepsLoadingWhenACancelledLoadFailsAnywayWithAStoredForecast() async {
        let repository = FakeForecastRepository(
            error: .offline, cached: .krakowDay, holdsResponses: true, checksCancellation: false
        )
        let viewModel = ForecastViewModel(city: .krakow, repository: repository)
        let load = Task { await viewModel.load() }
        _ = await repository.nextRequest()

        load.cancel()
        await load.value

        #expect(viewModel.state == .loading)
    }

    @Test func loadsOnlyOnce() async {
        let repository = FakeForecastRepository(forecast: .krakowDay)
        let viewModel = ForecastViewModel(city: .krakow, repository: repository)

        await viewModel.load()
        await viewModel.load()

        #expect(repository.requestedCities == [.krakow])
    }

    @Test func waitsForARetryAfterAFailedLoad() async {
        let repository = FakeForecastRepository(results: [.failure(.offline), .success(.krakowDay)])
        let viewModel = ForecastViewModel(city: .krakow, repository: repository)

        await viewModel.load()
        await viewModel.load()

        #expect(repository.requestedCities == [.krakow])
        #expect(viewModel.state == .failed(.offline))
    }

    @Test func retriesAFailedLoad() async {
        let repository = FakeForecastRepository(results: [.failure(.offline), .success(.krakowDay)])
        let viewModel = ForecastViewModel(city: .krakow, repository: repository)
        await viewModel.load()

        await viewModel.retry()

        #expect(viewModel.state == .loaded(.krakowDay, issue: nil))
    }

    @Test func showsLoadingWhileRetrying() async {
        let repository = FakeForecastRepository(results: [.failure(.offline), .success(.krakowDay)], holdsResponses: true)
        let viewModel = ForecastViewModel(city: .krakow, repository: repository)
        let load = Task { await viewModel.load() }
        _ = await repository.nextRequest()
        repository.releaseResponse()
        await load.value

        let retry = Task { await viewModel.retry() }
        _ = await repository.nextRequest()
        #expect(viewModel.state == .loading)
        repository.releaseResponse()
        await retry.value

        #expect(viewModel.state == .loaded(.krakowDay, issue: nil))
    }

    @Test func refreshReplacesTheForecast() async {
        let repository = FakeForecastRepository(results: [.success(.krakowDay), .success(.partialData)])
        let viewModel = ForecastViewModel(city: .krakow, repository: repository)
        await viewModel.load()

        await viewModel.refresh()

        #expect(viewModel.state == .loaded(.partialData, issue: nil))
    }

    @Test(arguments: [
        (APIError.offline, ForecastIssue.offline),
        (.server(status: 503, reason: nil), .serviceUnavailable),
    ])
    func keepsTheForecastWhenARefreshFails(error: APIError, issue: ForecastIssue) async {
        let repository = FakeForecastRepository(results: [.success(.krakowDay), .failure(error)])
        let viewModel = ForecastViewModel(city: .krakow, repository: repository)
        await viewModel.load()

        await viewModel.refresh()

        #expect(viewModel.state == .loaded(.krakowDay, issue: issue))
    }

    @Test func clearsTheIssueAfterASuccessfulRefresh() async {
        let repository = FakeForecastRepository(results: [.success(.krakowDay), .failure(.offline), .success(.partialData)])
        let viewModel = ForecastViewModel(city: .krakow, repository: repository)
        await viewModel.load()
        await viewModel.refresh()

        await viewModel.refresh()

        #expect(viewModel.state == .loaded(.partialData, issue: nil))
    }

    @Test func ignoresARefreshThatANewerRefreshReplaced() async {
        let repository = FakeForecastRepository(
            results: [.success(.krakowDay), .failure(.offline), .success(.partialData)], holdsResponses: true
        )
        let viewModel = ForecastViewModel(city: .krakow, repository: repository)
        let load = Task { await viewModel.load() }
        _ = await repository.nextRequest()
        repository.releaseResponse()
        await load.value
        let olderRefresh = Task { await viewModel.refresh() }
        _ = await repository.nextRequest()
        let newerRefresh = Task { await viewModel.refresh() }
        _ = await repository.nextRequest()

        repository.releaseResponse()
        await olderRefresh.value
        #expect(viewModel.state == .loaded(.krakowDay, issue: nil))

        repository.releaseResponse()
        await newerRefresh.value
        #expect(viewModel.state == .loaded(.partialData, issue: nil))
    }

    @Test func keepsNewerDataWhenAnOlderRefreshFailsAfterIt() async {
        let repository = FakeForecastRepository(
            results: [.success(.krakowDay), .failure(.offline), .success(.partialData)], holdsResponses: true
        )
        let viewModel = ForecastViewModel(city: .krakow, repository: repository)
        let load = Task { await viewModel.load() }
        _ = await repository.nextRequest()
        repository.releaseResponse()
        await load.value
        let olderRefresh = Task { await viewModel.refresh() }
        _ = await repository.nextRequest()
        let newerRefresh = Task { await viewModel.refresh() }
        _ = await repository.nextRequest()

        repository.releaseNewestResponse()
        await newerRefresh.value
        repository.releaseResponse()
        await olderRefresh.value

        #expect(viewModel.state == .loaded(.partialData, issue: nil))
    }

    @Test func ignoresARefreshThatARetryReplaced() async {
        let repository = FakeForecastRepository(
            results: [.success(.krakowDay), .success(.partialData), .success(.helStrongWind)], holdsResponses: true
        )
        let viewModel = ForecastViewModel(city: .krakow, repository: repository)
        let load = Task { await viewModel.load() }
        _ = await repository.nextRequest()
        repository.releaseResponse()
        await load.value
        let refresh = Task { await viewModel.refresh() }
        _ = await repository.nextRequest()
        let retry = Task { await viewModel.retry() }
        _ = await repository.nextRequest()

        repository.releaseResponse()
        await refresh.value
        #expect(viewModel.state == .loading)

        repository.releaseResponse()
        await retry.value
        #expect(viewModel.state == .loaded(.helStrongWind, issue: nil))
    }

    @Test func doesNotRefreshBeforeAForecastIsLoaded() async {
        let repository = FakeForecastRepository(forecast: .krakowDay)
        let viewModel = ForecastViewModel(city: .krakow, repository: repository)

        await viewModel.refresh()

        #expect(repository.requestedCities.isEmpty)
        #expect(viewModel.state == .loading)
    }

    @Test func keepsLoadingWhenTheLoadIsCancelledAndFinishesItLater() async {
        let repository = FakeForecastRepository(forecast: .krakowDay, holdsResponses: true)
        let viewModel = ForecastViewModel(city: .krakow, repository: repository)
        let load = Task { await viewModel.load() }
        _ = await repository.nextRequest()

        load.cancel()
        await load.value
        #expect(viewModel.state == .loading)

        let secondLoad = Task { await viewModel.load() }
        _ = await repository.nextRequest()
        repository.releaseResponse()
        await secondLoad.value
        #expect(viewModel.state == .loaded(.krakowDay, issue: nil))
    }

    @Test func keepsLoadingWhenACancelledLoadFailsAnyway() async {
        let repository = FakeForecastRepository(error: .offline, holdsResponses: true, checksCancellation: false)
        let viewModel = ForecastViewModel(city: .krakow, repository: repository)
        let load = Task { await viewModel.load() }
        _ = await repository.nextRequest()

        load.cancel()
        await load.value

        #expect(viewModel.state == .loading)
    }

    @Test func keepsTheForecastWithoutAnIssueWhenARefreshIsCancelled() async {
        let repository = FakeForecastRepository(
            results: [.success(.krakowDay), .failure(.offline)], holdsResponses: true, checksCancellation: false
        )
        let viewModel = ForecastViewModel(city: .krakow, repository: repository)
        let load = Task { await viewModel.load() }
        _ = await repository.nextRequest()
        repository.releaseResponse()
        await load.value

        let refresh = Task { await viewModel.refresh() }
        _ = await repository.nextRequest()
        refresh.cancel()
        await refresh.value

        #expect(viewModel.state == .loaded(.krakowDay, issue: nil))
    }
}
