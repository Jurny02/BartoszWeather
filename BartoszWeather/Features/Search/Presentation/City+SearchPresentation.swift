import Foundation

nonisolated extension City {
    /// The line under a search result that tells same-name places apart, such as "Małopolskie, Kraków · Poland";
    /// `nil` when region, district and country are all missing or blank.
    public var resultSubtitle: String? {
        let area = [region, district].compactMap(Self.trimmed).joined(separator: ", ")
        let parts = [area, country.flatMap(Self.trimmed) ?? ""].filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    /// The start of the name that matches the typed query, ignoring case, diacritics and surrounding spaces;
    /// `nil` when the query is blank or the name does not start with it.
    public func highlightedNameRange(matching query: String) -> Range<String.Index>? {
        guard let query = Self.trimmed(query) else { return nil }
        return name.range(of: query, options: [.anchored, .caseInsensitive, .diacriticInsensitive])
    }

    private static func trimmed(_ text: String?) -> String? {
        guard let text = text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return nil }
        return text
    }
}
