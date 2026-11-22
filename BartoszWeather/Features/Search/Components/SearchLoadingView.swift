import SwiftUI

/// "Searching for cities…" above three placeholder rows shaped like city results.
struct SearchLoadingView: View {
    private static let nameWidths: [CGFloat] = [108, 150, 122]
    @ScaledMetric(relativeTo: .footnote) private var iconSize = 16.0

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            HStack(spacing: Spacing.xSmall) {
                Image(icon: .arrowClockwise)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundStyle(Color(.accent))
                Text("Searching for cities…")
                    .typography(.footnote)
                    .foregroundStyle(Color(.Text.secondary))
            }
            VStack(spacing: 1) {
                ForEach(Self.nameWidths, id: \.self) { width in
                    SkeletonRow(nameWidth: width)
                }
            }
            .background(Color(.separatorLine))
            .clipShape(.rect(cornerRadius: Radius.large))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Loading results")
    }
}

/// A placeholder for one city result while the search runs.
private struct SkeletonRow: View {
    private static let verticalPadding: CGFloat = 20
    private static let barCornerRadius: CGFloat = 6
    private static let detailWidth: CGFloat = 220

    let nameWidth: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xSmall) {
            bar(width: nameWidth, height: 16)
            bar(width: Self.detailWidth, height: 12)
        }
        .padding(.horizontal, Spacing.medium)
        .padding(.vertical, Self.verticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.Surface.card))
    }

    private func bar(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: Self.barCornerRadius)
            .fill(Color(.separatorLine))
            .frame(width: width, height: height)
    }
}

#Preview {
    SearchLoadingView()
        .padding(Spacing.large)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(.background))
}
