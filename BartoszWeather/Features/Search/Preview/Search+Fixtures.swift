#if DEBUG
import Foundation

extension City {
    /// Fixture search results for "Krak": Kraków in Poland and two same-name places in the United States.
    static let searchResults = [
        City(
            id: City.krakow.id, name: "Kraków", region: "Małopolskie", district: "Kraków", country: "Poland",
            coordinate: City.krakow.coordinate
        ),
        City(
            id: 5_258_957, name: "Krakow", region: "Wisconsin", district: nil, country: "United States",
            coordinate: Coordinate(latitude: 44.77, longitude: -88.06)
        ),
        City(
            id: 4_393_146, name: "Krakow", region: "Missouri", district: nil, country: "United States",
            coordinate: Coordinate(latitude: 38.40, longitude: -91.03)
        ),
    ]
}

extension SearchHistoryEntry {
    /// Fixture history: a clear day, a clear night and a windy overcast day.
    static let previewEntries = [
        SearchHistoryEntry(city: .krakow, forecast: .krakowDay),
        SearchHistoryEntry(city: .zakopane, forecast: .zakopaneNight),
        SearchHistoryEntry(city: .hel, forecast: .helStrongWind),
    ]

    /// Fixture entry whose forecast is too old to show.
    static let expiredEntry = SearchHistoryEntry(city: City.searchResults[1], forecast: nil)
}
#endif
