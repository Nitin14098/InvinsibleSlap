import Foundation
import SwiftUI
import Combine

enum ReflexGamePhase {
    case idle
    case waiting
    case ready
    case roundResult
    case finished
}

@MainActor
final class ReflexGameEngine: ObservableObject {
    @Published private(set) var phase: ReflexGamePhase = .idle
    @Published private(set) var currentRound = 0
    @Published private(set) var results: [ReflexRoundResult] = []
    @Published private(set) var lastReactionMilliseconds: Int?
    @Published private(set) var lastWasFalseStart = false
    @Published private(set) var completedSession: ReflexSession?

    let totalRounds = 5

    private var signalTime: TimeInterval = 0
    private var sessionStartDate = Date()
    private var scheduledTask: Task<Void, Never>?

    var validReactionTimes: [Int] {
        results.compactMap { result in
            guard !result.wasFalseStart else { return nil }
            return result.reactionMilliseconds
        }
    }

    var falseStartCount: Int {
        results.filter(\.wasFalseStart).count
    }

    var medianReactionMilliseconds: Int? {
        let times = validReactionTimes.sorted()
        guard !times.isEmpty else { return nil }

        let middle = times.count / 2

        if times.count.isMultiple(of: 2) {
            return (times[middle - 1] + times[middle]) / 2
        }

        return times[middle]
    }

    func start() {
        scheduledTask?.cancel()
        results = []
        currentRound = 0
        lastReactionMilliseconds = nil
        lastWasFalseStart = false
        completedSession = nil
        sessionStartDate = Date()

        beginNextRound()
    }

    func handleTap() {
        switch phase {
        case .waiting:
            scheduledTask?.cancel()

            lastReactionMilliseconds = nil
            lastWasFalseStart = true

            results.append(
                ReflexRoundResult(
                    roundNumber: currentRound,
                    reactionMilliseconds: nil,
                    wasFalseStart: true
                )
            )

            phase = .roundResult
            scheduleNextRound()

        case .ready:
            scheduledTask?.cancel()

            let elapsed = ProcessInfo.processInfo.systemUptime - signalTime
            let milliseconds = max(0, Int((elapsed * 1000).rounded()))

            lastReactionMilliseconds = milliseconds
            lastWasFalseStart = false

            results.append(
                ReflexRoundResult(
                    roundNumber: currentRound,
                    reactionMilliseconds: milliseconds,
                    wasFalseStart: false
                )
            )

            phase = .roundResult
            scheduleNextRound()

        case .idle, .roundResult, .finished:
            break
        }
    }

    func restart() {
        start()
    }

    private func beginNextRound() {
        scheduledTask?.cancel()

        guard results.count < totalRounds else {
            finishSession()
            return
        }

        currentRound = results.count + 1
        lastReactionMilliseconds = nil
        lastWasFalseStart = false
        phase = .waiting

        let delay = UInt64.random(
            in: 1_500_000_000...4_000_000_000
        )

        scheduledTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: delay)
            } catch {
                return
            }

            guard
                let self,
                !Task.isCancelled,
                self.phase == .waiting
            else {
                return
            }

            self.signalTime = ProcessInfo.processInfo.systemUptime
            self.phase = .ready
        }
    }

    private func scheduleNextRound() {
        scheduledTask?.cancel()

        scheduledTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: 900_000_000)
            } catch {
                return
            }

            guard let self, !Task.isCancelled else { return }
            self.beginNextRound()
        }
    }

    private func finishSession() {
        let session = ReflexSession(
            date: sessionStartDate,
            rounds: results
        )

        completedSession = session
        ReflexHistoryStore.save(session)
        phase = .finished
    }
}
