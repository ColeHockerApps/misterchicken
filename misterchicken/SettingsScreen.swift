import SwiftUI
import Combine

struct SettingsScreen: View {

    @EnvironmentObject private var haptics: HapticsManager
    @EnvironmentObject private var orientation: CoopOrientationManager

    @State private var soundOn: Bool = true
    @State private var hapticsOn: Bool = true
    @State private var dimOn: Bool = false

    var body: some View {
        ZStack {
            MisterChickenTheme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 14) {
                header

                VStack(spacing: 12) {
                    toggleRow(
                        title: "Sound",
                        subtitle: "Classic slot vibes",
                        isOn: $soundOn
                    ) {
                        haptics.select()
                    }

                    toggleRow(
                        title: "Haptics",
                        subtitle: "Taps feel snappy",
                        isOn: $hapticsOn
                    ) {
                        if hapticsOn { haptics.light() }
                    }

                    toggleRow(
                        title: "Dim Effects",
                        subtitle: "Softer lights",
                        isOn: $dimOn
                    ) {
                        haptics.light()
                    }

//                    actionRow(
//                        title: "Re-center Screen",
//                        subtitle: "Keeps the stage stable"
//                    ) {
//                        orientation.lockLandscape()
//                        haptics.medium()
//                    }
                }
                .padding(.horizontal, 18)

                Spacer()
            }
            .padding(.top, 16)
        }
    }

    private var header: some View {
        HStack {
            Text("Settings")
                .font(MisterChickenTheme.Fonts.title(22))
                .foregroundColor(MisterChickenTheme.Colors.textPrimary)

            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            MisterChickenTheme.Colors.surface
                .ignoresSafeArea(edges: .top)
        )
    }

    private func toggleRow(
        title: String,
        subtitle: String,
        isOn: Binding<Bool>,
        onToggle: @escaping () -> Void
    ) -> some View {
        Button {
            isOn.wrappedValue.toggle()
            onToggle()
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(MisterChickenTheme.Fonts.body(16))
                        .foregroundColor(MisterChickenTheme.Colors.textPrimary)

                    Text(subtitle)
                        .font(MisterChickenTheme.Fonts.body(13))
                        .foregroundColor(MisterChickenTheme.Colors.textSecondary)
                }

                Spacer()

                Toggle("", isOn: isOn)
                    .labelsHidden()
                    .allowsHitTesting(false)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: MisterChickenTheme.Layout.corner, style: .continuous)
                    .fill(MisterChickenTheme.Colors.surfaceStrong)
                    .overlay(
                        RoundedRectangle(cornerRadius: MisterChickenTheme.Layout.corner, style: .continuous)
                            .stroke(MisterChickenTheme.Colors.borderSoft, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func actionRow(
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(MisterChickenTheme.Fonts.body(16))
                        .foregroundColor(MisterChickenTheme.Colors.textPrimary)

                    Text(subtitle)
                        .font(MisterChickenTheme.Fonts.body(13))
                        .foregroundColor(MisterChickenTheme.Colors.textSecondary)
                }

                Spacer()

                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(MisterChickenTheme.Colors.goldSoft.opacity(0.9))
                    .padding(.leading, 6)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: MisterChickenTheme.Layout.corner, style: .continuous)
                    .fill(MisterChickenTheme.Colors.surfaceStrong)
                    .overlay(
                        RoundedRectangle(cornerRadius: MisterChickenTheme.Layout.corner, style: .continuous)
                            .stroke(MisterChickenTheme.Colors.borderSoft, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
