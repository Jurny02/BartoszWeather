import os
import SwiftData

nonisolated extension ModelContainer {
    private static let logger = Logger(subsystem: "com.jurny02.BartoszWeather", category: "Persistence")

    /// A container for the search history with its current schema and migration plan.
    ///
    /// Throws when the store cannot be opened or migrated.
    static func history(isStoredInMemoryOnly: Bool = false) throws -> ModelContainer {
        try ModelContainer(
            for: Schema(versionedSchema: HistorySchemaV1.self),
            migrationPlan: HistoryMigrationPlan.self,
            configurations: ModelConfiguration("History", isStoredInMemoryOnly: isStoredInMemoryOnly)
        )
    }

    /// The search history stored on disk. When that store cannot be opened, the failure is logged
    /// and an in-memory store is used, so the app keeps working without remembering its history.
    static func historyOnDiskOrInMemory() -> ModelContainer {
        do {
            return try history()
        } catch {
            logger.error("Cannot open the history store, using memory instead: \(error, privacy: .public)")
        }
        do {
            return try history(isStoredInMemoryOnly: true)
        } catch {
            fatalError("Cannot create an in-memory history store: \(error)")
        }
    }
}
