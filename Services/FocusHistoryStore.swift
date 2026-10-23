
import Foundation

enum FocusHistoryStore {
    private static let storageKey = "neurotap.focus.sessions"
    private static let maximumSessions = 100

    static func load() -> [FocusSession] {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let sessions = try? JSONDecoder().decode(
                [FocusSession].self,
                from: data
            )
        else {
            return []
        }

        return sessions.sorted { $0.date > $1.date }
    }

    static func save(_ session: FocusSession) {
        var sessions = load()
        sessions.insert(session, at: 0)

        if sessions.count > maximumSessions {
            sessions = Array(sessions.prefix(maximumSessions))
        }

        guard let data = try? JSONEncoder().encode(sessions) else {
            return
        }

        UserDefaults.standard.set(data, forKey: storageKey)
    }

    static func totalCompletedSeconds() -> Int {
        load()
            .filter(\.wasCompleted)
            .reduce(0) { $0 + $1.completedDurationSeconds }
    }

    static func completedSessionCount() -> Int {
        load().filter(\.wasCompleted).count
    }
}
