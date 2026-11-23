import SwiftUI

/// A rounded placeholder bar that stands in for content while it loads.
///
/// Group blocks and apply `skeletonPulse()` to the group so they breathe together.
public struct SkeletonBlock: View {
    /// The corner radius Figma gives most skeleton bars.
    public static let defaultCornerRadius: CGFloat = 8

    private let width: CGFloat
    private let height: CGFloat
    private let cornerRadius: CGFloat

    public init(width: CGFloat, height: CGFloat, cornerRadius: CGFloat = SkeletonBlock.defaultCornerRadius) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color(.separatorLine))
            .frame(width: width, height: height)
    }
}

/// Fades content gently in and out to show it is loading; stays still when Reduce Motion is on.
private struct SkeletonPulse: ViewModifier {
    private static let dimmedOpacity = 0.5
    private static let halfCycle: TimeInterval = 0.9

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isDimmed = false

    func body(content: Content) -> some View {
        content
            .animation(reduceMotion ? nil : .easeInOut(duration: Self.halfCycle).repeatForever(autoreverses: true)) {
                $0.opacity(isDimmed && !reduceMotion ? Self.dimmedOpacity : 1)
            }
            .onAppear { isDimmed = true }
    }
}

extension View {
    /// Pulses the opacity of a group of skeleton blocks while content loads.
    public func skeletonPulse() -> some View {
        modifier(SkeletonPulse())
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.xSmall) {
        SkeletonBlock(width: 108, height: 16, cornerRadius: 6)
        SkeletonBlock(width: 220, height: 12, cornerRadius: 6)
        SkeletonBlock(width: 64, height: 64)
    }
    .skeletonPulse()
    .padding(Spacing.large)
    .background(Color(.Surface.card))
}
