import os
@testable import BartoszWeather

/// An in-memory `ForecastStore` that records every save and can be told to fail its saves or reads.
nonisolated final class FakeForecastStore: ForecastStore {
    /// The error thrown when the store is told to fail.
    struct Failure: Error {}

    private let stored: OSAllocatedUnfairLock<[City.ID: Forecast]>
    private let saves = OSAllocatedUnfairLock<[SavedForecast]>(initialState: [])
    private let failsSaves: Bool
    private let failsReads: Bool

    init(stored: [City.ID: Forecast] = [:], failsSaves: Bool = false, failsReads: Bool = false) {
        self.stored = OSAllocatedUnfairLock(initialState: stored)
        self.failsSaves = failsSaves
        self.failsReads = failsReads
    }

    /// Every save so far, oldest first, including the ones that failed.
    var savedForecasts: [SavedForecast] {
        saves.withLock { $0 }
    }

    /// Records the save, then throws `Failure` when saves fail and keeps the forecast otherwise.
    func save(_ forecast: Forecast, for city: City) async throws {
        saves.withLock { $0.append(SavedForecast(forecast: forecast, city: city)) }
        if failsSaves {
            throw Failure()
        }
        stored.withLock { $0[city.id] = forecast }
    }

    /// Throws `Failure` when reads fail.
    func forecast(for cityID: City.ID) async throws -> Forecast? {
        if failsReads {
            throw Failure()
        }
        return stored.withLock { $0[cityID] }
    }
}

/// One call to `FakeForecastStore.save(_:for:)`.
nonisolated struct SavedForecast: Equatable, Sendable {
    let forecast: Forecast
    let city: City
}
