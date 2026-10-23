
import Foundation

struct ReflexRoundResult: Codable, Identifiable {
    var id: UUID = UUID()
    let roundNumber: Int
    let reactionMilliseconds: Int?
    let wasFalseStart: Bool
}

struct ReflexSession: Codable, Identifiable {
    var id: UUID = UUID()
    let date: Date
    let rounds: [ReflexRoundResult]

    var validReactionTimes: [Int] {
        rounds.compactMap { round in
            guard !round.wasFalseStart else { return nil }
            return round.reactionMilliseconds
        }
    }

    var falseStartCount: Int {
        rounds.filter(\.wasFalseStart).count
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
}
