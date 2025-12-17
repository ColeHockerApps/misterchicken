import Foundation
import Combine

@MainActor
final class MisterChickenRealm: ObservableObject {

    @Published var entryPoint: URL
    @Published var privacyPage: URL

    private let entryKey   = "misterchicken.entry.value"
    private let privacyKey = "misterchicken.privacy.value"
    private let savedKey   = "misterchicken.saved.value"
    private let marksKey   = "misterchicken.marks.value"

    private var didSaveOnce = false

    init() {
        let defaults = UserDefaults.standard

        let defaultEntry = "https://aliboukharigames.github.io/mister-chicken"
        let defaultPrivacy = "https://aliboukharigames.github.io/mister-chicken-privacy"

        if let saved = defaults.string(forKey: entryKey),
           let url = URL(string: saved) {
            entryPoint = url
        } else {
            entryPoint = URL(string: defaultEntry)!
        }

        if let saved = defaults.string(forKey: privacyKey),
           let url = URL(string: saved) {
            privacyPage = url
        } else {
            privacyPage = URL(string: defaultPrivacy)!
        }
    }

    func updateEntry(_ value: String) {
        guard let url = URL(string: value) else { return }
        entryPoint = url
        UserDefaults.standard.set(value, forKey: entryKey)
    }

    func updatePrivacy(_ value: String) {
        guard let url = URL(string: value) else { return }
        privacyPage = url
        UserDefaults.standard.set(value, forKey: privacyKey)
    }

    func saveIfNeeded(_ value: URL) {
        guard didSaveOnce == false else { return }

        let defaults = UserDefaults.standard
        if defaults.string(forKey: savedKey) != nil {
            didSaveOnce = true
            return
        }

        defaults.set(value.absoluteString, forKey: savedKey)
        didSaveOnce = true
    }

    func restoreSaved() -> URL? {
        let defaults = UserDefaults.standard
        if let saved = defaults.string(forKey: savedKey),
           let url = URL(string: saved) {
            return url
        }
        return nil
    }

    func saveMarks(_ items: [[String: Any]]) {
        UserDefaults.standard.set(items, forKey: marksKey)
    }

    func currentMarks() -> [[String: Any]]? {
        UserDefaults.standard.array(forKey: marksKey) as? [[String: Any]]
    }
}
