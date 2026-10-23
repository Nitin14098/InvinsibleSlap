
import Foundation

enum ReflexHistoryStore {
    private static let storageKey = "neurotap.reflex.sessions"
    private static let maximumSessions = 100

    static func load() -> [ReflexSession] {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let sessions = try? JSONDecoder().decode(
                [ReflexSession].self,
                from: data
            )
        else {
            return []
        }

        return sessions.sorted { $0.date > $1.date }
    }

    static func save(_ session: ReflexSession) {
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
}
