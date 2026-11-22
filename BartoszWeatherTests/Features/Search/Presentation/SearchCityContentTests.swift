import Testing
@testable import BartoszWeather

/// Tests the validation message, state copy and result count the search screen shows for each content.
struct SearchCityContentTests {
    @Test func showsTheValidationMessageOnlyForInvalidInput() {
        #expect(SearchCityContent.invalidInput.validationMessage == "Only letters, spaces and hyphens are allowed.")
        #expect(SearchCityContent.prompt.validationMessage == nil)
        #expect(SearchCityContent.noResults(query: "Xyz").validationMessage == nil)
    }

    @Test func marksTheFieldInvalidOnlyForInvalidInput() {
        #expect(SearchCityContent.invalidInput.isInputInvalid)
        #expect(!SearchCityContent.loading.isInputInvalid)
    }

    @Test func reservesTheValidationAreaEverywhereButTheHistory() {
        #expect(!SearchCityContent.history([]).reservesValidationArea)
        #expect(SearchCityContent.prompt.reservesValidationArea)
        #expect(SearchCityContent.invalidInput.reservesValidationArea)
        #expect(SearchCityContent.results(query: "Krak", cities: []).reservesValidationArea)
    }

    @Test func invitesTheFirstSearch() throws {
        let message = try #require(SearchCityContent.prompt.stateMessage)
        #expect(message.icon == .cloudSunFill)
        #expect(message.title == "Search for a city to see the weather")
        #expect(message.message == "Your next forecast is a search away.")
        #expect(!message.showsRetry)
    }

    @Test func namesTheQueryThatFoundNothing() throws {
        let message = try #require(SearchCityContent.noResults(query: "Xyz").stateMessage)
        #expect(message.icon == .magnifyingGlass)
        #expect(message.title == "No city found for “Xyz”")
        #expect(message.message == "Check the spelling")
        #expect(!message.showsRetry)
    }

    @Test func offersRetryWhenOffline() throws {
        let message = try #require(SearchCityContent.offline.stateMessage)
        #expect(message.icon == .wifiSlash)
        #expect(message.title == "No internet connection")
        #expect(message.message == "Check your connection and try again.")
        #expect(message.showsRetry)
    }

    @Test func offersRetryAfterAFailure() throws {
        let message = try #require(SearchCityContent.failure.stateMessage)
        #expect(message.icon == .exclamationmarkTriangle)
        #expect(message.title == "Something went wrong")
        #expect(message.message == "We couldn't load the data. Please try again.")
        #expect(message.showsRetry)
    }

    @Test(arguments: [
        SearchCityContent.history([]),
        .loading,
        .results(query: "Krak", cities: []),
        .invalidInput,
    ])
    func usesNoStateMessageWhenTheScreenShowsData(content: SearchCityContent) {
        #expect(content.stateMessage == nil)
    }

    @Test(arguments: [(0, "0 results"), (1, "1 result"), (3, "3 results")])
    func countsResults(count: Int, expected: String) {
        #expect(SearchCityContent.resultCountText(count) == expected)
    }
}
