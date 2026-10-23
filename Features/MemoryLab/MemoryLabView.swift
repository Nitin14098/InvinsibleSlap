

import SwiftUI

struct MemoryLabView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var showingGame = false
    @State private var showingPairMatching = false
    @State private var showingMathSprint = false
    @State private var showingPatternRecall = false
    @State private var showingNumberLogic = false

    @State private var history = MemoryHistoryStore.load()

    private let activities: [MemoryActivity] = [
        .init(
            title: "Sequence Recall",
            subtitle: "Remember unpredictable number sequences.",
            category: "MEMORY",
            icon: "number",
            color: NeuroTapStyle.cyan,
            isReady: true
        ),
        .init(
            title: "Pair Matching",
            subtitle: "Find matching pairs using visual memory.",
            category: "VISUAL MEMORY",
            icon: "square.grid.2x2",
            color: NeuroTapStyle.violet,
            isReady: true
        ),
        .init(
            title: "Math Sprint",
            subtitle: "Solve arithmetic questions against the clock.",
            category: "MATHEMATICS",
            icon: "function",
            color: .orange,
            isReady: true
        ),
        .init(
            title: "Pattern Recall",
            subtitle: "Observe a pattern, then recreate it.",
            category: "VISUAL MEMORY",
            icon: "circle.grid.3x3",
            color: .pink,
            isReady: true
        ),
        .init(
            title: "Number Logic",
            subtitle: "Solve number sequences and missing-number puzzles.",
            category: "REASONING",
            icon: "puzzlepiece.extension",
            color: .green,
            isReady: true
        )
    ]

    var body: some View {
        ZStack {
            NeuroTapStyle.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header

                    Button {
                        dismiss()
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(NeuroTapStyle.cyan)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)

                    HStack(spacing: 14) {
                        Image(systemName: "shuffle")
                            .font(.title2.bold())
                            .foregroundStyle(NeuroTapStyle.violet)

                        VStack(alignment: .leading, spacing: 5) {
                            Text("Unpredictable by design")
                                .font(.headline)
                                .foregroundStyle(NeuroTapStyle.primaryText)

                            Text(
                                "7–10 rounds, 3–12 digits, and less time each round."
                            )
                            .font(.caption)
                            .foregroundStyle(NeuroTapStyle.muted)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(NeuroTapStyle.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                    VStack(alignment: .leading, spacing: 14) {
                        sectionTitle("YOUR ACTIVITIES")

                        ForEach(activities) { activity in
                            Button {
                                openActivity(activity)
                            } label: {
                                activityCard(activity)
                            }
                            .buttonStyle(.plain)
                            .disabled(!activity.isReady)
                        }
                    }

                    if !history.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            sectionTitle("RECENT SEQUENCE RECALL RESULTS")

                            ForEach(Array(history.prefix(3))) { session in
                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(session.activity)
                                            .font(.headline)
                                            .foregroundStyle(NeuroTapStyle.primaryText)

                                        Text(
                                            "\(session.totalRounds) rounds · " +
                                            "\(session.totalDigitsShown) digits shown"
                                        )
                                        .font(.caption)
                                        .foregroundStyle(NeuroTapStyle.muted)
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(
                                            "\(session.correctRounds)/\(session.totalRounds)"
                                        )
                                        .font(.headline)
                                        .foregroundStyle(NeuroTapStyle.primaryText)

                                        Text("\(session.accuracyPercentage)%")
                                            .font(.caption.bold())
                                            .foregroundStyle(NeuroTapStyle.cyan)
                                    }
                                }
                                .padding(14)
                                .background(NeuroTapStyle.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .toolbar(.hidden, for: .navigationBar)

        // Keep sheets on the main screen, not inside ForEach.
        .sheet(
            isPresented: $showingGame,
            onDismiss: {
                history = MemoryHistoryStore.load()
            }
        ) {
            SequenceRecallView()
        }
        .sheet(isPresented: $showingPairMatching) {
            PairMatchingView()
        }
        .sheet(isPresented: $showingMathSprint) {
            MathSprintView()
        }
        .sheet(isPresented: $showingPatternRecall) {
            PatternRecallView()
        }
        .sheet(isPresented: $showingNumberLogic) {
            NumberLogicView()
        }
        .onAppear {
            history = MemoryHistoryStore.load()
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(
                "NEUROTAP / TRAIN",
                systemImage: "brain.head.profile"
            )
            .font(.caption.bold())
            .tracking(1.5)
            .foregroundStyle(NeuroTapStyle.muted)

            Text("Memory Lab")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(NeuroTapStyle.primaryText)

            Text(
                "Test your recall under unpredictable difficulty and increasing time pressure."
            )
            .font(.subheadline)
            .foregroundStyle(NeuroTapStyle.muted)
        }
    }

    // MARK: Activity Routing

    private func openActivity(_ activity: MemoryActivity) {
        switch activity.title {
        case "Sequence Recall":
            showingGame = true

        case "Pair Matching":
            showingPairMatching = true

        case "Math Sprint":
            showingMathSprint = true

        case "Pattern Recall":
            showingPatternRecall = true

        case "Number Logic":
            showingNumberLogic = true

        default:
            break
        }
    }

    // MARK: Reusable UI

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.caption.bold())
            .tracking(1.5)
            .foregroundStyle(NeuroTapStyle.muted)
    }

    private func activityCard(_ activity: MemoryActivity) -> some View {
        HStack(spacing: 14) {
            Image(systemName: activity.icon)
                .font(.title3.bold())
                .foregroundStyle(activity.color)
                .frame(width: 52, height: 52)
                .background(
                    activity.color.opacity(0.15),
                    in: RoundedRectangle(cornerRadius: 14)
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(activity.category)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.1)
                    .foregroundStyle(activity.color)

                Text(activity.title)
                    .font(.headline)
                    .foregroundStyle(NeuroTapStyle.primaryText)

                Text(activity.subtitle)
                    .font(.caption)
                    .foregroundStyle(NeuroTapStyle.muted)

                if !activity.isReady {
                    Text("COMING NEXT")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(NeuroTapStyle.muted)
                }
            }

            Spacer(minLength: 4)

            Image(
                systemName: activity.isReady
                    ? "arrow.right.circle.fill"
                    : "lock.circle"
            )
            .font(.title3)
            .foregroundStyle(
                activity.isReady
                    ? activity.color
                    : NeuroTapStyle.muted
            )
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NeuroTapStyle.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(NeuroTapStyle.outline, lineWidth: 1)
        }
    }
}

