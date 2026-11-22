import Foundation

/// An Open-Meteo endpoint. Failed requests carry a `{"error": true, "reason": …}` body.
///
/// The reason is English-only and can expose internal type names, so it is meant for logs, never for the UI.
nonisolated public protocol OpenMeteoEndpoint: Endpoint {}

nonisolated extension OpenMeteoEndpoint {
    public func errorReason(from data: Data) -> String? {
        try? JSONDecoder().decode(OpenMeteoErrorDTO.self, from: data).reason
    }
}

/// The error body Open-Meteo returns with a failed request.
nonisolated struct OpenMeteoErrorDTO: Decodable, Sendable {
    let reason: String?
}
