#if DEBUG
/// A `CitySearchService` for previews: finds fixture cities whose name starts with the query, without the network.
nonisolated struct PreviewCitySearchService: CitySearchService {
    func cities(matching query: String) async throws -> [City] {
        try Task.checkCancellation()
        let cities = await City.searchResults + [.zakopane, .hel]
        return cities.filter { $0.highlightedNameRange(matching: query) != nil }
    }
}
#endif
