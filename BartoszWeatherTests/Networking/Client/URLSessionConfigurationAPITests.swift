import Foundation
import Testing
@testable import BartoszWeather

/// Tests the session settings the API client uses by default.
struct URLSessionConfigurationAPITests {
    private let configuration = URLSessionConfiguration.api

    @Test func failsFastWhenOffline() {
        #expect(configuration.timeoutIntervalForRequest == 15)
        #expect(configuration.waitsForConnectivity == false)
    }

    @Test func keepsNothingOnDisk() {
        #expect(configuration.urlCache == nil)
        #expect(configuration.httpCookieStorage == nil)
        #expect(configuration.httpShouldSetCookies == false)
        #expect(configuration.requestCachePolicy == .reloadIgnoringLocalCacheData)
    }

    @Test func limitsConnectionsPerHost() {
        #expect(configuration.httpMaximumConnectionsPerHost == 4)
    }
}
