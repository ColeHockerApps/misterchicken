import SwiftUI
import Combine

enum MisterChickenAssets {

    enum Images {
        static let symbol1 = Image("sym_1")
        static let symbol2 = Image("sym_2")
        static let symbol3 = Image("sym_3")
    }

    enum Motion {
        static let loadingDuration: Double = 3.0
        static let fadeOutDuration: Double = 0.35

        static let reelSpinDuration: Double = 1.6
        static let reelStagger: Double = 0.18
        static let symbolBounce: Double = 0.22
    }

    enum Layout {
        static let symbolSize: CGFloat = 136
        static let reelSpacing: CGFloat = 18
        static let centerLift: CGFloat = -12
    }
}
