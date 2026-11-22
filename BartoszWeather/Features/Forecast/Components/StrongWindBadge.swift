import SwiftUI

/// A pill under the current temperature that warns about strong wind.
struct StrongWindBadge: View {
    @Environment(\.weatherAppearance) private var appearance
    @ScaledMetric private var iconSize = 16.0

    var body: some View {
        HStack(spacing: Spacing.xxSmall) {
            Image(icon: .wind)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
            Text("Strong wind")
                .typography(.footnote)
                .fontWeight(.medium)
        }
        .foregroundStyle(Color(appearance.badgeText))
        .padding(.horizontal, Spacing.small)
        .padding(.vertical, Spacing.xSmall)
        .background(Color(appearance.selection), in: .rect(cornerRadius: Radius.medium))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    StrongWindBadge()
        .padding(Spacing.large)
}
