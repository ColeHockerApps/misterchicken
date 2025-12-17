import Foundation
import Combine
import UIKit

final class HapticsManager: ObservableObject {

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)

    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    init() {
        prepare()
    }

    func prepare() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        selection.prepare()
        notification.prepare()
    }

    func light() {
        impactLight.impactOccurred()
    }

    func medium() {
        impactMedium.impactOccurred()
    }

    func heavy() {
        impactHeavy.impactOccurred()
    }

    func select() {
        selection.selectionChanged()
    }

    func success() {
        notification.notificationOccurred(.success)
    }

    func warning() {
        notification.notificationOccurred(.warning)
    }

    func error() {
        notification.notificationOccurred(.error)
    }
}
