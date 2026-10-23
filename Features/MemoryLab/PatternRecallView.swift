
import SwiftUI

// MARK: - Pattern Recall History

private struct PatternRecallSession: Codable, Identifiable {
    var id = UUID()
    let date: Date
    let score: Int
    let roundsCompleted: Int
    let accuracy: Int
}

private enum PatternRecallHistory {
    private static let key = "neurotap.patternrecall.sessions"

    static func load() -> [PatternRecallSession] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let sessions = try? JSONDecoder().decode(
                [PatternRecallSession].self,
                from: data
            )
        else {
            return []
        }

        return sessions.sorted { $0.date > $1.date }
    }

    static func save(_ session: PatternRecallSession) {
        var sessions = load()
        sessions.insert(session, at: 0)
        sessions = Array(sessions.prefix(100))

        guard let data = try? JSONEncoder().encode(sessions) else {
            return
        }

        UserDefaults.standard.set(data, forKey: key)
    }
}

// MARK: - Pattern Recall

struct PatternRecallView: View {
    @Environment(\.dismiss) private var dismiss

    private let gridSize = 3
    private let totalRounds = 5

    @State private var isPlaying = false
    @State private var isFinished = false
    @State private var isShowingPattern = false
    @State private var isAcceptingInput = false

    @State private var pattern: [Int] = []
    @State private var playerPattern: [Int] = []
    @State private var highlightedCell: Int? = nil

    @State private var round = 1
    @State private var score = 0
    @State private var correctRounds = 0
    @State private var attempts = 0

    @State private var statusMessage = "Watch the pattern, then repeat it."
    @State private var statusColor: Color = NeuroTapStyle.muted

    @State private var sequenceTask: Task<Void, Never>?
    @State private var history = PatternRecallHistory.load()
    @State private var sessionSaved = false

    private var patternLength: Int {
        round + 2
    }

    private var accuracy: Int {
        guard attempts > 0 else { return 0 }
        return Int(
            (Double(correctRounds) / Double(attempts) * 100).rounded()
        )
    }

    var body: some View {
        ZStack {
            NeuroTapStyle.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                if isFinished {
                    resultsScreen
                } else if isPlaying {
                    gameScreen
                } else {
                    introScreen
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onDisappear {
            sequenceTask?.cancel()
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            Button {
                sequenceTask?.cancel()
                dismiss()
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(NeuroTapStyle.primaryText)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("PATTERN RECALL")
                .font(.caption.bold())
                .tracking(1.4)
                .foregroundStyle(NeuroTapStyle.muted)
        }
        .padding(.top, 12)
        .padding(.bottom, 24)
    }

    // MARK: Intro

    private var introScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Image(systemName: "square.grid.3x3.fill")
                    .font(.system(size: 42))
                    .foregroundStyle(NeuroTapStyle.violet)

                Text("Watch. Remember. Repeat.")
                    .font(.system(size: 31, weight: .bold))
                    .foregroundStyle(NeuroTapStyle.primaryText)

                Text(
                    "Memorize the order of the glowing tiles, " +
                    "then tap the same tiles in the same sequence."
                )
                .font(.subheadline)
                .foregroundStyle(NeuroTapStyle.muted)

                instructionRow("1", "Watch each tile light up.")
                instructionRow("2", "Wait for the pattern to disappear.")
                instructionRow("3", "Repeat the sequence without mistakes.")

                HStack {
                    infoTile(title: "ROUNDS", value: "\(totalRounds)")
                    infoTile(title: "FIRST PATTERN", value: "3 tiles")
                    infoTile(title: "POINTS", value: "+10")
                }

                Button {
                    startGame()
                } label: {
                    Text("Start Pattern Recall")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(17)
                        .background(
                            NeuroTapStyle.cyan,
                            in: RoundedRectangle(cornerRadius: 15)
                        )
                }
                .buttonStyle(.plain)

                historySection
            }
            .padding(.bottom, 20)
        }
    }

    // MARK: Game

