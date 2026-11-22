import SwiftUI

/// Empty, offline or error state with an optional action below the message.
public struct StateView<Actions: View>: View {
    private let icon: Icon
    private let title: String
    private let message: String
    private let actions: Actions
    @ScaledMetric(relativeTo: .largeTitle) private var iconSize = Size.stateIcon

    public init(icon: Icon, title: String, message: String, @ViewBuilder actions: () -> Actions) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actions = actions()
    }

    var accessibilityLabel: String {
        "\(title), \(message)"
    }

    public var body: some View {
        VStack(spacing: Spacing.small) {
            Image(icon: icon)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .foregroundStyle(Color(.accent))
                .accessibilityHidden(true)
            VStack(spacing: Spacing.small) {
                Text(title)
                    .typography(.title)
                    .foregroundStyle(Color(.Text.primary))
                Text(message)
                    .typography(.body)
                    .foregroundStyle(Color(.Text.secondary))
            }
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityAddTraits(.isHeader)
            actions
        }
        .padding(.horizontal, Spacing.medium)
        .padding(.vertical, Spacing.large)
    }
}

extension StateView where Actions == EmptyView {
    public init(icon: Icon, title: String, message: String) {
        self.init(icon: icon, title: title, message: message) { EmptyView() }
    }
}

#Preview("Light") {
    StateViewPreview()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    StateViewPreview()
        .preferredColorScheme(.dark)
}

#Preview("Large Dynamic Type") {
    StateViewPreview()
        .dynamicTypeSize(.accessibility3)
}

private struct StateViewPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.large) {
                StateView(
                    icon: .cloudSunFill,
                    title: "Search for a city to see the weather",
                    message: "Your next forecast is a search away."
                )
                StateView(
                    icon: .wifiSlash,
                    title: "No internet connection",
                    message: "Check your connection and try again."
                ) {
                    RetryButton {}
                }
                StateView(
                    icon: .exclamationmarkTriangle,
                    title: "Something went wrong",
                    message: "We couldn't load the data. Please try again."
                ) {
                    RetryButton(state: .loading) {}
                }
            }
            .padding(.horizontal, Spacing.large)
        }
        .background(Color(.background))
    }
}
