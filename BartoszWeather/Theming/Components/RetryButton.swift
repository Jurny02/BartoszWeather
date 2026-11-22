import SwiftUI

public struct RetryButton: View {
    nonisolated public enum State: CaseIterable, Sendable {
        case `default`
        case loading

        public var title: String {
            String(localized: "Try again")
        }

        public var accessibilityLabel: String {
            switch self {
            case .default: title
            case .loading: String(localized: "Trying again")
            }
        }

        public var isDisabled: Bool {
            self == .loading
        }

        public var showsActivityIndicator: Bool {
            self == .loading
        }
    }

    private let state: State
    private let action: () -> Void

    public init(state: State = .default, action: @escaping () -> Void) {
        self.state = state
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xSmall) {
                if state.showsActivityIndicator {
                    ProgressView()
                        .tint(Color(.onAccent))
                        .accessibilityHidden(true)
                }
                Text(state.title)
                    .typography(.headline)
            }
        }
        .buttonStyle(RetryButtonStyle())
        .disabled(state.isDisabled)
        .accessibilityLabel(state.accessibilityLabel)
    }
}

private struct RetryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color(.onAccent))
            .padding(.horizontal, Spacing.large)
            .padding(.vertical, Spacing.small)
            .frame(minWidth: Size.buttonMinWidth, minHeight: Size.buttonHeight)
            .background(Color(.accent), in: .rect(cornerRadius: Radius.medium))
            .opacity(configuration.isPressed ? Opacity.pressed : 1)
            .contentShape(.rect(cornerRadius: Radius.medium))
    }
}

#Preview("Light") {
    RetryButtonPreview()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    RetryButtonPreview()
        .preferredColorScheme(.dark)
}

#Preview("Large Dynamic Type") {
    RetryButtonPreview()
        .dynamicTypeSize(.accessibility3)
}

private struct RetryButtonPreview: View {
    var body: some View {
        VStack(spacing: Spacing.large) {
            ForEach(RetryButton.State.allCases, id: \.self) { state in
                RetryButton(state: state) {}
            }
        }
        .padding(Spacing.medium)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.background))
    }
}
