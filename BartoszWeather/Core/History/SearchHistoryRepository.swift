/// Reads and edits the search history: the most recently loaded cities with their last forecasts.
nonisolated public protocol SearchHistoryRepository: Sendable {
    /// The entries, newest first. An entry whose forecast is too old to show has `forecast == nil`.
    ///
    /// Throws when the history cannot be read.
    func entries() async throws -> [SearchHistoryEntry]

    /// Removes the city's entry; does nothing when the city is not in the history.
    ///
    /// Throws when the history cannot be written.
    func remove(cityID: City.ID) async throws

    /// Removes every entry. Throws when the history cannot be written.
    func removeAll() async throws
}
