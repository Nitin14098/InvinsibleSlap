import SwiftUI
import Combine

struct FocusModeView: View {
    @State private var selectedMinutes = 25
    @State private var remainingSeconds = 25 * 60
    @State private var isRunning = false
    @State private var isPaused = false
    @State private var hasSavedCurrentSession = false
    @State private var sessionStartedAt: Date?
    @State private var elapsedBeforePause = 0
    @State private var showingResetConfirmation = false

    private let presets = [15, 25, 45]
    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var plannedSeconds: Int { selectedMinutes * 60 }
    private var elapsedSeconds: Int { max(0, plannedSeconds - remainingSeconds) }
    private var progress: Double { plannedSeconds > 0 ? Double(elapsedSeconds) / Double(plannedSeconds) : 0 }

    var body: some View {
        ZStack {
            NeuroTapStyle.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 26) {
                    VStack(spacing: 8) {
                        Text("FOCUS MODE").font(.caption.bold()).tracking(2).foregroundStyle(NeuroTapStyle.cyan)
                        Text("Make this time yours.").font(.title.bold()).foregroundStyle(NeuroTapStyle.primaryText)
                        Text("Choose a block, start when ready, and give one task your attention.")
                            .font(.subheadline).foregroundStyle(NeuroTapStyle.muted).multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    ZStack {
                        Circle().stroke(NeuroTapStyle.outline, lineWidth: 13)
                        Circle().trim(from: 0, to: progress).stroke(NeuroTapStyle.cyan, style: StrokeStyle(lineWidth: 13, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        VStack(spacing: 8) {
                            Text(timeString(remainingSeconds)).font(.system(size: 42, weight: .bold, design: .rounded)).monospacedDigit().foregroundStyle(NeuroTapStyle.primaryText)
                            Text(isRunning ? (isPaused ? "PAUSED" : "STAY WITH IT") : "READY TO FOCUS")
                                .font(.caption.bold()).tracking(1.4).foregroundStyle(NeuroTapStyle.muted)
                        }
                    }
                    .frame(width: 250, height: 250).padding(.vertical, 4)

                    HStack(spacing: 10) {
                        ForEach(presets, id: \.self) { minutes in
                            Button {
                                guard !isRunning else { return }
                                selectedMinutes = minutes
                                remainingSeconds = minutes * 60
                            } label: {
                                Text("\(minutes) min")
                                    .font(.subheadline.bold()).frame(maxWidth: .infinity).padding(.vertical, 13)
                                    .background(selectedMinutes == minutes ? NeuroTapStyle.violet.opacity(0.28) : NeuroTapStyle.surface)
                                    .foregroundStyle(NeuroTapStyle.primaryText).clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(selectedMinutes == minutes ? NeuroTapStyle.violet : .clear, lineWidth: 1.5))
                            }.buttonStyle(.plain).disabled(isRunning)
                        }
                    }

                    HStack(spacing: 12) {
                        Button {
                            if !isRunning { startSession() }
                            else if isPaused { isPaused = false }
                            else { isPaused = true }
                        } label: {
                            Label(primaryButtonTitle, systemImage: primaryButtonSymbol)
                                .font(.headline).frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(NeuroTapStyle.violet).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        Button {
                            if isRunning && elapsedSeconds > 0 { saveSession(completed: false) }
                            resetTimer()
                        } label: {
                            Image(systemName: "arrow.counterclockwise").font(.headline).frame(width: 54, height: 54)
                                .background(NeuroTapStyle.surface).foregroundStyle(NeuroTapStyle.primaryText).clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .accessibilityLabel("Reset focus timer")
                    }

                    HStack(spacing: 12) {
                        summaryTile(title: "Completed blocks", value: "\(FocusHistoryStore.completedSessionCount())")
                        summaryTile(title: "Total focus", value: "\(FocusHistoryStore.totalCompletedSeconds() / 60) min")
                    }
                }
                .padding(22)
            }
        }
        .navigationTitle("Focus Mode")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(ticker) { _ in tick() }
    }

    private var primaryButtonTitle: String { !isRunning ? "Start focus" : (isPaused ? "Resume" : "Pause") }
    private var primaryButtonSymbol: String { !isRunning ? "play.fill" : (isPaused ? "play.fill" : "pause.fill") }

    private func startSession() {
        isRunning = true
        isPaused = false
        hasSavedCurrentSession = false
        sessionStartedAt = Date()
        elapsedBeforePause = 0
    }

    private func tick() {
        guard isRunning, !isPaused, remainingSeconds > 0 else { return }
        remainingSeconds -= 1
        if remainingSeconds <= 0 {
            remainingSeconds = 0
            saveSession(completed: true)
            isRunning = false
            isPaused = false
        }
    }

    private func resetTimer() {
        isRunning = false
        isPaused = false
        remainingSeconds = plannedSeconds
        hasSavedCurrentSession = false
        sessionStartedAt = nil
        elapsedBeforePause = 0
    }

    private func saveSession(completed: Bool) {
        guard !hasSavedCurrentSession else { return }
        let elapsed = completed ? plannedSeconds : elapsedSeconds
        guard elapsed > 0 else { return }
        FocusHistoryStore.save(FocusSession(plannedDurationSeconds: plannedSeconds, completedDurationSeconds: elapsed, wasCompleted: completed))
        hasSavedCurrentSession = true
    }

    private func timeString(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    private func summaryTile(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption).foregroundStyle(NeuroTapStyle.muted)
            Text(value).font(.title2.bold()).foregroundStyle(NeuroTapStyle.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(16)
        .background(NeuroTapStyle.surface).clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview { NavigationStack { FocusModeView() } }
