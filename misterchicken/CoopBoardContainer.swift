import SwiftUI
import Combine

struct CoopBoardContainer: View {

    @EnvironmentObject private var orientation: CoopOrientationManager
    @EnvironmentObject private var realm: MisterChickenRealm

    @State private var isReady: Bool = false
    @State private var fadeIn: Bool = false
    @State private var dimLayer: Double = 0.20

    let onClose: (() -> Void)?

    var body: some View {
        ZStack {
            MisterChickenTheme.backgroundGradient
                .ignoresSafeArea()

            ZStack {
                Color.black
                    .ignoresSafeArea()

                MisterChickenPlayfield(
                    entryPoint: startValue(),
                    realm: realm,
                    orientation: orientation
                ) {
                    markReady()
                }
                .opacity(fadeIn ? 1 : 0)
                .animation(.easeOut(duration: 0.28), value: fadeIn)

                if isReady == false {
                    loadingOverlay
                }
            }

            Color.black
                .opacity(dimLayer)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .animation(.easeOut(duration: 0.28), value: dimLayer)
        }
        .onAppear {
            onAppear()
        }
    }

    private func startValue() -> URL {
        realm.restoreSaved() ?? realm.entryPoint
    }

    private func onAppear() {
        isReady = false
        fadeIn = false
        dimLayer = 0.22
    }

    private func markReady() {
        if isReady { return }
        isReady = true

        withAnimation(.easeOut(duration: 0.28)) {
            fadeIn = true
            dimLayer = 0.0
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.10)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.1)

                Text("Loading…")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(MisterChickenTheme.Colors.textPrimary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(MisterChickenTheme.Colors.surfaceStrong)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(MisterChickenTheme.Colors.borderSoft, lineWidth: 1)
                    )
                    .shadow(color: MisterChickenTheme.Colors.shadow, radius: 10, x: 0, y: 6)
            )
        }
        .transition(.opacity)
        .animation(.easeOut(duration: 0.22), value: isReady)
    }
}
