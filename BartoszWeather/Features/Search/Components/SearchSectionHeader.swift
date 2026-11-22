import SwiftUI

/// A section title such as "Recent" or "Cities", with an optional trailing button or count.
struct SearchSectionHeader<Trailing: View>: View {
    private let title: LocalizedStringKey
    private let trailing: Trailing

    init(title: LocalizedStringKey, @ViewBuilder trailing: () -> Trailing) {
        self.title = title
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: Spacing.xSmall) {
            Text(title)
                .typography(.title)
                .foregroundStyle(Color(.Text.primary))
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: Spacing.xSmall)
            trailing
        }
    }
}

extension SearchSectionHeader where Trailing == EmptyView {
    init(title: LocalizedStringKey) {
        self.init(title: title) { EmptyView() }
    }
}

#Preview {
    VStack(spacing: Spacing.large) {
        SearchSectionHeader(title: "Recent") {
            Button("Clear") {}
        }
        SearchSectionHeader(title: "Cities") {
            Text(verbatim: "3 results")
        }
    }
    .padding(Spacing.large)
}
