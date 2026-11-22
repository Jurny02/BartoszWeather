import SwiftUI

/// A rounded card with a heading row, shared by the hourly and daily sections.
struct ForecastCard<Content: View>: View {
    @Environment(\.weatherAppearance) private var appearance
    private let title: LocalizedStringKey
    private let detail: String?
    private let content: Content

    init(title: LocalizedStringKey, detail: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.detail = detail
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xSmall) {
            HStack {
                Text(title)
                    .typography(.headline)
                    .foregroundStyle(Color(appearance.text))
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: Spacing.xSmall)
                if let detail {
                    Text(verbatim: detail)
                        .typography(.footnote)
                        .foregroundStyle(Color(appearance.secondaryText))
                }
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.medium)
        .padding(.vertical, Spacing.small)
        .background(Color(appearance.card), in: .rect(cornerRadius: Radius.large))
    }
}
