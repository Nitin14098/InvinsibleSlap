import SwiftUI

struct ProfileView: View {
    @AppStorage("neurotap.profile.displayName") private var displayName = ""
    @AppStorage("neurotap.profile.dailyFocusGoal") private var dailyFocusGoal = 60.0
    @AppStorage("neurotap.profile.showCompletionMessages") private var showCompletionMessages = true
    @AppStorage("neurotap.profile.hapticsEnabled") private var hapticsEnabled = true
    @AppStorage("neurotap.appearance") private var appearance = "system"
    @AppStorage("neurotap.hasEnteredApp") private var hasEnteredApp = false
    @State private var showingResetConfirmation = false

    var body: some View {
        ZStack {
            NeuroTapStyle.background.ignoresSafeArea()
            Form {
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: "person.crop.circle.fill").font(.system(size: 54)).foregroundStyle(NeuroTapStyle.violet)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(displayName.isEmpty ? "NeuroTap learner" : displayName).font(.headline)
                            Text("Personal profile").font(.caption).foregroundStyle(NeuroTapStyle.muted)
                        }
                    }.listRowBackground(NeuroTapStyle.surface)
                    TextField("Display name", text: $displayName).listRowBackground(NeuroTapStyle.surface)
                } header: { Text("PROFILE") }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack { Text("Daily focus goal"); Spacer(); Text("\(Int(dailyFocusGoal)) min").foregroundStyle(NeuroTapStyle.cyan).bold() }
                        Slider(value: $dailyFocusGoal, in: 15...240, step: 15)
                            .tint(NeuroTapStyle.violet)
                    }.listRowBackground(NeuroTapStyle.surface)
                    Toggle("Completion messages", isOn: $showCompletionMessages).tint(NeuroTapStyle.violet).listRowBackground(NeuroTapStyle.surface)
                    Toggle("Haptic feedback", isOn: $hapticsEnabled).tint(NeuroTapStyle.violet).listRowBackground(NeuroTapStyle.surface)
                } header: { Text("PREFERENCES") }

                Section {
                    Picker("Appearance", selection: $appearance) {
                        Text("System default").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .listRowBackground(NeuroTapStyle.surface)
                } header: { Text("APPEARANCE") }

                Section {
                    Label("Data is currently stored on this device", systemImage: "iphone.gen3")
                        .font(.subheadline).listRowBackground(NeuroTapStyle.surface)
                    Text("Cloud accounts and cross-device sync are not connected yet.")
                        .font(.caption).foregroundStyle(NeuroTapStyle.muted).listRowBackground(NeuroTapStyle.surface)
                } header: { Text("ACCOUNT & SYNC") }

                Section {
                    Button("Reset profile preferences", role: .destructive) { showingResetConfirmation = true }
                        .listRowBackground(NeuroTapStyle.surface)
                    Button("Sign out", role: .destructive) { hasEnteredApp = false }
                        .listRowBackground(NeuroTapStyle.surface)
                }
            }
            .scrollContentBackground(.hidden)
            .foregroundStyle(NeuroTapStyle.primaryText)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Reset profile preferences?", isPresented: $showingResetConfirmation, titleVisibility: .visible) {
            Button("Reset preferences", role: .destructive) {
                displayName = ""
                dailyFocusGoal = 60
                showCompletionMessages = true
                hapticsEnabled = true
                appearance = "system"
            }
            Button("Cancel", role: .cancel) {}
        } message: { Text("Your recorded Memory, Reflex, and Focus history will not be deleted.") }
    }
}

#Preview { NavigationStack { ProfileView() } }
