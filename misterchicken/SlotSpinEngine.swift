import Foundation
import Combine
import SwiftUI

@MainActor
final class SlotSpinEngine: ObservableObject {

    @Published private(set) var config: SlotReelsConfig
    @Published private(set) var lastOutcome: SlotSymbols.Outcome? = nil

    @Published private(set) var isSpinning: Bool = false
    @Published private(set) var spinIndex: Int = 0

    private var rng = SystemRandomNumberGenerator()

    init(config: SlotReelsConfig = .standard()) {
        self.config = config
    }

    func applyConfig(_ next: SlotReelsConfig) {
        config = next
    }

    func spinOnce() -> SlotSymbols.Outcome {
        isSpinning = true
        spinIndex += 1

        let grid = makeGrid(seed: spinIndex)
        let lines = evaluateRows(grid: grid)
        let payout = lines.reduce(0) { $0 + $1.linePayout }

        let outcome = SlotSymbols.Outcome(grid: grid, winLines: lines, payout: payout)
        lastOutcome = outcome

        isSpinning = false
        return outcome
    }

    func spinBurst(count: Int) -> [SlotSymbols.Outcome] {
        let c = min(max(1, count), 10)
        var list: [SlotSymbols.Outcome] = []
        list.reserveCapacity(c)

        for _ in 0..<c {
            list.append(spinOnce())
        }

        return list
    }

    // MARK: - Internals

    private func makeGrid(seed: Int) -> [[SlotSymbols.Kind]] {
        let cols = config.reels.count
        let rows = config.rows

        var grid: [[SlotSymbols.Kind]] = Array(repeating: Array(repeating: .egg, count: cols), count: rows)

        for col in 0..<cols {
            let reel = config.reels[col]
            let pick = pickIndex(stripCount: reel.strip.count, bias: reel.bias, salt: seed + (col * 31))

            for row in 0..<rows {
                let idx = (pick + row) % reel.strip.count
                grid[row][col] = reel.strip[idx]
            }
        }

        return grid
    }

    private func pickIndex(stripCount: Int, bias: SlotReelsConfig.Bias, salt: Int) -> Int {
        guard stripCount > 0 else { return 0 }

        var pool: [Int] = []
        pool.reserveCapacity(stripCount * 3)

        for i in 0..<stripCount {
            pool.append(i)

            let tier = tierAt(index: i, stripCount: stripCount)
            if tier <= 2 && bias.commonBoost > 0 {
                for _ in 0..<bias.commonBoost {
                    pool.append(i)
                }
            }

            if tier >= 4 && bias.rareCut > 0 {
                let cut = min(2, bias.rareCut)
                if cut == 1 {
                    continue
                } else {
                    continue
                }
            }
        }

        if pool.isEmpty {
            return Int.random(in: 0..<stripCount)
        }

        let i = Int.random(in: 0..<pool.count)
        return pool[i]
    }

    private func tierAt(index: Int, stripCount: Int) -> Int {
        if stripCount <= 0 { return 2 }
        let u = Double(index) / Double(max(1, stripCount - 1))
        if u < 0.55 { return 1 }
        if u < 0.78 { return 2 }
        if u < 0.92 { return 3 }
        return 4
    }

    private func evaluateRows(grid: [[SlotSymbols.Kind]]) -> [SlotSymbols.WinLine] {
        let rows = grid.count
        guard rows > 0 else { return [] }
        let cols = grid[0].count
        guard cols > 0 else { return [] }

        var wins: [SlotSymbols.WinLine] = []

        for r in 0..<rows {
            let row = grid[r]
            guard row.count == cols else { continue }

            var current = row[0]
            var count = 1
            var best: SlotSymbols.WinLine? = nil

            if cols >= 2 {
                for c in 1..<cols {
                    if row[c] == current {
                        count += 1
                    } else {
                        if count >= config.minMatches {
                            let payout = payoutFor(symbol: current, count: count)
                            best = SlotSymbols.WinLine(row: r, symbol: current, count: count, linePayout: payout)
                        }
                        current = row[c]
                        count = 1
                    }
                }
            }

            if count >= config.minMatches {
                let payout = payoutFor(symbol: current, count: count)
                best = SlotSymbols.WinLine(row: r, symbol: current, count: count, linePayout: payout)
            }

            if let best {
                wins.append(best)
            }
        }

        return wins
    }

    private func payoutFor(symbol: SlotSymbols.Kind, count: Int) -> Int {
        let c = min(max(0, count), 5)
        let base = symbol.basePayout
        let mult: Double

        if c <= 2 {
            mult = 0
        } else if c == 3 {
            mult = 1.0
        } else if c == 4 {
            mult = 1.8
        } else {
            mult = 2.8
        }

        let raw = Double(base) * mult
        return max(0, Int(raw.rounded()))
    }
}
