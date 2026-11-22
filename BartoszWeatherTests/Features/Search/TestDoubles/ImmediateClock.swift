import os

/// A clock whose sleeps return at once and are recorded, so debounces can be tested without waiting.
///
/// Like a real clock, sleeping in a cancelled task throws `CancellationError`.
nonisolated final class ImmediateClock: Clock {
    /// A point on the clock's timeline, measured from its start.
    struct Instant: InstantProtocol {
        let offset: Duration

        func advanced(by duration: Duration) -> Instant {
            Instant(offset: offset + duration)
        }

        func duration(to other: Instant) -> Duration {
            other.offset - offset
        }

        static func < (lhs: Instant, rhs: Instant) -> Bool {
            lhs.offset < rhs.offset
        }
    }

    let now = Instant(offset: .zero)
    let minimumResolution = Duration.zero
    private let sleeps = OSAllocatedUnfairLock<[Duration]>(initialState: [])

    /// How long each sleep asked for, oldest first.
    var sleepDurations: [Duration] {
        sleeps.withLock { $0 }
    }

    func sleep(until deadline: Instant, tolerance: Duration?) async throws {
        sleeps.withLock { $0.append(now.duration(to: deadline)) }
        try Task.checkCancellation()
    }
}
