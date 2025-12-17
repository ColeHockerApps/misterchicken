import Foundation
import Combine
import SwiftUI

struct SlotReelsConfig: Codable, Hashable {

    var reels: [Reel]
    var rows: Int
    var minMatches: Int

    init(reels: [Reel], rows: Int, minMatches: Int) {
        self.reels = reels.isEmpty ? SlotReelsConfig.defaultReels() : reels
        self.rows = max(3, rows)
        self.minMatches = min(max(3, minMatches), 5)
    }

    static func standard() -> SlotReelsConfig {
        SlotReelsConfig(reels: defaultReels(), rows: 3, minMatches: 3)
    }

    static func wide() -> SlotReelsConfig {
        SlotReelsConfig(reels: defaultReels().map { $0.withExtraWeight() }, rows: 3, minMatches: 3)
    }

    struct Reel: Codable, Hashable {
        var strip: [SlotSymbols.Kind]
        var bias: Bias

        init(strip: [SlotSymbols.Kind], bias: Bias) {
            self.strip = strip.isEmpty ? SlotReelsConfig.defaultStrip() : strip
            self.bias = bias
        }

        func withExtraWeight() -> Reel {
            var next = self
            next.bias = Bias(commonBoost: bias.commonBoost + 1, rareCut: min(2, bias.rareCut + 1))
            return next
        }
    }

    struct Bias: Codable, Hashable {
        var commonBoost: Int
        var rareCut: Int

        init(commonBoost: Int, rareCut: Int) {
            self.commonBoost = max(0, commonBoost)
            self.rareCut = max(0, rareCut)
        }

        static func neutral() -> Bias {
            Bias(commonBoost: 0, rareCut: 0)
        }

        static func cozy() -> Bias {
            Bias(commonBoost: 2, rareCut: 1)
        }
    }

    // MARK: - Defaults

    private static func defaultReels() -> [Reel] {
        [
            Reel(strip: defaultStrip(), bias: .neutral()),
            Reel(strip: defaultStrip().rotated(by: 3), bias: .neutral()),
            Reel(strip: defaultStrip().rotated(by: 7), bias: .neutral())
        ]
    }

    private static func defaultStrip() -> [SlotSymbols.Kind] {
        [
            .chick, .egg, .corn, .hen, .chick, .egg, .corn, .hat,
            .chick, .hen, .egg, .boots, .corn, .hen, .chick, .egg,
            .corn, .hat, .hen, .egg, .chick, .corn, .rooster, .barn
        ]
    }
}

private extension Array where Element == SlotSymbols.Kind {
    func rotated(by shift: Int) -> [SlotSymbols.Kind] {
        guard count > 1 else { return self }
        let k = abs(shift) % count
        if k == 0 { return self }
        return Array(self[k..<count]) + Array(self[0..<k])
    }
}
