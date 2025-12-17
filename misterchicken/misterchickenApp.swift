import SwiftUI
import Combine
import UIKit

final class MisterChickenAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        CoopOrientationManager.shared.interfaceMask
    }
}

@main
struct MisterChickenApp: App {

    @UIApplicationDelegateAdaptor(MisterChickenAppDelegate.self) private var appDelegate

    @StateObject private var haptics = HapticsManager()
    @StateObject private var orientation = CoopOrientationManager.shared
    @StateObject private var realm = MisterChickenRealm()

    var body: some Scene {
        WindowGroup {
            MisterChickenMainScreen()
                .environmentObject(haptics)
                .environmentObject(orientation)
                .environmentObject(realm)
        }
    }
}
