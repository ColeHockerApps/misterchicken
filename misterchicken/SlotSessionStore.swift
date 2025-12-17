import Foundation
import Combine
import SwiftUI

@MainActor
final class SlotSessionStore: ObservableObject {

    struct Snapshot: Codable, Hashable {
        let chips: Int
        let bestWin: Int
        let spins: Int
        let wins: Int
        let lastSavedAt: TimeInterval

        init(chips: Int, bestWin: Int, spins: Int, wins: Int, lastSavedAt: TimeInterval) {
            self.chips = max(0, chips)
            self.bestWin = max(0, bestWin)
            self.spins = max(0, spins)
            self.wins = max(0, wins)
            self.lastSavedAt = max(0, lastSavedAt)
        }

        static func fresh() -> Snapshot {
            Snapshot(chips: 500, bestWin: 0, spins: 0, wins: 0, lastSavedAt: 0)
        }
    }

    @Published private(set) var snapshot: Snapshot = .fresh()
    @Published private(set) var statusLine: String = "Ready"

    private let key = "misterchicken.session.snapshot"

    init() {
        load()
        refreshStatus()
    }

    func load() {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: key) else {
            snapshot = .fresh()
            refreshStatus()
            return
        }

        do {
            let decoded = try JSONDecoder().decode(Snapshot.self, from: data)
            snapshot = decoded
        } catch {
            snapshot = .fresh()
        }

        refreshStatus()
    }

    func save(chips: Int, bestWin: Int, spins: Int, wins: Int) {
        let next = Snapshot(
            chips: chips,
            bestWin: bestWin,
            spins: spins,
            wins: wins,
            lastSavedAt: Date().timeIntervalSince1970
        )
        snapshot = next
        persist(next)
        refreshStatus()
    }

    func addChips(_ delta: Int) {
        let add = max(0, delta)
        let next = Snapshot(
            chips: snapshot.chips + add,
            bestWin: snapshot.bestWin,
            spins: snapshot.spins,
            wins: snapshot.wins,
            lastSavedAt: Date().timeIntervalSince1970
        )
        snapshot = next
        persist(next)
        refreshStatus()
    }

    func spendChips(_ delta: Int) -> Bool {
        let cost = max(0, delta)
        guard snapshot.chips >= cost else { return false }

        let next = Snapshot(
            chips: snapshot.chips - cost,
            bestWin: snapshot.bestWin,
            spins: snapshot.spins,
            wins: snapshot.wins,
            lastSavedAt: Date().timeIntervalSince1970
        )
        snapshot = next
        persist(next)
        refreshStatus()
        return true
    }

    func resetAll() {
        snapshot = .fresh()
        UserDefaults.standard.removeObject(forKey: key)
        refreshStatus()
    }

    private func persist(_ value: Snapshot) {
        do {
            let data = try JSONEncoder().encode(value)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    private func refreshStatus() {
        let s = snapshot
        if s.lastSavedAt <= 0 {
            statusLine = "Ready"
            return
        }
        statusLine = "Chips \(s.chips) • Best \(s.bestWin) • Spins \(s.spins)"
    }
}
