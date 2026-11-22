import SwiftUI

/// Connects `SearchCityView` to its view model and restarts the debounced search whenever the searched query changes.
///
/// A retry is cancelled by the next query change or when the screen disappears, like the debounced search.
struct SearchCityScreen: View {
    @Bindable private var viewModel: SearchCityViewModel
    @State private var retryTask: Task<Void, Never>?

    init(viewModel: SearchCityViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        SearchCityView(
            query: $viewModel.query,
            content: viewModel.content,
            onSelectCity: viewModel.select,
            onDeleteHistoryEntry: { _ in },
            onClearHistory: {},
            onRetry: retry
        )
        .task(id: viewModel.cityQuery) {
            retryTask?.cancel()
            await viewModel.search()
        }
        .onDisappear {
            retryTask?.cancel()
        }
    }

    private func retry() {
        retryTask?.cancel()
        retryTask = Task { await viewModel.retry() }
    }
}
