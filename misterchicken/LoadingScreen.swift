import SwiftUI
import Combine

struct LoadingScreen: View {
    let onFinish: () -> Void

    @State private var progress: Double = 0
    @State private var isVisible: Bool = true

    @State private var shimmer: CGFloat = -0.9
    @State private var pulse: Bool = false

    @State private var spin: Double = 0
    @State private var wobble: Bool = false

    private let total = MisterChickenAssets.Motion.loadingDuration

    var body: some View {
        ZStack {
            MisterChickenTheme.backgroundGradient
                .ignoresSafeArea()

            ambientLayer
            centerReelLayer

            VStack(spacing: 0) {
                Spacer()

                progressCard
                    .padding(.horizontal, 22)
                    .padding(.bottom, 28)
            }
        }
        .opacity(isVisible ? 1 : 0)
        .animation(.easeOut(duration: MisterChickenAssets.Motion.fadeOutDuration), value: isVisible)
        .onAppear { start() }
    }

    private var ambientLayer: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)

            ZStack {
                Color.black.opacity(0.15)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                MisterChickenTheme.Colors.glow.opacity(0.34),
                                MisterChickenTheme.Colors.plum.opacity(0.16),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 8,
                            endRadius: side * 0.34
                        )
                    )
                    .frame(width: side * 0.82, height: side * 0.82)
                    .position(x: geo.size.width * 0.22, y: geo.size.height * 0.26)
                    .blur(radius: 18)
                    .scaleEffect(pulse ? 1.03 : 0.98)
                    .animation(.easeInOut(duration: 1.9).repeatForever(autoreverses: true), value: pulse)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                MisterChickenTheme.Colors.gold.opacity(0.22),
                                MisterChickenTheme.Colors.ember.opacity(0.12),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 8,
                            endRadius: side * 0.28
                        )
                    )
                    .frame(width: side * 0.72, height: side * 0.72)
                    .position(x: geo.size.width * 0.78, y: geo.size.height * 0.40)
                    .blur(radius: 18)
                    .scaleEffect(pulse ? 1.02 : 0.97)
                    .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: pulse)

                Rectangle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.clear,
                                Color.black.opacity(0.25),
                                Color.black.opacity(0.58)
                            ],
                            center: .center,
                            startRadius: 160,
                            endRadius: 720
                        )
                    )
                    .blendMode(.multiply)
                    .allowsHitTesting(false)
            }
            .ignoresSafeArea()
        }
    }

    private var centerReelLayer: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width * 0.5, y: geo.size.height * 0.44)

            ZStack {
                ReelFrame()
                    .frame(width: 310, height: 200)
                    .position(center)
                    .shadow(color: MisterChickenTheme.Colors.shadow, radius: 18, x: 0, y: 12)
                    .shadow(color: MisterChickenTheme.Colors.reelGlow, radius: 22, x: 0, y: 0)

                ReelWindow(spin: spin, wobble: wobble)
                    .frame(width: 270, height: 160)
                    .position(center)
                    .offset(y: MisterChickenAssets.Layout.centerLift)

                ReelHighlight()
                    .frame(width: 310, height: 200)
                    .position(center)
                    .blendMode(.screen)
                    .opacity(pulse ? 0.85 : 0.55)
                    .animation(.easeInOut(duration: 1.7).repeatForever(autoreverses: true), value: pulse)
            }
        }
        .allowsHitTesting(false)
    }

    private var progressCard: some View {
        VStack(spacing: 14) {
            progressBar
            thinGlowLine
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: MisterChickenTheme.Layout.corner, style: .continuous)
                .fill(MisterChickenTheme.Colors.surfaceStrong)
                .overlay(
                    RoundedRectangle(cornerRadius: MisterChickenTheme.Layout.corner, style: .continuous)
                        .stroke(MisterChickenTheme.Colors.borderSoft, lineWidth: 1)
                )
                .shadow(color: MisterChickenTheme.Colors.shadow, radius: 14, x: 0, y: 10)
                .shadow(color: MisterChickenTheme.Colors.glow.opacity(0.9), radius: 20, x: 0, y: 0)
        )
    }

    private var progressBar: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: h / 2, style: .continuous)
                    .fill(Color.white.opacity(0.08))

                RoundedRectangle(cornerRadius: h / 2, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                MisterChickenTheme.Colors.gold.opacity(0.96),
                                MisterChickenTheme.Colors.goldSoft.opacity(0.92),
                                MisterChickenTheme.Colors.glow.opacity(0.80)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(10, w * progress))
                    .overlay(shimmerOverlay(height: h))
                    .shadow(color: MisterChickenTheme.Colors.glow, radius: 14, x: 0, y: 0)

                RoundedRectangle(cornerRadius: h / 2, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            }
            .animation(.easeInOut(duration: 0.18), value: progress)
        }
        .frame(height: MisterChickenTheme.Layout.barHeight)
    }

    private func shimmerOverlay(height: CGFloat) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.22),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .rotationEffect(.degrees(18))
            .offset(x: shimmer * 220, y: 0)
            .blendMode(.screen)
            .mask(RoundedRectangle(cornerRadius: height / 2, style: .continuous))
            .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: false), value: shimmer)
            .allowsHitTesting(false)
    }

    private var thinGlowLine: some View {
        RoundedRectangle(cornerRadius: 2, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.0),
                        MisterChickenTheme.Colors.goldSoft.opacity(0.65),
                        Color.white.opacity(0.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 2)
            .opacity(pulse ? 1.0 : 0.65)
            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
    }

    private func start() {
        pulse = true
        wobble = true

        withAnimation(.linear(duration: 1.15).repeatForever(autoreverses: false)) {
            spin = Double.pi * 2.0
        }

        shimmer = 0.9

        let steps = 45
        let interval = total / Double(steps)

        var current = 0
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            current += 1

            let t = min(1.0, Double(current) / Double(steps))
            let eased = t < 0.85 ? (t / 0.85) : (0.96 + (t - 0.85) * 0.04 / 0.15)
            progress = min(1.0, max(0.0, eased))

            if current >= steps {
                timer.invalidate()
                finish()
            }
        }
    }

    private func finish() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
            isVisible = false
            DispatchQueue.main.asyncAfter(deadline: .now() + MisterChickenAssets.Motion.fadeOutDuration) {
                onFinish()
            }
        }
    }
}

