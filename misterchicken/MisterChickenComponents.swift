import SwiftUI
import Combine

enum MisterChickenComponents {

    struct Pill: View {
        let title: String
        let systemIcon: String?
        let action: (() -> Void)?

        init(title: String, systemIcon: String? = nil, action: (() -> Void)? = nil) {
            self.title = title
            self.systemIcon = systemIcon
            self.action = action
        }

        var body: some View {
            Button {
                action?()
            } label: {
                HStack(spacing: 8) {
                    if let systemIcon {
                        Image(systemName: systemIcon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(MisterChickenTheme.Colors.goldSoft.opacity(0.95))
                    }

                    Text(title)
                        .font(MisterChickenTheme.Fonts.caption(14))
                        .foregroundColor(MisterChickenTheme.Colors.textPrimary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: MisterChickenTheme.Layout.pillCorner, style: .continuous)
                        .fill(MisterChickenTheme.Colors.surfaceStrong)
                        .overlay(
                            RoundedRectangle(cornerRadius: MisterChickenTheme.Layout.pillCorner, style: .continuous)
                                .stroke(MisterChickenTheme.Colors.borderSoft, lineWidth: 1)
                        )
                        .shadow(color: MisterChickenTheme.Colors.shadow, radius: 10, x: 0, y: 6)
                )
            }
            .buttonStyle(.plain)
        }
    }

    struct Card<Content: View>: View {
        let title: String?
        let content: Content

        init(title: String? = nil, @ViewBuilder content: () -> Content) {
            self.title = title
            self.content = content()
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                if let title {
                    Text(title)
                        .font(MisterChickenTheme.Fonts.caption(13))
                        .foregroundColor(MisterChickenTheme.Colors.textSecondary)
                }

                content
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
                    .shadow(color: MisterChickenTheme.Colors.shadow, radius: 12, x: 0, y: 8)
            )
        }
    }

    struct GlowDivider: View {
        var body: some View {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.0),
                            MisterChickenTheme.Colors.goldSoft.opacity(0.55),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
        }
    }

    struct Badge: View {
        let text: String

        init(_ text: String) {
            self.text = text
        }

        var body: some View {
            Text(text)
                .font(MisterChickenTheme.Fonts.caption(12))
                .foregroundColor(MisterChickenTheme.Colors.textPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(MisterChickenTheme.Colors.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(MisterChickenTheme.Colors.borderSoft, lineWidth: 1)
                        )
                )
        }
    }
}
