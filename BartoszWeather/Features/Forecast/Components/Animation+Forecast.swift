import SwiftUI

extension Animation {
    /// The slow cross-fade the forecast screen uses when its screen or sky changes, so a night sky never flashes in.
    static let skyChange = Animation.easeInOut(duration: 0.6)
}
