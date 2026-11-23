import Foundation
import SwiftData

/// The first version of the search history's SwiftData schema.
nonisolated enum HistorySchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [CityHistoryRecord.self]
    }

    /// One city in the search history: the city's fields, when it was last saved and its forecast as stored JSON.
    @Model
    final class CityHistoryRecord {
        @Attribute(.unique) var cityID: Int
        var name: String
        var region: String?
        var district: String?
        var country: String?
        var latitude: Double
        var longitude: Double
        var savedAt: Date
        /// A `StoredForecast` encoded as JSON, or `nil` once the forecast has expired or could not be read.
        var forecastData: Data?

        init(city: City, savedAt: Date, forecastData: Data?) {
            cityID = city.id
            name = city.name
            region = city.region
            district = city.district
            country = city.country
            latitude = city.coordinate.latitude
            longitude = city.coordinate.longitude
            self.savedAt = savedAt
            self.forecastData = forecastData
        }
    }
}

/// The current version of a city in the search history.
typealias CityHistoryRecord = HistorySchemaV1.CityHistoryRecord

nonisolated extension CityHistoryRecord {
    var city: City {
        City(
            id: cityID, name: name, region: region, district: district, country: country,
            coordinate: Coordinate(latitude: latitude, longitude: longitude)
        )
    }

    func update(city: City, savedAt: Date, forecastData: Data?) {
        name = city.name
        region = city.region
        district = city.district
        country = city.country
        latitude = city.coordinate.latitude
        longitude = city.coordinate.longitude
        self.savedAt = savedAt
        self.forecastData = forecastData
    }
}

/// How stored search history moves between schema versions. There is only one version so far.
nonisolated enum HistoryMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [HistorySchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
