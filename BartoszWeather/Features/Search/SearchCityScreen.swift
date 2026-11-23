import SwiftUI

/// Connects `SearchCityView` to its view model and restarts the debounced search whenever the searched query changes.
///
/// The search starts over and the history is read again each time the screen appears,
/// such as on the return from a forecast.
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
            onDeleteHistoryEntry: deleteHistoryEntry,
            onClearHistory: clearHistory,
            onRetry: retry
        )
        .task(id: viewModel.cityQuery) {
            retryTask?.cancel()
            await viewModel.search()
        }
        .onAppear {
            viewModel.resetSearch()
        }
        .task {
            await viewModel.loadHistory()
        }
        .onDisappear {
            retryTask?.cancel()
        }
    }

    private func deleteHistoryEntry(_ entry: SearchHistoryEntry) {
        Task { await viewModel.deleteHistoryEntry(entry) }
    }

    private func clearHistory() {
        Task { await viewModel.clearHistory() }
    }

    private func retry() {
        retryTask?.cancel()
        retryTask = Task { await viewModel.retry() }
    }
}
