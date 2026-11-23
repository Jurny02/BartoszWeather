import Foundation
import os
import SwiftData

/// The search history and its stored forecasts, kept with SwiftData.
///
/// Keeps at most `limit` cities, newest save first. A forecast older than `maxForecastAge`, measured from its
/// `updatedAt`, or one that cannot be read, is deleted when it is next read; the city stays in the history.
/// Saves stamped with the same moment have no defined order.
public actor SwiftDataHistoryRepository: ModelActor, SearchHistoryRepository, ForecastStore {
    public static let limit = 10
    public static let defaultMaxForecastAge: TimeInterval = 24 * 3_600

    public nonisolated let modelContainer: ModelContainer
    public nonisolated let modelExecutor: any ModelExecutor

    private let maxForecastAge: TimeInterval
    private let now: @Sendable () -> Date
    private let logger = Logger(subsystem: "com.jurny02.BartoszWeather", category: "Persistence")

    /// The history stored on disk. When that store cannot be opened, the failure is logged
    /// and an in-memory store is used, so the app keeps working without remembering its history.
    ///
    /// - Parameter now: The current moment, used to stamp saves and to judge a forecast's age.
    public static func onDiskOrInMemory(
        maxForecastAge: TimeInterval = defaultMaxForecastAge,
        now: @escaping @Sendable () -> Date
    ) -> SwiftDataHistoryRepository {
        SwiftDataHistoryRepository(
            modelContainer: .historyOnDiskOrInMemory(), maxForecastAge: maxForecastAge, now: now
        )
    }

    /// - Parameter now: The current moment, used to stamp saves and to judge a forecast's age.
    init(
        modelContainer: ModelContainer,
        maxForecastAge: TimeInterval = defaultMaxForecastAge,
        now: @escaping @Sendable () -> Date
    ) {
        self.modelContainer = modelContainer
        modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))
        self.maxForecastAge = maxForecastAge
        self.now = now
    }

    public func entries() throws -> [SearchHistoryEntry] {
        try commit { _ in
            try newestFirst().prefix(Self.limit).map { record in
                SearchHistoryEntry(city: record.city, forecast: validForecast(of: record))
            }
        }
    }

    public func remove(cityID: City.ID) throws {
        try commit { _ in
            try record(for: cityID).map(modelContext.delete)
        }
    }

    public func removeAll() throws {
        try commit { _ in
            try modelContext.fetch(FetchDescriptor<CityHistoryRecord>()).forEach(modelContext.delete)
        }
    }

    public func save(_ forecast: Forecast, for city: City) throws {
        let data = try StoredForecast(forecast).encoded()
        try commit { _ in
            if let record = try record(for: city.id) {
                record.update(city: city, savedAt: now(), forecastData: data)
            } else {
                modelContext.insert(CityHistoryRecord(city: city, savedAt: now(), forecastData: data))
            }
            try newestFirst().dropFirst(Self.limit).forEach(modelContext.delete)
        }
    }

    public func forecast(for cityID: City.ID) throws -> Forecast? {
        try commit { _ in
            try record(for: cityID).flatMap(validForecast)
        }
    }

    /// Runs `work` on the model context and saves what it changed.
    ///
    /// When `work` or the save throws, every pending change is discarded before the error is rethrown,
    /// so a failed call never takes effect later through another call's save.
    func commit<Value: Sendable>(_ work: (ModelContext) throws -> Value) throws -> Value {
        do {
            let result = try work(modelContext)
            if modelContext.hasChanges {
                try modelContext.save()
            }
            return result
        } catch {
            modelContext.rollback()
            throw error
        }
    }

    private func record(for cityID: City.ID) throws -> CityHistoryRecord? {
        var descriptor = FetchDescriptor<CityHistoryRecord>(predicate: #Predicate { $0.cityID == cityID })
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    private func newestFirst() throws -> [CityHistoryRecord] {
        try modelContext.fetch(FetchDescriptor<CityHistoryRecord>(sortBy: [SortDescriptor(\.savedAt, order: .reverse)]))
    }

    /// The record's forecast while it is readable and young enough; otherwise clears it from the record.
    private func validForecast(of record: CityHistoryRecord) -> Forecast? {
        guard let data = record.forecastData else { return nil }
        do {
            let forecast = try StoredForecast.decode(data).forecast()
            guard now().timeIntervalSince(forecast.updatedAt) <= maxForecastAge else {
                record.forecastData = nil
                return nil
            }
            return forecast
        } catch {
            logger.error("Dropping an unreadable stored forecast: \(error, privacy: .public)")
            record.forecastData = nil
            return nil
        }
    }
}
