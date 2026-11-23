import Testing
@testable import BartoszWeather

/// Tests which phase of the forecast screen each state belongs to.
struct ForecastScreenStateTests {
    @Test func loadingBelongsToTheLoadingPhase() {
        #expect(ForecastScreenState.loading.phase == .loading)
    }

    @Test func aFailedLoadBelongsToTheFailedPhase() {
        #expect(ForecastScreenState.failed(.offline).phase == .failed)
    }

    @Test func aForecastBelongsToTheLoadedPhaseWithOrWithoutAnIssue() {
        #expect(ForecastScreenState.loaded(.krakowDay, issue: nil).phase == .loaded)
        #expect(ForecastScreenState.loaded(.krakowDay, issue: .offline).phase == .loaded)
    }

    @Test func keepsThePhaseWhenARefreshReplacesTheForecast() {
        let before = ForecastScreenState.loaded(.krakowDay, issue: nil)
        let after = ForecastScreenState.loaded(.zakopaneNight, issue: .offline)

        #expect(before.phase == after.phase)
    }
}
