import Foundation
import Testing
@testable import BartoszWeather

/// Tests how failed forecast loads map to issues, and the copy each issue shows.
struct ForecastIssueTests {
    private let warsaw = TimeZone(identifier: "Europe/Warsaw")!

    @Test(arguments: [
        (APIError.offline, ForecastIssue.offline),
        (.server(status: 429, reason: nil), .rateLimited),
        (.server(status: 500, reason: nil), .serviceUnavailable),
        (.server(status: 503, reason: "The service is overloaded"), .serviceUnavailable),
        (.server(status: 400, reason: nil), .failure),
        (.timeout, .failure),
        (.decoding(description: "bad"), .failure),
        (.invalidRequest, .failure),
        (.transport, .failure),
    ])
    func mapsAPIErrors(error: APIError, expected: ForecastIssue) {
        #expect(ForecastIssue(error: error) == expected)
    }

    @Test func mapsOtherErrorsToFailure() {
        #expect(ForecastIssue(error: URLError(.badURL)) == .failure)
    }

    @Test(arguments: [
        (
            ForecastIssue.offline,
            ForecastStateMessage(
                icon: .wifiSlash,
                title: "No internet connection",
                message: "Check your connection and try again."
            )
        ),
        (
            .rateLimited,
            ForecastStateMessage(
                icon: .clockBadgeExclamationmark,
                title: "Too many requests",
                message: "The weather service limit has been reached. Please try again later."
            )
        ),
        (
            .serviceUnavailable,
            ForecastStateMessage(
                icon: .exclamationmarkIcloud,
                title: "Weather service unavailable",
                message: "The service is temporarily down. Please try again in a few minutes."
            )
        ),
        (
            .failure,
            ForecastStateMessage(
                icon: .exclamationmarkTriangle,
                title: "Something went wrong",
                message: "We couldn't load the data. Please try again."
            )
        ),
    ])
    func describesTheFullScreenState(issue: ForecastIssue, expected: ForecastStateMessage) {
        #expect(issue.message == expected)
    }

    @Test func tellsThatShownDataIsFromBeforeTheConnectionWasLost() {
        let lastUpdated = Date(timeIntervalSince1970: 1_795_352_700)

        #expect(ForecastIssue.offline.statusIcon == .wifiSlash)
        #expect(ForecastIssue.offline.statusText(lastUpdated: lastUpdated, timeZone: warsaw)
            == "No connection · Showing data from 14:05")
    }

    @Test(arguments: [ForecastIssue.rateLimited, .serviceUnavailable, .failure])
    func tellsThatShownDataCouldNotBeRefreshed(issue: ForecastIssue) {
        let lastUpdated = Date(timeIntervalSince1970: 1_795_352_700)

        #expect(issue.statusIcon == .arrowClockwise)
        #expect(issue.statusText(lastUpdated: lastUpdated, timeZone: warsaw)
            == "Couldn't refresh · Showing data from 14:05")
    }
}
