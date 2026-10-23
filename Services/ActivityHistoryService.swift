
import Foundation

/// Read-only unified view of the existing activity stores.
enum ActivityHistoryService {

    static func loadRecentActivities() -> [ActivityRecord] {
        let memoryRecords = MemoryHistoryStore.load().map {
            ActivityRecord.memory($0)
        }

        let reflexRecords = ReflexHistoryStore.load().map {
            ActivityRecord.reflex($0)
        }

        let focusRecords = FocusHistoryStore.load().map {
            ActivityRecord.focus($0)
        }

        return (
            memoryRecords + reflexRecords + focusRecords
        )
        .sorted { $0.date > $1.date }
    }

    static func loadRecentActivities(limit: Int) -> [ActivityRecord] {
        let safeLimit = max(0, limit)

        guard safeLimit > 0 else {
            return []
        }

        return Array(loadRecentActivities().prefix(safeLimit))
    }

    static func totalRecordedSessions() -> Int {
        MemoryHistoryStore.load().count
            + ReflexHistoryStore.load().count
            + FocusHistoryStore.load().count
    }

    static func memorySessionCount() -> Int {
        MemoryHistoryStore.load().count
    }

    static func reflexSessionCount() -> Int {
        ReflexHistoryStore.load().count
    }

    static func focusSessionCount() -> Int {
        FocusHistoryStore.load().count
    }

    static func completedFocusSessionCount() -> Int {
        FocusHistoryStore.completedSessionCount()
    }

    static func totalCompletedFocusSeconds() -> Int {
        FocusHistoryStore.totalCompletedSeconds()
    }
}
