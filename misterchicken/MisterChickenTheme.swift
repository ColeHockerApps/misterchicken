import SwiftUI
import Combine

enum MisterChickenTheme {

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Colors.bgTop,
                Colors.bgMid,
                Colors.bgBottom
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    enum Colors {
        static let bgTop = Color(red: 0.07, green: 0.06, blue: 0.08)
        static let bgMid = Color(red: 0.10, green: 0.07, blue: 0.11)
        static let bgBottom = Color(red: 0.05, green: 0.04, blue: 0.07)

        static let surface = Color.black.opacity(0.55)
        static let surfaceStrong = Color.black.opacity(0.70)

        static let textPrimary = Color.white.opacity(0.92)
        static let textSecondary = Color.white.opacity(0.72)
        static let textMuted = Color.white.opacity(0.56)

        static let borderSoft = Color.white.opacity(0.12)
        static let shadow = Color.black.opacity(0.55)

        static let gold = Color(red: 0.98, green: 0.80, blue: 0.28)
        static let goldSoft = Color(red: 1.00, green: 0.86, blue: 0.46)

        static let plum = Color(red: 0.70, green: 0.22, blue: 0.55)
        static let ember = Color(red: 0.86, green: 0.20, blue: 0.22)

        static let glow = Color(red: 1.00, green: 0.52, blue: 0.20).opacity(0.55)
        static let reelGlow = Color.white.opacity(0.18)
    }

    enum Layout {
        static let corner: CGFloat = 22
        static let pillCorner: CGFloat = 18
        static let barHeight: CGFloat = 14
    }

    enum Fonts {
        static func title(_ size: CGFloat) -> Font {
            .system(size: size, weight: .semibold, design: .rounded)
        }

        static func body(_ size: CGFloat) -> Font {
            .system(size: size, weight: .medium, design: .rounded)
        }

        static func caption(_ size: CGFloat) -> Font {
            .system(size: size, weight: .semibold, design: .rounded)
        }
    }
}
