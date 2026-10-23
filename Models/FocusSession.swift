
import Foundation

struct FocusSession: Codable, Identifiable {
    var id: UUID = UUID()
    let date: Date
    let plannedDurationSeconds: Int
    let completedDurationSeconds: Int
    let wasCompleted: Bool

    var completionPercentage: Int {
        guard plannedDurationSeconds > 0 else {
            return 0
        }

        let ratio = Double(completedDurationSeconds)
            / Double(plannedDurationSeconds)

        return min(100, max(0, Int((ratio * 100).rounded())))
    }

    init(
        date: Date = Date(),
        plannedDurationSeconds: Int,
        completedDurationSeconds: Int,
        wasCompleted: Bool
    ) {
        self.date = date
        self.plannedDurationSeconds = max(0, plannedDurationSeconds)
        self.completedDurationSeconds = max(0, completedDurationSeconds)
        self.wasCompleted = wasCompleted
    }
}
