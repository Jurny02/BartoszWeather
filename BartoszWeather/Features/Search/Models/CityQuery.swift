import Foundation

/// The typed city name, normalized and classified before it is sent to the search.
nonisolated public enum CityQuery: Hashable, Sendable {
    /// Nothing but whitespace.
    case empty
    /// Fewer than `minLength` characters, which the search answers with no results.
    case tooShort
    /// Contains characters other than letters, spaces and hyphens, or no letter at all.
    case invalid
    /// Trimmed, with runs of whitespace collapsed to one space and at most `maxLength` characters.
    case valid(String)

    public static let minLength = 2
    public static let maxLength = 60

    public init(_ text: String) {
        let normalized = text.split(whereSeparator: \.isWhitespace).joined(separator: " ")
        if normalized.isEmpty {
            self = .empty
        } else if !normalized.allSatisfy(Self.isAllowed) || !normalized.contains(where: \.isLetter) {
            self = .invalid
        } else if normalized.count < Self.minLength {
            self = .tooShort
        } else {
            self = .valid(String(normalized.prefix(Self.maxLength)).trimmingCharacters(in: .whitespaces))
        }
    }

    private static func isAllowed(_ character: Character) -> Bool {
        character == " " || character == "-" || character.isLetter
    }
}
