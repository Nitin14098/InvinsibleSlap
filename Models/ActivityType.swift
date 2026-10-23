
import Foundation

/// Categories used by the unified activity history.
enum ActivityType: String, Codable, CaseIterable, Identifiable {
    case memory
    case reflex
    case focus

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .memory:
            return "Memory Lab"

        case .reflex:
            return "Reflex Lab"

        case .focus:
            return "Focus Mode"
        }
    }
}
