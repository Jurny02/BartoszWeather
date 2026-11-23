import Foundation
import os
import SwiftData
import Testing
@testable import BartoszWeather

/// Tests the SwiftData search history against an in-memory store: order, limit, updates, removal and expiry.
struct SwiftDataHistoryRepositoryTests {
    nonisolated private static let start = Date(timeIntervalSince1970: 1_784_117_100)

    private let clock = OSAllocatedUnfairLock(initialState: start)
    private let container: ModelContainer
    private let repository: SwiftDataHistoryRepository

    init() throws {
        container = try ModelContainer.history(isStoredInMemoryOnly: true)
        repository = SwiftDataHistoryRepository(
            modelContainer: container, maxForecastAge: 3_600, now: { [clock] in clock.withLock { $0 } }
        )
    }

    private func advance(by seconds: TimeInterval) {
        clock.withLock { $0.addTimeInterval(seconds) }
    }

    private func city(_ id: Int, name: String = "City") -> City {
        City(
            id: id, name: name, region: "Region", district: nil, country: "Poland",
            coordinate: Coordinate(latitude: 50, longitude: 20)
        )
    }

    private func forecast(temperature: Double = 20, updatedAt: Date = start) -> Forecast {
        Forecast(
            current: CurrentWeather(
                date: updatedAt, condition: .clearSky, isDay: true, temperature: temperature, apparentTemperature: nil,
                humidity: nil, cloudCover: nil, precipitationProbability: nil, wind: nil
            ),
            hourly: [], daily: [], timeZone: .gmt, updatedAt: updatedAt
        )
    }

    @Test func startsEmpty() async throws {
        #expect(try await repository.entries().isEmpty)
    }

    @Test func listsTheNewestSaveFirst() async throws {
        try await repository.save(forecast(), for: city(1))
        advance(by: 1)
        try await repository.save(forecast(), for: city(2))
        #expect(try await repository.entries().map(\.city.id) == [2, 1])
    }

    @Test func keepsTheCityAndTheForecast() async throws {
        let krakow = City(
            id: 3_094_802, name: "Kraków", region: "Małopolskie", district: "Kraków", country: nil,
            coordinate: Coordinate(latitude: 50.06143, longitude: 19.93658)
        )
        try await repository.save(forecast(), for: krakow)
        #expect(try await repository.entries() == [SearchHistoryEntry(city: krakow, forecast: forecast())])
    }

    @Test func keepsOnlyTheTenNewestCities() async throws {
        for id in 1...11 {
            try await repository.save(forecast(), for: city(id))
            advance(by: 1)
        }
        #expect(try await repository.entries().map(\.city.id) == Array((2...11).reversed()))
        #expect(try await repository.forecast(for: 1) == nil)
    }

    @Test func movesASavedAgainCityToTheFrontWithItsNewData() async throws {
        try await repository.save(forecast(temperature: 10), for: city(1, name: "Old"))
        advance(by: 1)
        try await repository.save(forecast(), for: city(2))
        advance(by: 1)
        try await repository.save(forecast(temperature: 30, updatedAt: Self.start.addingTimeInterval(2)), for: city(1, name: "New"))

        let entries = try await repository.entries()
        #expect(entries.map(\.city.id) == [1, 2])
        #expect(entries.first?.city.name == "New")
        #expect(entries.first?.forecast?.current.temperature == 30)
    }

    @Test func returnsTheStoredForecastOfACity() async throws {
        try await repository.save(forecast(temperature: 12), for: city(1))
        #expect(try await repository.forecast(for: 1) == forecast(temperature: 12))
        #expect(try await repository.forecast(for: 2) == nil)
    }

    @Test func removesOneCity() async throws {
        try await repository.save(forecast(), for: city(1))
        try await repository.save(forecast(), for: city(2))
        try await repository.remove(cityID: 1)
        try await repository.remove(cityID: 1)
        #expect(try await repository.entries().map(\.city.id) == [2])
    }

    @Test func removesAllCities() async throws {
        try await repository.save(forecast(), for: city(1))
        try await repository.save(forecast(), for: city(2))
        try await repository.removeAll()
        try await repository.removeAll()
        #expect(try await repository.entries().isEmpty)
    }

    @Test func keepsAForecastExactlyAtTheMaximumAge() async throws {
        try await repository.save(forecast(), for: city(1))
        advance(by: 3_600)
        #expect(try await repository.forecast(for: 1) != nil)
        #expect(try await repository.entries().first?.forecast != nil)
    }

    @Test func dropsAnExpiredForecastButKeepsTheCity() async throws {
        try await repository.save(forecast(), for: city(1))
        advance(by: 3_601)
        #expect(try await repository.forecast(for: 1) == nil)
        #expect(try await repository.entries() == [SearchHistoryEntry(city: city(1), forecast: nil)])
        #expect(try storedForecastData(for: 1) == nil)
    }

    @Test func dropsUnreadableForecastDataButKeepsTheCity() async throws {
        try await repository.save(forecast(), for: city(1))
        try replaceStoredForecastData(for: 1, with: Data("not json".utf8))
        #expect(try await repository.entries() == [SearchHistoryEntry(city: city(1), forecast: nil)])
        #expect(try storedForecastData(for: 1) == nil)
    }

    @Test func discardsTheChangesOfAFailedWrite() async throws {
        try await repository.save(forecast(), for: city(1))
        let unsaved = city(2)
        let failingWrite: @Sendable (ModelContext) throws -> Void = { context in
            context.insert(CityHistoryRecord(city: unsaved, savedAt: Self.start, forecastData: nil))
            throw WriteFailure()
        }
        await #expect(throws: WriteFailure.self) {
            try await repository.commit(failingWrite)
        }
        try await repository.remove(cityID: 1)
        #expect(try await repository.entries().isEmpty)
        #expect(try record(for: 2) == nil)
    }

    @Test func keepsTheHistoryInTheContainer() async throws {
        try await repository.save(forecast(), for: city(1))
        let reopened = SwiftDataHistoryRepository(modelContainer: container, now: { Self.start })
        #expect(try await reopened.entries().map(\.city.id) == [1])
    }

    private func record(for cityID: Int) throws -> CityHistoryRecord? {
        let context = ModelContext(container)
        return try context.fetch(FetchDescriptor<CityHistoryRecord>(predicate: #Predicate { $0.cityID == cityID })).first
    }

    private func storedForecastData(for cityID: Int) throws -> Data? {
        try record(for: cityID)?.forecastData
    }

    private func replaceStoredForecastData(for cityID: Int, with data: Data) throws {
        let context = ModelContext(container)
        let record = try #require(
            try context.fetch(FetchDescriptor<CityHistoryRecord>(predicate: #Predicate { $0.cityID == cityID })).first
        )
        record.forecastData = data
        try context.save()
    }
}

/// An error thrown on purpose in the middle of a write.
private struct WriteFailure: Error {}
