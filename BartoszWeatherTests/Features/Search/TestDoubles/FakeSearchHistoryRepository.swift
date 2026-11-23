import os
@testable import BartoszWeather

/// A `SearchHistoryRepository` that keeps entries in memory, can fail any operation and records every call.
///
/// While reads are held (`holdsReads`), each read waits for `releaseRead()`, so a test can act while a load
/// is in flight; the read then returns the entries stored at the time it is released.
/// Hold at most one read at a time: `stopHoldingReads()` lets later reads answer at once.
/// Like the real repository, a failing write leaves the entries unchanged.
nonisolated final class FakeSearchHistoryRepository: SearchHistoryRepository {
    /// The state behind the lock: stored entries, injected failures and recorded calls.
    private struct State {
        var entries: [SearchHistoryEntry]
        var readError: (any Error)?
        var writeError: (any Error)?
        var readCount = 0
        var removedCityIDs: [City.ID] = []
        var removeAllCount = 0
        var holdsReads: Bool
    }

    private let state: OSAllocatedUnfairLock<State>
    private let reads = AsyncStream<Void>.makeStream()
    private let releases = AsyncStream<Void>.makeStream()

    init(
        entries: [SearchHistoryEntry] = [],
        readError: (any Error)? = nil,
        writeError: (any Error)? = nil,
        holdsReads: Bool = false
    ) {
        state = OSAllocatedUnfairLock(
            initialState: State(
                entries: entries, readError: readError, writeError: writeError, holdsReads: holdsReads
            )
        )
    }

    /// The entries stored now, newest first.
    var storedEntries: [SearchHistoryEntry] {
        state.withLock { $0.entries }
    }

    /// How many times the entries were read.
    var readCount: Int {
        state.withLock { $0.readCount }
    }

    /// The city IDs passed to `remove(cityID:)`, oldest first, including failed calls.
    var removedCityIDs: [City.ID] {
        state.withLock { $0.removedCityIDs }
    }

    /// How many times `removeAll()` was called, including failed calls.
    var removeAllCount: Int {
        state.withLock { $0.removeAllCount }
    }

    /// Replaces the stored entries, as if another part of the app had written the history.
    func store(_ entries: [SearchHistoryEntry]) {
        state.withLock { $0.entries = entries }
    }

    /// Makes every later read fail with the error, or succeed again with `nil`.
    func failReads(with error: (any Error)?) {
        state.withLock { $0.readError = error }
    }

    /// Lets reads that start from now on answer without waiting for `releaseRead()`.
    func stopHoldingReads() {
        state.withLock { $0.holdsReads = false }
    }

    /// Waits until the next read starts.
    func nextRead() async {
        var iterator = reads.stream.makeAsyncIterator()
        _ = await iterator.next()
    }

    /// Lets one held read answer.
    func releaseRead() {
        releases.continuation.yield()
    }

    func entries() async throws -> [SearchHistoryEntry] {
        let holdsRead = state.withLock { state in
            state.readCount += 1
            return state.holdsReads
        }
        reads.continuation.yield()
        if holdsRead {
            var iterator = releases.stream.makeAsyncIterator()
            _ = await iterator.next()
        }
        try Task.checkCancellation()
        return try state.withLock { state in
            if let error = state.readError { throw error }
            return state.entries
        }
    }

    func remove(cityID: City.ID) async throws {
        try state.withLock { state in
            state.removedCityIDs.append(cityID)
            if let error = state.writeError { throw error }
            state.entries.removeAll { $0.id == cityID }
        }
    }

    func removeAll() async throws {
        try state.withLock { state in
            state.removeAllCount += 1
            if let error = state.writeError { throw error }
            state.entries.removeAll()
        }
    }
}
