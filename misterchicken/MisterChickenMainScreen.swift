import SwiftUI
import Combine

struct MisterChickenMainScreen: View {

    @EnvironmentObject private var orientation: CoopOrientationManager
    @EnvironmentObject private var realm: MisterChickenRealm

    @State private var showLoading: Bool = true
    @State private var showStage: Bool = false

    @State private var didStartDecision: Bool = false

    var body: some View {
        ZStack {
            MisterChickenTheme.backgroundGradient
                .ignoresSafeArea()

            CoopBoardContainer(onClose: nil)
                .opacity(showStage ? 1 : 0)
                .allowsHitTesting(showStage)
                .transition(.opacity)

            if showLoading {
                LoadingScreen {

                    startDecision()
                }
                .transition(.opacity)
            }
        }
        .onAppear {

            orientation.allowFlexible()
        }
        .onDisappear {

            orientation.cancelLandscapeDecision(triggerCompletion: false)
        }
    }

    private func startDecision() {
        guard didStartDecision == false else { return }
        didStartDecision = true


        
        orientation.scheduleLandscapeIfStillOnBase(base: realm.entryPoint, delay: 0.2) {

            
            withAnimation(.easeOut(duration: 0.25)) {
                showLoading = false
                showStage = true
            }
        }


    }
}
