import Foundation
import Combine
import SwiftUI

struct SlotPayoutTable: Codable, Hashable {

    struct Row: Codable, Hashable {
        let symbol: SlotSymbols.Kind
        let x3: Int
        let x4: Int
        let x5: Int

        init(symbol: SlotSymbols.Kind, x3: Int, x4: Int, x5: Int) {
            self.symbol = symbol
            self.x3 = max(0, x3)
            self.x4 = max(0, x4)
            self.x5 = max(0, x5)
        }
    }

    var rows: [Row]

    init(rows: [Row]) {
        self.rows = rows.isEmpty ? SlotPayoutTable.standard().rows : rows
    }

    static func standard() -> SlotPayoutTable {
        SlotPayoutTable(rows: [
            make(.chick),
            make(.egg),
            make(.corn),
            make(.hen),
            make(.hat),
            make(.boots),
            make(.rooster),
            make(.barn)
        ])
    }

    func payout(for symbol: SlotSymbols.Kind, count: Int) -> Int {
        let c = min(max(0, count), 5)
        guard c >= 3 else { return 0 }

        guard let row = rows.first(where: { $0.symbol == symbol }) else {
            return fallback(symbol: symbol, count: c)
        }

        if c == 3 { return row.x3 }
        if c == 4 { return row.x4 }
        return row.x5
    }

    private static func make(_ symbol: SlotSymbols.Kind) -> Row {
        let base = symbol.basePayout
        let x3 = max(1, Int((Double(base) * 1.00).rounded()))
        let x4 = max(1, Int((Double(base) * 1.80).rounded()))
        let x5 = max(1, Int((Double(base) * 2.80).rounded()))
        return Row(symbol: symbol, x3: x3, x4: x4, x5: x5)
    }

    private func fallback(symbol: SlotSymbols.Kind, count: Int) -> Int {
        let base = symbol.basePayout
        if count == 3 { return max(1, base) }
        if count == 4 { return max(1, Int((Double(base) * 1.8).rounded())) }
        return max(1, Int((Double(base) * 2.8).rounded()))
    }
}