    private var gameScreen: some View {
        VStack(spacing: 22) {
            HStack(spacing: 12) {
                statBox(
                    title: "ROUND",
                    value: "\(round)/\(totalRounds)",
                    color: NeuroTapStyle.cyan
                )

                statBox(
                    title: "SCORE",
                    value: "\(score)",
                    color: NeuroTapStyle.violet
                )

                statBox(
                    title: "PROGRESS",
                    value: "\(playerPattern.count)/\(pattern.count)",
                    color: .green
                )
            }

            VStack(spacing: 8) {
                Text(isShowingPattern ? "MEMORIZE THE PATTERN" : "REPEAT THE PATTERN")
                    .font(.caption.bold())
                    .tracking(1.2)
                    .foregroundStyle(
                        isShowingPattern
                            ? NeuroTapStyle.cyan
                            : NeuroTapStyle.violet
                    )

                Text(statusMessage)
                    .font(.subheadline)
                    .foregroundStyle(statusColor)
                    .multilineTextAlignment(.center)
                    .frame(minHeight: 40)
            }

            Spacer(minLength: 8)

            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: 12),
                    count: gridSize
                ),
                spacing: 12
            ) {
                ForEach(0..<(gridSize * gridSize), id: \.self) { index in
                    Button {
                        handleCellTap(index)
                    } label: {
                        RoundedRectangle(cornerRadius: 17)
                            .fill(
                                highlightedCell == index
                                    ? NeuroTapStyle.cyan
                                    : NeuroTapStyle.surface
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 17)
                                    .strokeBorder(
                                        highlightedCell == index
                                            ? NeuroTapStyle.cyan
                                            : .white.opacity(0.08),
                                        lineWidth: 1
                                    )
                            }
                            .overlay {
                                if highlightedCell == index {
                                    Image(systemName: "sparkle")
                                        .font(.title2.bold())
                                        .foregroundStyle(.black)
                                }
                            }
                            .aspectRatio(1, contentMode: .fit)
                    }
                    .buttonStyle(.plain)
                    .disabled(!isAcceptingInput)
                }
            }
            .padding(4)

            Text(
                isShowingPattern
                    ? "Keep your eyes on the glowing tiles."
                    : "Tap \(pattern.count) tiles in the correct order."
            )
            .font(.caption)
            .foregroundStyle(NeuroTapStyle.muted)
            .multilineTextAlignment(.center)

            Spacer(minLength: 8)
        }
    }

    // MARK: Results

    private var resultsScreen: some View {
        VStack(spacing: 22) {
            Spacer()

            Image(systemName: "brain.head.profile")
                .font(.system(size: 58))
                .foregroundStyle(NeuroTapStyle.cyan)

            Text("Pattern Complete")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(NeuroTapStyle.primaryText)

            Text("\(score) points")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(NeuroTapStyle.cyan)

            HStack(spacing: 12) {
                statBox(
                    title: "ROUNDS",
                    value: "\(correctRounds)/\(totalRounds)",
                    color: .green
                )

                statBox(
                    title: "ACCURACY",
                    value: "\(accuracy)%",
                    color: NeuroTapStyle.violet
                )
            }

            Text(
                correctRounds == totalRounds
                    ? "Perfect recall! You completed every pattern."
                    : "Keep practising to strengthen your visual memory."
            )
            .font(.subheadline)
            .foregroundStyle(NeuroTapStyle.muted)
            .multilineTextAlignment(.center)

            Button {
                isFinished = false
                history = PatternRecallHistory.load()
            } label: {
                Text("Play Again")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(17)
                    .background(
                        NeuroTapStyle.cyan,
                        in: RoundedRectangle(cornerRadius: 15)
                    )
            }
            .buttonStyle(.plain)

            Button("Back to Memory Lab") {
                dismiss()
            }
            .foregroundStyle(NeuroTapStyle.muted)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !history.isEmpty {
                Text("RECENT RESULTS")
                    .font(.caption.bold())
                    .tracking(1.2)
                    .foregroundStyle(NeuroTapStyle.muted)

                ForEach(Array(history.prefix(3))) { session in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(
                                session.date.formatted(
                                    date: .abbreviated,
                                    time: .shortened
                                )
                            )
                            .font(.caption)
                            .foregroundStyle(NeuroTapStyle.muted)

                            Text(
                                "\(session.roundsCompleted)/\(totalRounds) rounds · " +
                                "\(session.accuracy)% accuracy"
                            )
                            .font(.subheadline)
                            .foregroundStyle(NeuroTapStyle.primaryText)
                        }

                        Spacer()

                        Text("\(session.score)")
                            .font(.headline)
                            .foregroundStyle(NeuroTapStyle.cyan)
                    }
                    .padding(12)
                    .background(NeuroTapStyle.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    // MARK: Reusable UI

    private func instructionRow(
        _ number: String,
        _ text: String
    ) -> some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.headline)
                .foregroundStyle(NeuroTapStyle.cyan)
                .frame(width: 34, height: 34)
                .background(
                    NeuroTapStyle.cyan.opacity(0.12),
                    in: Circle()
                )

            Text(text)
                .font(.subheadline)
                .foregroundStyle(NeuroTapStyle.primaryText)

            Spacer(minLength: 0)
        }
    }

    private func infoTile(
        title: String,
        value: String
    ) -> some View {
        VStack(spacing: 7) {
            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(NeuroTapStyle.muted)

            Text(value)
                .font(.headline)
                .foregroundStyle(NeuroTapStyle.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(NeuroTapStyle.surface)
        .clipShape(RoundedRectangle(cornerRadius: 13))
    }

    private func statBox(
        title: String,
        value: String,
        color: Color
    ) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption2.bold())
                .tracking(0.7)
                .foregroundStyle(NeuroTapStyle.muted)

            Text(value)
                .font(.headline.monospacedDigit())
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 13)
        .background(NeuroTapStyle.surface)
        .clipShape(RoundedRectangle(cornerRadius: 13))
    }

    // MARK: Game Logic

    private func startGame() {
        sequenceTask?.cancel()

        round = 1
        score = 0
        correctRounds = 0
        attempts = 0
        playerPattern = []
        pattern = []
        highlightedCell = nil
        sessionSaved = false
        isFinished = false
        isPlaying = true

        beginRound()
    }

    private func beginRound() {
        sequenceTask?.cancel()

        guard isPlaying else { return }

        pattern = (0..<patternLength).map { _ in
            Int.random(in: 0..<(gridSize * gridSize))
        }

        playerPattern = []
        highlightedCell = nil
        isShowingPattern = true
        isAcceptingInput = false
        statusMessage = "Watch carefully..."
        statusColor = NeuroTapStyle.cyan

        sequenceTask = Task { @MainActor in
            do {
                try await Task.sleep(nanoseconds: 500_000_000)

                for cell in pattern {
                    guard !Task.isCancelled, isPlaying else { return }

                    highlightedCell = cell
                    try await Task.sleep(nanoseconds: 550_000_000)

                    highlightedCell = nil
                    try await Task.sleep(nanoseconds: 250_000_000)
                }
            } catch {
                return
            }

            guard !Task.isCancelled, isPlaying else { return }

            highlightedCell = nil
            isShowingPattern = false
            isAcceptingInput = true
            statusMessage = "Your turn. Repeat the sequence."
            statusColor = NeuroTapStyle.violet
        }
    }

    private func handleCellTap(_ index: Int) {
        guard isPlaying, isAcceptingInput, !isShowingPattern else {
            return
        }

        guard playerPattern.count < pattern.count else { return }

        let expectedIndex = playerPattern.count

        if pattern[expectedIndex] != index {
            attempts += 1
            isAcceptingInput = false
            highlightedCell = index
            statusMessage = "Incorrect tile. Round missed."
            statusColor = .pink

            sequenceTask?.cancel()

            sequenceTask = Task { @MainActor in
                do {
                    try await Task.sleep(nanoseconds: 700_000_000)
                } catch {
                    return
                }

                guard !Task.isCancelled, isPlaying else { return }

                highlightedCell = nil
                finishGame()
            }

            return
        }

        playerPattern.append(index)
        highlightedCell = index

        if playerPattern.count == pattern.count {
            attempts += 1
            correctRounds += 1
            score += 10
            isAcceptingInput = false
            statusMessage = "Perfect! +10 points"
            statusColor = .green

            sequenceTask?.cancel()

            sequenceTask = Task { @MainActor in
                do {
                    try await Task.sleep(nanoseconds: 800_000_000)
                } catch {
                    return
                }

                guard !Task.isCancelled, isPlaying else { return }

                highlightedCell = nil

                if round >= totalRounds {
                    finishGame()
                } else {
                    round += 1
                    beginRound()
                }
            }
        }
    }

    private func finishGame() {
        guard isPlaying else { return }

        sequenceTask?.cancel()
        isPlaying = false
        isShowingPattern = false
        isAcceptingInput = false
        highlightedCell = nil
        isFinished = true

        guard !sessionSaved else { return }
        sessionSaved = true

        let session = PatternRecallSession(
            date: Date(),
            score: score,
            roundsCompleted: correctRounds,
            accuracy: accuracy
        )

        PatternRecallHistory.save(session)
        history = PatternRecallHistory.load()
    }
}
