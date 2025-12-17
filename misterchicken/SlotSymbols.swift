import Foundation
import Combine
import SwiftUI

enum SlotSymbols {

    enum Kind: String, CaseIterable, Codable, Hashable {
        case rooster
        case hen
        case chick
        case egg
        case corn
        case barn
        case hat
        case boots

        var title: String {
            switch self {
            case .rooster: return "Rooster"
            case .hen: return "Hen"
            case .chick: return "Chick"
            case .egg: return "Egg"
            case .corn: return "Corn"
            case .barn: return "Barn"
            case .hat: return "Hat"
            case .boots: return "Boots"
            }
        }

        var tier: Int {
            switch self {
            case .chick: return 1
            case .egg: return 1
            case .corn: return 2
            case .hen: return 2
            case .hat: return 3
            case .boots: return 3
            case .rooster: return 4
            case .barn: return 4
            }
        }

        var basePayout: Int {
            switch self {
            case .chick: return 4
            case .egg: return 5
            case .corn: return 7
            case .hen: return 9
            case .hat: return 12
            case .boots: return 14
            case .rooster: return 18
            case .barn: return 22
            }
        }
    }

    struct Strip: Codable, Hashable {
        let items: [Kind]

        init(items: [Kind]) {
            self.items = items.isEmpty ? Kind.allCases : items
        }

        func rotated(seed: Int) -> Strip {
            guard items.count > 1 else { return self }
            let shift = abs(seed) % items.count
            let a = Array(items[shift..<items.count])
            let b = Array(items[0..<shift])
            return Strip(items: a + b)
        }
    }

    struct Outcome: Codable, Hashable {
        let grid: [[Kind]]
        let winLines: [WinLine]
        let payout: Int

        init(grid: [[Kind]], winLines: [WinLine], payout: Int) {
            self.grid = grid
            self.winLines = winLines
            self.payout = max(0, payout)
        }
    }

    struct WinLine: Codable, Hashable {
        let row: Int
        let symbol: Kind
        let count: Int
        let linePayout: Int

        init(row: Int, symbol: Kind, count: Int, linePayout: Int) {
            self.row = row
            self.symbol = symbol
            self.count = max(0, count)
            self.linePayout = max(0, linePayout)
        }
    }
}
