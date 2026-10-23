
import SwiftUI

private enum NeuroTapStyle {
    static let background = Color(red: 0.035, green: 0.045, blue: 0.105)
    static let surface = Color(red: 0.075, green: 0.09, blue: 0.17)
    static let violet = Color(red: 0.60, green: 0.43, blue: 1.0)
    static let cyan = Color(red: 0.30, green: 0.85, blue: 0.98)
    static let muted = Color(red: 0.64, green: 0.68, blue: 0.79)
}

private enum NeuroTapFeature: String, CaseIterable, Identifiable {
    case chat = "Let's Chat"
    case memory = "Memory Lab"
    case focus = "Focus & Reflex"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .chat:
            return "Explore ideas. Understand deeply."
        case .memory:
            return "Challenge how you think and remember."
        case .focus:
            return "Sharpen your attention and reaction."
        }
    }

    var symbol: String {
        switch self {
        case .chat: return "bubble.left.and.bubble.right.fill"
        case .memory: return "brain.head.profile"
        case .focus: return "scope"
        }
    }

    var accent: Color {
        switch self {
        case .chat: return NeuroTapStyle.cyan
        case .memory: return NeuroTapStyle.violet
        case .focus: return Color(red: 1.0, green: 0.69, blue: 0.42)
        }
    }

    var detail: String {
        switch self {
        case .chat:
            return "Ask questions, explore new topics, and learn through a natural conversation."
        case .memory:
            return "Choose a Cognitive Memory Test, an Aptitude Test, or a Conceptual Test. Each measures a different skill."
        case .focus:
            return "Try short activities designed to explore reaction speed and sustained attention."
        }
    }
}

struct Content: View {
    @State private var selectedFeature: NeuroTapFeature?

    var body: some View {
        NavigationStack {
            ZStack {
                NeuroTapStyle.background
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        header
                        welcomeSection
                        featureSection
                        footer
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 18)
                    .padding(.bottom, 32)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $selectedFeature) { feature in
                FeatureDetailView(feature: feature)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(NeuroTapStyle.violet.opacity(0.18))
                    .frame(width: 48, height: 48)

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 25, weight: .medium))
                    .foregroundStyle(NeuroTapStyle.cyan)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("NEUROTAP")
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .tracking(2.2)
                    .foregroundStyle(.white)

                Text("YOUR PERSONAL STUDY SPACE")
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(NeuroTapStyle.muted)
            }

            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(NeuroTapStyle.violet)
                .padding(12)
                .background(NeuroTapStyle.surface, in: Circle())
        }
    }

    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("YOUR MIND, YOUR JOURNEY")
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundStyle(NeuroTapStyle.cyan)

            Text("Train your mind.\nExplore what you love.")
                .font(.system(size: 35, weight: .bold, design: .rounded))
                .tracking(-1)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text("Learn out of curiosity. Challenge yourself.\nGrow one discovery at a time.")
                .font(.system(size: 14))
                .foregroundStyle(NeuroTapStyle.muted)
                .lineSpacing(5)

            HStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(NeuroTapStyle.cyan)

                Text("No pressure. Just progress.")
                    .foregroundStyle(.white.opacity(0.9))
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 10)
            .background(NeuroTapStyle.cyan.opacity(0.09), in: Capsule())
        }
        .padding(.top, 10)
    }

    private var featureSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("YOUR SPACE")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.8)
                    .foregroundStyle(NeuroTapStyle.muted)

                Spacer()

                Text("3 EXPERIENCES")
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(1)
                    .foregroundStyle(NeuroTapStyle.violet)
            }

            ForEach(NeuroTapFeature.allCases) { feature in
                Button {
                    selectedFeature = feature
                } label: {
                    FeatureCard(feature: feature)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 8) {
            Image(systemName: "infinity")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(NeuroTapStyle.violet.opacity(0.8))

            Text("Every great mind starts with curiosity.")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(NeuroTapStyle.muted)
                .multilineTextAlignment(.center)

            Text("NEUROTAP • BUILT FOR THE CURIOUS")
                .font(.system(size: 8, weight: .semibold))
                .tracking(1.5)
                .foregroundStyle(NeuroTapStyle.muted.opacity(0.65))
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }
}

private struct FeatureCard: View {
    let feature: NeuroTapFeature

    var body: some View {
        HStack(spacing: 15) {
            RoundedRectangle(cornerRadius: 16)
                .fill(feature.accent.opacity(0.13))
                .frame(width: 55, height: 55)
                .overlay {
                    Image(systemName: feature.symbol)
                        .font(.system(size: 23, weight: .medium))
                        .foregroundStyle(feature.accent)
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(feature.rawValue)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(feature.subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(NeuroTapStyle.muted)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Image(systemName: "arrow.up.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(feature.accent)
                .padding(9)
                .background(feature.accent.opacity(0.10), in: Circle())
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NeuroTapStyle.surface, in: RoundedRectangle(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(.white.opacity(0.055), lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: 22))
    }
}

private struct FeatureDetailView: View {
    let feature: NeuroTapFeature

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            NeuroTapStyle.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Button {
                    dismiss()
                } label: {
                    Label("Back to NeuroTap", systemImage: "arrow.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(NeuroTapStyle.cyan)
                }
                .buttonStyle(.plain)

                Spacer()

                Image(systemName: feature.symbol)
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(feature.accent)
                    .frame(width: 100, height: 100)
                    .background(feature.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 28))

                Text(feature.rawValue)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(feature.detail)
                    .font(.system(size: 16))
                    .foregroundStyle(NeuroTapStyle.muted)
                    .lineSpacing(6)

                Text("This experience is our next build step.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(feature.accent)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(feature.accent.opacity(0.09), in: RoundedRectangle(cornerRadius: 14))

                Spacer()
                Spacer()
            }
            .padding(24)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    Content()
}
