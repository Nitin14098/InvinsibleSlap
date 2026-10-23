
import SwiftUI

// MARK: - App Features

enum NeuroTapFeature: String, CaseIterable, Identifiable, Hashable {
    case chat = "Let's Chat"
    case memory = "Memory Lab"
    case focus = "Focus Mode"
    case reflex = "Reflex Lab"
    case insights = "Insights"
    case profile = "Profile"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .chat: return "Your personal AI study companion"
        case .memory: return "Challenge your memory and reasoning"
        case .focus: return "Build focused study sessions"
        case .reflex: return "Test your reaction speed"
        case .insights: return "Explore your recorded practice"
        case .profile: return "Your account and preferences"
        }
    }

    var symbol: String {
        switch self {
        case .chat: return "bubble.left.and.bubble.right.fill"
        case .memory: return "brain.head.profile"
        case .focus: return "timer"
        case .reflex: return "bolt.fill"
        case .insights: return "chart.xyaxis.line"
        case .profile: return "person.crop.circle"
        }
    }

    var accent: Color {
        switch self {
        case .chat: return NeuroTapStyle.cyan
        case .memory: return NeuroTapStyle.violet
        case .focus: return NeuroTapStyle.cyan
        case .reflex: return .green
        case .insights: return NeuroTapStyle.violet
        case .profile: return .orange
        }
    }

    var detail: String {
        switch self {
        case .chat:
            return "Ask questions, explore concepts, and learn through conversation."
        case .memory:
            return "Practise memory, aptitude, and reasoning through interactive exercises."
        case .focus:
            return "Plan a focused study block and track your session."
        case .reflex:
            return "Play reaction rounds, avoid false starts, and review your results."
        case .insights:
            return "Review activity and performance recorded by NeuroTap."
        case .profile:
            return "Manage your profile, account, and app preferences."
        }
    }
}

// MARK: - App Entry and Home

struct Content: View {
    @AppStorage("neurotap.hasEnteredApp") private var hasEnteredApp = false
    @AppStorage("neurotap.appearance") private var appearance = "system"
    @AppStorage("neurotap.profile.displayName") private var displayName = ""
    @State private var selectedFeature: NeuroTapFeature?

    var body: some View {
        Group {
            if hasEnteredApp {
                homeScreen
            } else {
                WelcomeGateView { hasEnteredApp = true }
            }
        }
        .preferredColorScheme(colorScheme)
        .tint(NeuroTapStyle.violet)
    }

