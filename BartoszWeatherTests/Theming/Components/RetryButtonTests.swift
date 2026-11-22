import Testing
@testable import BartoszWeather

struct RetryButtonTests {
    @Test func defaultStateIsAnEnabledTryAgainButton() {
        let state = RetryButton.State.default
        #expect(state.title == "Try again")
        #expect(state.accessibilityLabel == "Try again")
        #expect(state.isDisabled == false)
        #expect(state.showsActivityIndicator == false)
    }

    @Test func loadingStateKeepsTitleAndAnnouncesThatItIsBusy() {
        let state = RetryButton.State.loading
        #expect(state.title == "Try again")
        #expect(state.accessibilityLabel == "Trying again")
        #expect(state.isDisabled)
        #expect(state.showsActivityIndicator)
    }

    @Test(arguments: [
        (true, false, 1.0),
        (true, true, Opacity.pressed),
        (false, false, Opacity.disabled),
        (false, true, Opacity.disabled),
    ])
    func dimsWhenPressedOrDisabled(isEnabled: Bool, isPressed: Bool, opacity: Double) {
        #expect(RetryButtonStyle.opacity(isEnabled: isEnabled, isPressed: isPressed) == opacity)
    }
}
