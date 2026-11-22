import SwiftUI

/// The city name field with a clear button, outlined in the accent color while focused and in red while invalid.
struct SearchField: View {
    @Binding private var text: String
    private let isInvalid: Bool
    @FocusState private var isFocused: Bool
    @ScaledMetric(relativeTo: .body) private var searchIconSize = 20.0
    @ScaledMetric(relativeTo: .body) private var clearIconSize = 18.0

    init(text: Binding<String>, isInvalid: Bool) {
        _text = text
        self.isInvalid = isInvalid
    }

    var body: some View {
        HStack(spacing: Spacing.xSmall) {
            Image(icon: .magnifyingGlass)
                .resizable()
                .scaledToFit()
                .frame(width: searchIconSize, height: searchIconSize)
                .foregroundStyle(Color(.Text.secondary))
                .accessibilityHidden(true)
            TextField(
                "Enter city name",
                text: $text,
                prompt: Text("Enter city name").foregroundStyle(Color(.Text.secondary))
            )
            .typography(.body)
            .foregroundStyle(Color(.Text.primary))
            .focused($isFocused)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .submitLabel(.search)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(icon: .xmarkCircleFill)
                        .resizable()
                        .scaledToFit()
                        .frame(width: clearIconSize, height: clearIconSize)
                        .foregroundStyle(Color(.Text.secondary))
                }
                .accessibilityLabel("Clear text")
            }
        }
        .padding(.leading, Spacing.medium)
        .padding(.trailing, Spacing.small)
        .padding(.vertical, Spacing.small)
        .background(Color(.Surface.field), in: .rect(cornerRadius: Radius.medium))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.medium)
                .strokeBorder(borderColor, lineWidth: 1.5)
        }
    }

    private var borderColor: Color {
        if isInvalid { return Color(.error) }
        return isFocused ? Color(.accent) : .clear
    }
}

#Preview {
    VStack(spacing: Spacing.medium) {
        SearchField(text: .constant(""), isInvalid: false)
        SearchField(text: .constant("Krak"), isInvalid: false)
        SearchField(text: .constant("Kraków123"), isInvalid: true)
    }
    .padding(Spacing.large)
    .background(Color(.background))
}
