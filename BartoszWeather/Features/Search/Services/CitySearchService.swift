/// Finds cities whose name matches a query, most relevant first.
nonisolated public protocol CitySearchService: Sendable {
    /// Returns the matching cities, or an empty array when nothing matches.
    ///
    /// Throws `APIError` when the search fails and `CancellationError` when the calling task is cancelled
    /// during the request; a request that has already finished may still return or throw `APIError`.
    func cities(matching query: String) async throws -> [City]
}
