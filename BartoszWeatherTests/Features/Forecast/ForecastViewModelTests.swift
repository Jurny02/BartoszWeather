import Testing
@testable import BartoszWeather

/// Tests the forecast screen's state as the forecast loads, fails, is retried and is refreshed.
struct ForecastViewModelTests {
    @Test func startsLoading() {
        let viewModel = ForecastViewModel(city: .krakow, service: FakeForecastService(forecast: .krakowDay))

        #expect(viewModel.city == .krakow)
        #expect(viewModel.state == .loading)
    }

    @Test func loadsTheForecastOfItsCity() async {
        let service = FakeForecastService(forecast: .krakowDay)
        let viewModel = ForecastViewModel(city: .krakow, service: service)

        await viewModel.load()

        #expect(service.requestedCities == [.krakow])
        #expect(viewModel.state == .loaded(.krakowDay, issue: nil))
    }

    @Test(arguments: [
        (APIError.offline, ForecastIssue.offline),
        (.server(status: 429, reason: nil), .rateLimited),
        (.server(status: 503, reason: nil), .serviceUnavailable),
        (.server(status: 400, reason: nil), .failure),
    ])
    func reportsAFailedLoad(error: APIError, issue: ForecastIssue) async {
        let viewModel = ForecastViewModel(city: .krakow, service: FakeForecastService(error: error))

        await viewModel.load()

        #expect(viewModel.state == .failed(issue))
    }

    @Test func loadsOnlyOnce() async {
        let service = FakeForecastService(forecast: .krakowDay)
        let viewModel = ForecastViewModel(city: .krakow, service: service)

        await viewModel.load()
        await viewModel.load()

        #expect(service.requestedCities == [.krakow])
    }

    @Test func waitsForARetryAfterAFailedLoad() async {
        let service = FakeForecastService(results: [.failure(.offline), .success(.krakowDay)])
        let viewModel = ForecastViewModel(city: .krakow, service: service)

        await viewModel.load()
        await viewModel.load()

        #expect(service.requestedCities == [.krakow])
        #expect(viewModel.state == .failed(.offline))
    }

    @Test func retriesAFailedLoad() async {
        let service = FakeForecastService(results: [.failure(.offline), .success(.krakowDay)])
        let viewModel = ForecastViewModel(city: .krakow, service: service)
        await viewModel.load()

        await viewModel.retry()

        #expect(viewModel.state == .loaded(.krakowDay, issue: nil))
    }

    @Test func showsLoadingWhileRetrying() async {
        let service = FakeForecastService(results: [.failure(.offline), .success(.krakowDay)], holdsResponses: true)
        let viewModel = ForecastViewModel(city: .krakow, service: service)
        let load = Task { await viewModel.load() }
        _ = await service.nextRequest()
        service.releaseResponse()
        await load.value

        let retry = Task { await viewModel.retry() }
        _ = await service.nextRequest()
        #expect(viewModel.state == .loading)
        service.releaseResponse()
        await retry.value

        #expect(viewModel.state == .loaded(.krakowDay, issue: nil))
    }

    @Test func refreshReplacesTheForecast() async {
        let service = FakeForecastService(results: [.success(.krakowDay), .success(.partialData)])
        let viewModel = ForecastViewModel(city: .krakow, service: service)
        await viewModel.load()

        await viewModel.refresh()

        #expect(viewModel.state == .loaded(.partialData, issue: nil))
    }

    @Test(arguments: [
        (APIError.offline, ForecastIssue.offline),
        (.server(status: 503, reason: nil), .serviceUnavailable),
    ])
    func keepsTheForecastWhenARefreshFails(error: APIError, issue: ForecastIssue) async {
        let service = FakeForecastService(results: [.success(.krakowDay), .failure(error)])
        let viewModel = ForecastViewModel(city: .krakow, service: service)
        await viewModel.load()

        await viewModel.refresh()

        #expect(viewModel.state == .loaded(.krakowDay, issue: issue))
    }

    @Test func clearsTheIssueAfterASuccessfulRefresh() async {
        let service = FakeForecastService(results: [.success(.krakowDay), .failure(.offline), .success(.partialData)])
        let viewModel = ForecastViewModel(city: .krakow, service: service)
        await viewModel.load()
        await viewModel.refresh()

        await viewModel.refresh()

        #expect(viewModel.state == .loaded(.partialData, issue: nil))
    }

    @Test func doesNotRefreshBeforeAForecastIsLoaded() async {
        let service = FakeForecastService(forecast: .krakowDay)
        let viewModel = ForecastViewModel(city: .krakow, service: service)

        await viewModel.refresh()

        #expect(service.requestedCities.isEmpty)
        #expect(viewModel.state == .loading)
    }

    @Test func keepsLoadingWhenTheLoadIsCancelledAndFinishesItLater() async {
        let service = FakeForecastService(forecast: .krakowDay, holdsResponses: true)
        let viewModel = ForecastViewModel(city: .krakow, service: service)
        let load = Task { await viewModel.load() }
        _ = await service.nextRequest()

        load.cancel()
        await load.value
        #expect(viewModel.state == .loading)

        await viewModel.load()
        #expect(viewModel.state == .loaded(.krakowDay, issue: nil))
    }

    @Test func keepsLoadingWhenACancelledLoadFailsAnyway() async {
        let service = FakeForecastService(error: .offline, holdsResponses: true, checksCancellation: false)
        let viewModel = ForecastViewModel(city: .krakow, service: service)
        let load = Task { await viewModel.load() }
        _ = await service.nextRequest()

        load.cancel()
        await load.value

        #expect(viewModel.state == .loading)
    }

    @Test func keepsTheForecastWithoutAnIssueWhenARefreshIsCancelled() async {
        let service = FakeForecastService(
            results: [.success(.krakowDay), .failure(.offline)], holdsResponses: true, checksCancellation: false
        )
        let viewModel = ForecastViewModel(city: .krakow, service: service)
        let load = Task { await viewModel.load() }
        _ = await service.nextRequest()
        service.releaseResponse()
        await load.value

        let refresh = Task { await viewModel.refresh() }
        _ = await service.nextRequest()
        refresh.cancel()
        await refresh.value

        #expect(viewModel.state == .loaded(.krakowDay, issue: nil))
    }
}