    private var colorScheme: ColorScheme? {
        switch appearance {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    private var homeScreen: some View {
        NavigationStack {
            ZStack {
                NeuroTapStyle.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        header
                        welcomeSection
                        VStack(alignment: .leading, spacing: 13) {
                            HStack(alignment: .bottom) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("YOUR TOOLKIT").font(.caption.weight(.bold)).tracking(1.8).foregroundStyle(NeuroTapStyle.muted)
                                    Text("Choose your next session").font(.title3.bold()).foregroundStyle(NeuroTapStyle.primaryText)
                                }
                                Spacer()
                                Text("\(NeuroTapFeature.allCases.count) TOOLS")
                                    .font(.caption2.weight(.bold)).foregroundStyle(NeuroTapStyle.violet)
                                    .padding(.horizontal, 10).padding(.vertical, 7)
                                    .background(NeuroTapStyle.violet.opacity(0.12)).clipShape(Capsule())
                            }
                            ForEach(NeuroTapFeature.allCases) { feature in
                                Button { selectedFeature = feature } label: { FeatureCard(feature: feature) }
                                    .buttonStyle(.plain)
                            }
                        }
                        footer
                    }
                    .padding(.horizontal, 20).padding(.top, 14).padding(.bottom, 32)
                    .frame(maxWidth: 620).frame(maxWidth: .infinity)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $selectedFeature) { feature in
                switch feature {
                case .chat: FeatureDetailView(feature: .chat)
                case .memory: MemoryLabView()
                case .focus: FocusModeView()
                case .reflex: ReflexLabView()
                case .insights: InsightsView()
                case .profile: ProfileView()
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16).fill(NeuroTapStyle.violet.opacity(0.15)).frame(width: 50, height: 50)
                Image(systemName: "brain.head.profile").font(.system(size: 24, weight: .semibold)).foregroundStyle(NeuroTapStyle.cyan)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("NeuroTap").font(.title2.bold()).foregroundStyle(NeuroTapStyle.primaryText)
                Text("COGNITIVE FITNESS").font(.system(size: 10, weight: .bold)).tracking(1.8).foregroundStyle(NeuroTapStyle.muted)
            }
            Spacer()
            Button { selectedFeature = .profile } label: {
                Image(systemName: "person.crop.circle").font(.system(size: 24, weight: .medium))
                    .foregroundStyle(NeuroTapStyle.primaryText).frame(width: 44, height: 44)
                    .background(NeuroTapStyle.surface).clipShape(Circle())
                    .overlay(Circle().stroke(NeuroTapStyle.outline, lineWidth: 1))
            }
            .accessibilityLabel("Open profile and settings")
        }
    }

    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text(greeting).font(.subheadline.weight(.semibold)).foregroundStyle(NeuroTapStyle.cyan)
            Text("A sharper mind,\none session at a time.")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(NeuroTapStyle.primaryText).fixedSize(horizontal: false, vertical: true)
            Text("Build focus, train memory, and track your practice.")
                .font(.subheadline).foregroundStyle(NeuroTapStyle.muted).fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 8) {
                Circle().fill(NeuroTapStyle.cyan).frame(width: 7, height: 7)
                Text("READY WHEN YOU ARE").font(.caption.weight(.bold)).tracking(1.3).foregroundStyle(NeuroTapStyle.muted)
            }.padding(.top, 3)
        }
        .padding(22).frame(maxWidth: .infinity, alignment: .leading)
        .background(LinearGradient(colors: [NeuroTapStyle.violet.opacity(0.15), NeuroTapStyle.cyan.opacity(0.06), NeuroTapStyle.surface], startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .overlay(RoundedRectangle(cornerRadius: 26).stroke(NeuroTapStyle.outline, lineWidth: 1))
    }

    private var greeting: String {
        let name = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "WELCOME TO YOUR TRAINING SPACE" : "WELCOME BACK, \(name.uppercased())"
    }

    private var footer: some View {
        VStack(spacing: 8) {
            Image(systemName: "waveform.path").font(.title2).foregroundStyle(NeuroTapStyle.violet)
            Text("Progress comes from practice.").font(.subheadline.weight(.medium)).foregroundStyle(NeuroTapStyle.muted)
            Text("NeuroTap is a learning and wellness prototype, not a medical diagnostic tool.")
                .font(.caption2).multilineTextAlignment(.center).foregroundStyle(NeuroTapStyle.muted.opacity(0.85))
        }.frame(maxWidth: .infinity).padding(.top, 8)
    }
}

// MARK: - Welcome and optional sign-in

private struct WelcomeGateView: View {
    let onEnter: () -> Void
    @AppStorage("neurotap.profile.displayName") private var savedDisplayName = ""
    @AppStorage("neurotap.profile.email") private var savedEmail = ""
    @State private var showingSignIn = false
    @State private var email = ""
    @State private var password = ""
    @State private var message: String?

