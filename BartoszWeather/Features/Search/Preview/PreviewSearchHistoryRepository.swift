#if DEBUG
/// A `SearchHistoryRepository` for previews: starts with the given entries and keeps edits in memory.
actor PreviewSearchHistoryRepository: SearchHistoryRepository {
    private var storedEntries: [SearchHistoryEntry]

    init(entries: [SearchHistoryEntry]) {
        storedEntries = entries
    }

    func entries() -> [SearchHistoryEntry] {
        storedEntries
    }

    func remove(cityID: City.ID) {
        storedEntries.removeAll { $0.id == cityID }
    }

    func removeAll() {
        storedEntries.removeAll()
    }
}
#endif
