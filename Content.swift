
import SwiftUI

// MARK: - App Theme

enum NeuroTapStyle {
    static let background = Color(
        red: 0.035, green: 0.045, blue: 0.105
    )

    static let surface = Color(
        red: 0.075, green: 0.09, blue: 0.17
    )

    static let violet = Color(
        red: 0.60, green: 0.43, blue: 1.0
    )

    static let cyan = Color(
        red: 0.30, green: 0.85, blue: 0.98
    )

    static let muted = Color(
        red: 0.64, green: 0.68, blue: 0.79
    )
}

// MARK: - App Features

enum NeuroTapFeature: String, CaseIterable, Identifiable, Hashable {
    case chat = "Let's Chat"
    case memory = "Memory Lab"
    case focus = "Focus & Reflex"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .chat:
            return "Your personal AI study companion"
        case .memory:
            return "Challenge your memory and reasoning"
        case .focus:
            return "Test your reaction speed"
        }
    }

    var symbol: String {
        switch self {
        case .chat:
            return "bubble.left.and.bubble.right.fill"
        case .memory:
            return "brain.head.profile"
        case .focus:
            return "bolt.fill"
        }
    }

    var accent: Color {
        switch self {
        case .chat:
            return NeuroTapStyle.cyan
        case .memory:
            return NeuroTapStyle.violet
        case .focus:
            return Color.green
        }
    }

    var detail: String {
        switch self {
        case .chat:
            return "Ask questions, explore concepts, and learn through conversation."
        case .memory:
            return "Practise cognitive memory, aptitude, and conceptual understanding."
        case .focus:
            return "Play reaction rounds, avoid false starts, and review your results."
        }
    }
}

// MARK: - Home Screen

struct Content: View {
    @State private var selectedFeature: NeuroTapFeature?

    var body: some View {
        NavigationStack {
            ZStack {
                NeuroTapStyle.background
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 26) {
                        header

                        welcomeSection

                        VStack(alignment: .leading, spacing: 14) {
                            Text("YOUR EXPERIENCE")
                                .font(.caption.weight(.bold))
                                .tracking(2)
                                .foregroundStyle(NeuroTapStyle.muted)

                            ForEach(NeuroTapFeature.allCases) { feature in
                                Button {
                                    selectedFeature = feature
                                } label: {
                                    FeatureCard(feature: feature)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        footer
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 20)
                    .padding(.bottom, 32)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $selectedFeature) { feature in
                switch feature {
                case .chat:
                    FeatureDetailView(feature: .chat)

                case .memory:
                    MemoryLabView()

                case .focus:
                    ReflexLabView()
                }
            }
        }
        .tint(.white)
        .preferredColorScheme(.dark)
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(NeuroTapStyle.violet.opacity(0.18))
                    .frame(width: 48, height: 48)

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundStyle(NeuroTapStyle.cyan)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("NeuroTap")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text("TRAIN YOUR MIND")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(NeuroTapStyle.muted)
            }

            Spacer()

            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundStyle(NeuroTapStyle.violet)
        }
    }

    // MARK: Welcome

    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your mind.\nYour next level.")
                .font(.system(size: 35, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text("Train your mind. Explore what you love.")
                .font(.subheadline)
                .foregroundStyle(NeuroTapStyle.muted)

            HStack(spacing: 8) {
                Image(systemName: "circle.fill")
                    .font(.system(size: 7))
                    .foregroundStyle(NeuroTapStyle.cyan)

                Text("READY WHEN YOU ARE")
                    .font(.caption.weight(.bold))
                    .tracking(1.5)
                    .foregroundStyle(NeuroTapStyle.cyan)
            }
            .padding(.top, 5)
        }
        .padding(.vertical, 8)
    }

    // MARK: Footer

    private var footer: some View {
        VStack(spacing: 8) {
            Image(systemName: "waveform.path")
                .font(.title2)
                .foregroundStyle(NeuroTapStyle.violet)

            Text("Progress comes from practice.")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(NeuroTapStyle.muted)

            Text("NeuroTap is a learning and wellness prototype, not a medical diagnostic tool.")
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundStyle(NeuroTapStyle.muted.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}

// MARK: - Feature Card

private struct FeatureCard: View {
    let feature: NeuroTapFeature

    var body: some View {
        HStack(spacing: 15) {
            RoundedRectangle(cornerRadius: 15)
                .fill(feature.accent.opacity(0.15))
                .frame(width: 54, height: 54)
                .overlay {
                    Image(systemName: feature.symbol)
                        .font(.system(size: 23, weight: .semibold))
                        .foregroundStyle(feature.accent)
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(feature.rawValue)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(feature.subtitle)
                    .font(.caption)
                    .foregroundStyle(NeuroTapStyle.muted)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 4)

            Image(systemName: "arrow.up.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(feature.accent)
        }
        .padding(16)
        .background(NeuroTapStyle.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(.white.opacity(0.06), lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Chat Placeholder

private struct FeatureDetailView: View {
    let feature: NeuroTapFeature

    var body: some View {
        ZStack {
            NeuroTapStyle.background
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Image(systemName: feature.symbol)
                    .font(.system(size: 44))
                    .foregroundStyle(feature.accent)

                Text(feature.rawValue)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                Text(feature.detail)
                    .font(.body)
                    .foregroundStyle(NeuroTapStyle.muted)
                    .multilineTextAlignment(.center)

                Text("This experience is being built.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(feature.accent)
                    .padding(.top, 8)
            }
            .padding(28)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    Content()
}
