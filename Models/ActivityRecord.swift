
import Foundation

struct ActivityRecord: Identifiable {
    let id: String
    let date: Date
    let type: ActivityType
    let title: String
    let detail: String

    static func memory(_ session: MemorySession) -> ActivityRecord {
        ActivityRecord(
            id: "memory-\(session.id.uuidString)",
            date: session.date,
            type: .memory,
            title: session.activity,
            detail: """
            \(session.correctRounds)/\(session.totalRounds) rounds correct \
            • \(session.accuracyPercentage)% accuracy
            """
        )
    }

    static func reflex(_ session: ReflexSession) -> ActivityRecord {
        let reactionDescription: String

        if let median = session.medianReactionMilliseconds {
            reactionDescription = "Median reaction: \(median) ms"
        } else {
            reactionDescription = "No valid reaction times"
        }

        return ActivityRecord(
            id: "reflex-\(session.id.uuidString)",
            date: session.date,
            type: .reflex,
            title: "Reflex Lab",
            detail: """
            \(reactionDescription) • \
            \(session.falseStartCount) false starts
            """
        )
    }

    static func focus(_ session: FocusSession) -> ActivityRecord {
        let minutes = session.completedDurationSeconds / 60

        let result = session.wasCompleted
            ? "Completed"
            : "Interrupted"

        return ActivityRecord(
            id: "focus-\(session.id.uuidString)",
            date: session.date,
            type: .focus,
            title: "Focus Mode",
            detail: "\(result) • \(minutes) minutes"
        )
    }
}