private enum ReelSymbol {
    case s1, s2, s3

    var image: Image {
        switch self {
        case .s1: return MisterChickenAssets.Images.symbol1
        case .s2: return MisterChickenAssets.Images.symbol2
        case .s3: return MisterChickenAssets.Images.symbol3
        }
    }
}

private struct ReelWindow: View {
    let spin: Double
    let wobble: Bool

    var body: some View {
        let maskShape = RoundedRectangle(cornerRadius: 18, style: .continuous)

        ZStack {
            HStack(spacing: MisterChickenAssets.Layout.reelSpacing) {
                ReelStrip(symbols: [.s1, .s2, .s3], baseShift: 0.00, spin: spin)
                ReelStrip(symbols: [.s2, .s3, .s1], baseShift: 0.16, spin: spin)
                ReelStrip(symbols: [.s3, .s1, .s2], baseShift: 0.33, spin: spin)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.22))
            .clipShape(maskShape)

            VStack {
                LinearGradient(
                    colors: [Color.black.opacity(0.65), Color.black.opacity(0.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 34)

                Spacer()

                LinearGradient(
                    colors: [Color.black.opacity(0.0), Color.black.opacity(0.65)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 34)
            }
            .clipShape(maskShape)
            .allowsHitTesting(false)

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)

            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.00),
                            MisterChickenTheme.Colors.goldSoft.opacity(0.20),
                            Color.white.opacity(0.00)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 44)
                .blendMode(.screen)
                .opacity(0.55)
        }
        .rotationEffect(.degrees(wobble ? 0.55 : -0.55))
        .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: wobble)
        .mask(maskShape)
    }
}

private struct ReelStrip: View {
    let symbols: [ReelSymbol]
    let baseShift: Double
    let spin: Double

    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            let cell = h / 3.0

            let phase = (spin / (Double.pi * 2.0)) + baseShift
            let u = phase - floor(phase)
            let y = CGFloat(-u) * cell

            VStack(spacing: 0) {
                ForEach(0..<6, id: \.self) { i in
                    symbols[i % symbols.count]
                        .image
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width, height: cell)
                        .padding(.vertical, 2)
                        .opacity(0.98)
                }
            }
            .offset(y: y)
        }
        .frame(width: MisterChickenAssets.Layout.symbolSize * 0.62, height: MisterChickenAssets.Layout.symbolSize * 1.10)
        .clipped()
    }
}

private struct ReelFrame: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        MisterChickenTheme.Colors.surfaceStrong,
                        Color.black.opacity(0.72)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(MisterChickenTheme.Colors.goldSoft.opacity(0.22), lineWidth: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    .padding(6)
            )
    }
}

private struct ReelHighlight: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.10),
                        Color.white.opacity(0.00),
                        Color.white.opacity(0.04)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .blur(radius: 0.5)
    }
}
