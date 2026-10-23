import SwiftUI
import UIKit

/// Shared adaptive NeuroTap palette. Existing feature views can keep using these names.
enum NeuroTapStyle {
    static let background = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.035, green: 0.045, blue: 0.105, alpha: 1)
            : UIColor(red: 0.955, green: 0.965, blue: 0.99, alpha: 1)
    })

    static let surface = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.075, green: 0.09, blue: 0.17, alpha: 1)
            : UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
    })

    static let primaryText = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.96, green: 0.97, blue: 1.0, alpha: 1)
            : UIColor(red: 0.09, green: 0.11, blue: 0.19, alpha: 1)
    })

    static let muted = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.64, green: 0.68, blue: 0.79, alpha: 1)
            : UIColor(red: 0.36, green: 0.40, blue: 0.51, alpha: 1)
    })

    static let outline = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.10)
            : UIColor(red: 0.16, green: 0.19, blue: 0.30, alpha: 0.10)
    })

    static let violet = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.60, green: 0.43, blue: 1.0, alpha: 1)
            : UIColor(red: 0.39, green: 0.23, blue: 0.82, alpha: 1)
    })

    static let cyan = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.30, green: 0.85, blue: 0.98, alpha: 1)
            : UIColor(red: 0.02, green: 0.43, blue: 0.62, alpha: 1)
    })
}