    var body: some View {
        ZStack {
            NeuroTapStyle.background.ignoresSafeArea()
            Circle().fill(NeuroTapStyle.violet.opacity(0.16)).frame(width: 280, height: 280).blur(radius: 70).offset(x: 170, y: -300)
            Circle().fill(NeuroTapStyle.cyan.opacity(0.10)).frame(width: 240, height: 240).blur(radius: 65).offset(x: -160, y: 300)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    Spacer(minLength: 32)
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(LinearGradient(colors: [NeuroTapStyle.violet, NeuroTapStyle.cyan.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 92, height: 92)
                        Image(systemName: "brain.head.profile").font(.system(size: 43, weight: .medium)).foregroundStyle(.white)
                    }
                    VStack(spacing: 10) {
                        Text("NeuroTap").font(.system(size: 36, weight: .bold, design: .rounded)).foregroundStyle(NeuroTapStyle.primaryText)
                        Text(showingSignIn ? "Pick up where you left off." : "Your mind is worth training.")
                            .font(.title3.weight(.medium)).foregroundStyle(NeuroTapStyle.primaryText)
                        Text(showingSignIn ? "Enter your details to continue on this device." : "A calmer focus. A stronger memory. Better everyday practice.")
                            .font(.subheadline).multilineTextAlignment(.center).foregroundStyle(NeuroTapStyle.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }.padding(.horizontal, 12)

                    VStack(spacing: 13) {
                        if showingSignIn {
                            VStack(spacing: 12) {
                                TextField("Email address", text: $email)
                                    .textContentType(.emailAddress).keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never).autocorrectionDisabled()
                                    .padding(16).background(NeuroTapStyle.background)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(NeuroTapStyle.outline, lineWidth: 1))
                                SecureField("Password", text: $password).textContentType(.password)
                                    .padding(16).background(NeuroTapStyle.background)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(NeuroTapStyle.outline, lineWidth: 1))
                                Text("Prototype sign-in only: no server verifies accounts yet. Your email is saved locally; your password is never saved.")
                                    .font(.caption2).foregroundStyle(NeuroTapStyle.muted).fixedSize(horizontal: false, vertical: true)
                                if let message { Text(message).font(.caption).foregroundStyle(.red) }
                                Button(action: continueWithEmail) {
                                    HStack { Text("Continue"); Spacer(); Image(systemName: "arrow.right") }
                                        .font(.headline).foregroundStyle(.white).padding(17).frame(maxWidth: .infinity)
                                        .background(LinearGradient(colors: [NeuroTapStyle.violet, NeuroTapStyle.cyan.opacity(0.85)], startPoint: .leading, endPoint: .trailing))
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                                Button("Back") { showingSignIn = false; message = nil }
                                    .font(.subheadline.weight(.semibold)).foregroundStyle(NeuroTapStyle.muted).padding(.top, 2)
                            }
                        } else {
                            Button { showingSignIn = true } label: {
                                HStack { Image(systemName: "envelope.fill"); Text("Sign in with email"); Spacer(); Image(systemName: "arrow.right") }
                                    .font(.headline).foregroundStyle(.white).padding(17).frame(maxWidth: .infinity)
                                    .background(LinearGradient(colors: [NeuroTapStyle.violet, NeuroTapStyle.cyan.opacity(0.85)], startPoint: .leading, endPoint: .trailing))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            Button(action: onEnter) {
                                HStack(spacing: 10) { Image(systemName: "bolt.fill"); Text("Quick enter — no login") }
                                    .font(.headline).foregroundStyle(NeuroTapStyle.primaryText).padding(17).frame(maxWidth: .infinity)
                                    .background(NeuroTapStyle.background).clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(NeuroTapStyle.outline, lineWidth: 1))
                            }
                            Text("Start immediately. You can set up your profile later.")
                                .font(.caption).foregroundStyle(NeuroTapStyle.muted).multilineTextAlignment(.center)
                        }
                    }
                    .padding(18).background(NeuroTapStyle.surface.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(NeuroTapStyle.outline, lineWidth: 1))
                    .frame(maxWidth: 460)

                    HStack(spacing: 7) {
                        Image(systemName: "lock.shield")
                        Text("Your activity history stays on this device")
                    }.font(.caption2).foregroundStyle(NeuroTapStyle.muted)
                    Spacer(minLength: 24)
                }.padding(.horizontal, 24).frame(maxWidth: .infinity)
            }
        }
    }

    private func continueWithEmail() {
        let cleaned = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleaned.contains("@"), cleaned.contains(".") else { message = "Enter a valid email address."; return }
        guard password.count >= 4 else { message = "Enter at least 4 characters to continue in this prototype."; return }
        // The password is intentionally not stored. This is a local prototype, not server authentication.
        savedEmail = cleaned
        if savedDisplayName.isEmpty { savedDisplayName = cleaned.components(separatedBy: "@").first ?? "NeuroTap learner" }
        onEnter()
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
                    .foregroundStyle(NeuroTapStyle.primaryText)

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
                .strokeBorder(NeuroTapStyle.outline, lineWidth: 1)
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
                    .foregroundStyle(NeuroTapStyle.primaryText)

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