// MARK: - Activity Model

private struct MemoryActivity: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let category: String
    let icon: String
    let color: Color
    let isReady: Bool
}

// MARK: - Sequence Recall

private struct SequenceRecallView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var round = 1
    @State private var totalRounds = Int.random(in: 7...10)
    @State private var sequence: [Int] = []
    @State private var answer = ""
    @State private var correctRounds = 0
    @State private var highestLevel = 0
    @State private var totalDigitsShown = 0
    @State private var hardestCorrectSequenceLength = 0
    @State private var lastAnswerCorrect = false
    @State private var phase: GamePhase = .intro
    @State private var revealTask: Task<Void, Never>?
    @State private var revealDeadline = Date()
    @State private var revealDuration: Double = 4.0
    @State private var sessionSaved = false

    private enum GamePhase: Equatable {
        case intro
        case showing
        case answering
        case feedback
        case finished
    }

    // The first round gets 4 seconds; the final round gets 1.4 seconds.
    // The reduction is evenly distributed across the randomly chosen rounds.
    private var memorisationTime: Double {
        guard totalRounds > 1 else { return 4.0 }

        let progress = Double(round - 1) / Double(totalRounds - 1)
        return 4.0 - (progress * 2.6)
    }


    var body: some View {
        ZStack(alignment: .topTrailing) {
            NeuroTapStyle.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    header

                    switch phase {
                    case .intro:
                        introContent
                    case .showing:
                        showingContent
                    case .answering:
                        answerContent
                    case .feedback:
                        feedbackContent
                    case .finished:
                        resultsContent
                    }
                }
                .padding(24)
                .padding(.top, 36)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
            }

            Button {
                revealTask?.cancel()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(NeuroTapStyle.primaryText)
                    .frame(width: 36, height: 36)
                    .background(NeuroTapStyle.surface)
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .strokeBorder(
                                .white.opacity(0.1),
                                lineWidth: 1
                            )
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Exit Sequence Recall")
            .padding(.top, 12)
            .padding(.trailing, 20)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onDisappear {
            revealTask?.cancel()
        }
    }


    private var header: some View {
        VStack(spacing: 8) {
            Label("NEUROTAP / MEMORY LAB", systemImage: "brain.head.profile")
                .font(.caption.bold())
                .tracking(1.3)
                .foregroundStyle(NeuroTapStyle.muted)

            Text("Sequence Recall")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(NeuroTapStyle.primaryText)

            if phase != .intro && phase != .finished {
                Text("ROUND \(round) OF \(totalRounds)")
                    .font(.caption.bold())
                    .tracking(1.5)
                    .foregroundStyle(NeuroTapStyle.cyan)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
    }

    private var introContent: some View {
        VStack(spacing: 20) {
            gameIcon("brain.head.profile")

            Text("Remember the digits")
                .font(.title2.bold())
                .foregroundStyle(NeuroTapStyle.primaryText)

            Text("Every round is unpredictable. You may get 12 digits immediately, and your memorisation time will shrink with each round.")
                .font(.body)
                .foregroundStyle(NeuroTapStyle.muted)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 12) {
                instruction("Random session: 7–10 rounds")
                instruction("Random sequence: 3–12 digits")
                instruction("Memorisation time: 4.0 to 1.4 seconds")
                instruction("One point for every exact answer")
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(NeuroTapStyle.surface)
            .clipShape(RoundedRectangle(cornerRadius: 18))

            primaryButton("Start Challenge", icon: "play.fill") {
                totalRounds = Int.random(in: 7...10)
                round = 1
                correctRounds = 0
                highestLevel = 0
                totalDigitsShown = 0
                hardestCorrectSequenceLength = 0
                startRound()
            }
        }
    }

    private var showingContent: some View {
        VStack(spacing: 24) {
            Text("MEMORISE")
                .font(.caption.bold())
                .tracking(2)
                .foregroundStyle(NeuroTapStyle.cyan)

            Text(sequence.map(String.init).joined(separator: " "))
                .font(.system(size: sequence.count > 8 ? 27 : 35,
                              weight: .bold,
                              design: .rounded))
                .tracking(sequence.count > 8 ? 2 : 4)
                .monospacedDigit()
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .foregroundStyle(NeuroTapStyle.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 38)
                .padding(.horizontal, 8)
                .background(NeuroTapStyle.surface)
                .clipShape(RoundedRectangle(cornerRadius: 20))

            TimelineView(.animation(minimumInterval: 0.05)) { context in
                let remaining = max(
                    0,
                    revealDeadline.timeIntervalSince(context.date)
                )

                VStack(spacing: 10) {
                    Text(String(format: "%.1f seconds", remaining))
                        .font(.title2.bold().monospacedDigit())
                        .foregroundStyle(NeuroTapStyle.cyan)

                    ProgressView(
                        value: remaining,
                        total: max(revealDuration, 0.01)
                    )
                    .tint(NeuroTapStyle.cyan)
                }
            }

            Text("\(sequence.count) digits · Focus now")
                .font(.subheadline)
                .foregroundStyle(NeuroTapStyle.muted)
        }
    }

    private var answerContent: some View {
        VStack(spacing: 22) {
            gameIcon("keyboard")

            Text("Enter the sequence")
                .font(.title2.bold())
                .foregroundStyle(NeuroTapStyle.primaryText)

            Text("The digits are hidden. Enter every digit in its original order.")
                .font(.subheadline)
                .foregroundStyle(NeuroTapStyle.muted)
                .multilineTextAlignment(.center)

            TextField("Enter digits", text: $answer)
                .keyboardType(.numberPad)
                .font(.system(size: 25, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(18)
                .background(NeuroTapStyle.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .onChange(of: answer) { _, newValue in
                    let digits = String(newValue.filter(\.isNumber).prefix(12))
                    if answer != digits {
                        answer = digits
                    }
                }

            primaryButton("Check Answer", icon: "checkmark") {
                checkAnswer()
            }
            .disabled(answer.filter(\.isNumber).isEmpty)
            .opacity(answer.filter(\.isNumber).isEmpty ? 0.5 : 1)
        }
    }

    private var feedbackContent: some View {
        VStack(spacing: 22) {
            gameIcon(lastAnswerCorrect
                     ? "checkmark.circle.fill"
                     : "xmark.circle.fill")

            Text(lastAnswerCorrect ? "Correct!" : "Not quite")
                .font(.title.bold())
                .foregroundStyle(
                    lastAnswerCorrect ? NeuroTapStyle.cyan : .orange
                )

            Text(lastAnswerCorrect
                 ? "You recalled the entire sequence."
                 : "The exact sequence is shown below. Keep going.")
                .font(.subheadline)
                .foregroundStyle(NeuroTapStyle.muted)
                .multilineTextAlignment(.center)

            VStack(spacing: 10) {
                Text("CORRECT SEQUENCE")
                    .font(.caption.bold())
                    .tracking(1.3)
                    .foregroundStyle(NeuroTapStyle.muted)

                Text(sequence.map(String.init).joined(separator: " "))
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(NeuroTapStyle.primaryText)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(22)
            .background(NeuroTapStyle.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            Text("Score: \(correctRounds) / \(round)")
                .font(.headline)
                .foregroundStyle(NeuroTapStyle.cyan)

            primaryButton(
                round < totalRounds ? "Next Round" : "View Results",
                icon: "arrow.right"
            ) {
                if round < totalRounds {
                    round += 1
                    startRound()
                } else {
                    finishSession()
                }
            }
        }
    }

    private var resultsContent: some View {
        VStack(spacing: 22) {
            gameIcon("trophy.fill")

            Text("Challenge Complete")
                .font(.title.bold())
                .foregroundStyle(NeuroTapStyle.primaryText)

            Text("\(correctRounds) / \(totalRounds) correct")
                .font(.title2.bold())
                .foregroundStyle(NeuroTapStyle.cyan)

            HStack(spacing: 12) {
                resultCard(
                    title: "ACCURACY",
                    value: "\(Int((Double(correctRounds) / Double(totalRounds) * 100).rounded()))%"
                )

                resultCard(
                    title: "TOTAL DIGITS",
                    value: "\(totalDigitsShown)"
                )
            }

            HStack(spacing: 12) {
                resultCard(
                    title: "LONGEST SHOWN",
                    value: "\(highestLevel) digits"
                )

                resultCard(
                    title: "HARDEST CORRECT",
                    value: "\(hardestCorrectSequenceLength) digits"
                )
            }

            Text("Your session has been saved on this device.")
                .font(.footnote)
                .foregroundStyle(NeuroTapStyle.muted)
                .multilineTextAlignment(.center)

            primaryButton("Back to Memory Lab", icon: "arrow.left") {
                dismiss()
            }
        }
    }

    private func gameIcon(_ symbol: String) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 34, weight: .semibold))
            .foregroundStyle(NeuroTapStyle.cyan)
            .frame(width: 86, height: 86)
            .background(
                NeuroTapStyle.cyan.opacity(0.12),
                in: RoundedRectangle(cornerRadius: 26)
            )
    }

    private func instruction(_ text: String) -> some View {
        Label(text, systemImage: "checkmark.circle.fill")
            .font(.subheadline)
            .foregroundStyle(NeuroTapStyle.primaryText)
            .labelStyle(.titleAndIcon)
    }

    private func resultCard(title: String, value: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption2.bold())
                .tracking(0.8)
                .foregroundStyle(NeuroTapStyle.muted)
                .multilineTextAlignment(.center)

            Text(value)
                .font(.title3.bold())
                .foregroundStyle(NeuroTapStyle.primaryText)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(NeuroTapStyle.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func primaryButton(
        _ title: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(17)
                .background(
                    NeuroTapStyle.cyan,
                    in: RoundedRectangle(cornerRadius: 16)
                )
        }
        .buttonStyle(.plain)
    }

    @MainActor
    private func startRound() {
        revealTask?.cancel()

        let length = Int.random(in: 3...12)
        sequence = (0..<length).map { _ in Int.random(in: 0...9) }

        highestLevel = max(highestLevel, length)
        totalDigitsShown += length
        answer = ""

        let extraTime = Double(max(0, length - 3)) * 0.2
        revealDuration = min(6.0, memorisationTime + extraTime)
        revealDeadline = Date().addingTimeInterval(revealDuration)
        phase = .showing

        let nanoseconds = UInt64(revealDuration * 1_000_000_000)

        revealTask = Task { @MainActor in
            do {
                try await Task.sleep(nanoseconds: nanoseconds)
            } catch {
                return
            }

            guard !Task.isCancelled else { return }
            guard phase == .showing else { return }

            phase = .answering
        }
    }

    private func checkAnswer() {
        guard phase == .answering else { return }

        let enteredDigits = answer.filter(\.isNumber)
        let correctDigits = sequence.map(String.init).joined()
        lastAnswerCorrect = enteredDigits == correctDigits

        if lastAnswerCorrect {
            correctRounds += 1
            hardestCorrectSequenceLength = max(
                hardestCorrectSequenceLength,
                sequence.count
            )
        }

        phase = .feedback
    }

    private func finishSession() {
        guard !sessionSaved else { return }
        sessionSaved = true

        let session = MemorySession(
            date: Date(),
            activity: "Sequence Recall",
            totalRounds: totalRounds,
            correctRounds: correctRounds,
            highestLevel: highestLevel,
            totalDigitsShown: totalDigitsShown,
            hardestCorrectSequenceLength: hardestCorrectSequenceLength
        )

        MemoryHistoryStore.save(session)
        phase = .finished
    }
}
