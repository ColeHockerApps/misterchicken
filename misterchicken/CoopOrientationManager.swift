import Foundation
import Combine
import UIKit
import SwiftUI

@MainActor
final class CoopOrientationManager: ObservableObject {

    enum Mode: Equatable {
        case flexible
        case lockedLandscape
    }

    static let shared = CoopOrientationManager()

    @Published private(set) var activeValue: URL? = nil
    @Published private(set) var mode: Mode = .flexible

    private var isOrientation: Bool = false
    private var baseCheck: String? = nil
    private var gameOrientation: DispatchWorkItem? = nil
    private var pendingCompletion: (() -> Void)? = nil

    private init() {

    }

    func setActiveValue(_ value: URL?) {
        let prev = activeValue?.absoluteString ?? "nil"
        let next = value?.absoluteString ?? "nil"
        let base = baseCheck ?? "nil"

        
        activeValue = value

        guard isOrientation, let baseCheck else {

            return
        }

        guard let nowUrl = value else {

            return
        }

        let nowKey = duckKey(nowUrl)
        let baseKey = baseCheck

        if nowKey != baseKey {

            cancelLandscapeDecision(triggerCompletion: true)
        } else {

        }
    }

    func allowFlexible() {

        mode = .flexible

        applyPreferredKick()
    }

    func lockLandscape() {

        mode = .lockedLandscape

        applyLandscapeKick()
    }

    var interfaceMask: UIInterfaceOrientationMask {
        switch mode {
        case .flexible:
            return [.portrait, .landscapeLeft, .landscapeRight]
        case .lockedLandscape:
            return [.landscapeLeft, .landscapeRight]
        }
    }

    func scheduleLandscapeIfStillOnBase(
        base: URL,
        delay: TimeInterval,
        completion: @escaping () -> Void
    ) {
        let baseKey = duckKey(base)

        cancelLandscapeDecision(triggerCompletion: false)

        isOrientation = true
        baseCheck = baseKey
        pendingCompletion = completion


        
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }

            let baseKeyNow = self.baseCheck ?? "nil"
            let nowAbs = self.activeValue?.absoluteString ?? "nil"

            
            if self.isOrientation, let baseKey = self.baseCheck {
                guard let nowUrl = self.activeValue else {

                    self.finishDecision()
                    return
                }

                let nowKey = self.duckKey(nowUrl)

                if nowKey == baseKey {

                    self.lockLandscape()
                } else {

                }
            }

            self.finishDecision()
        }

        gameOrientation = work
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)

    }

    func cancelLandscapeDecision(triggerCompletion: Bool) {

        
        gameOrientation?.cancel()
        gameOrientation = nil

        let shouldComplete = triggerCompletion && isOrientation
        isOrientation = false
        baseCheck = nil

        if shouldComplete {

            pendingCompletion?()
        } else {

        }

        pendingCompletion = nil

    }

    private func finishDecision() {

        
        guard isOrientation else {

            return
        }

        isOrientation = false
        baseCheck = nil

        let completion = pendingCompletion
        pendingCompletion = nil
        gameOrientation = nil


        completion?()

    }

    // MARK: - Normalization

    private func duckKey(_ url: URL) -> String {
        var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)

        
        let scheme = (comps?.scheme ?? url.scheme ?? "").lowercased()
        let host = (comps?.host ?? url.host ?? "").lowercased()

        var path = comps?.path ?? url.path
        if path.isEmpty { path = "/" }

    
        if path.count > 1, path.hasSuffix("/") {
            path.removeLast()
        }

        return "\(scheme)://\(host)\(path)"
    }

    private func applyLandscapeKick() {

        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()

    }

    private func applyPreferredKick() {

        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()

    }
}
