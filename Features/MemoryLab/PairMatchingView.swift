
import SwiftUI

// MARK: - Difficulty

private enum MatchingDifficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var id: String { rawValue }

    var dimension: Int {
        switch self {
        case .easy: return 4
        case .medium: return 6
        case .hard: return 8
        }
    }

    var pairCount: Int {
        dimension * dimension / 2
    }

    var timeLimit: Int {
        switch self {
        case .easy: return 45
        case .medium: return 75
        case .hard: return 100
        }
    }

    var accent: Color {
        switch self {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .pink
        }
    }

    var description: String {
        switch self {
        case .easy: return "16 cards · 8 pairs"
        case .medium: return "36 cards · 18 pairs"
        case .hard: return "64 cards · 32 pairs"
        }
    }
}

// MARK: - Card Model

private struct MatchingCard: Identifiable {
    let id = UUID()
    let pairID: Int
    let symbol: String

    var isFaceUp = false
    var isMatched = false
}

// MARK: - Saved Results

private struct MatchingSession: Codable, Identifiable {
    var id = UUID()
    let date: Date
    let difficulty: String
    let completed: Bool
    let moves: Int
    let elapsedSeconds: Int
    let pairsFound: Int
    let totalPairs: Int
}

private enum MatchingHistoryStore {
    private static let key = "neurotap.matching.sessions"

    static func load() -> [MatchingSession] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let sessions = try? JSONDecoder().decode(
                [MatchingSession].self,
                from: data
            )
        else {
            return []
        }

        return sessions.sorted { $0.date > $1.date }
    }

    static func save(_ session: MatchingSession) {
        var sessions = load()
        sessions.insert(session, at: 0)
        sessions = Array(sessions.prefix(100))

        guard let data = try? JSONEncoder().encode(sessions) else {
            return
        }

        UserDefaults.standard.set(data, forKey: key)
    }
}

// MARK: - Pair Matching Game

struct PairMatchingView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var difficulty: MatchingDifficulty = .easy
    @State private var phase: GamePhase = .selection
    @State private var cards: [MatchingCard] = []
    @State private var firstFlippedIndex: Int?
    @State private var isResolvingMismatch = false
    @State private var moves = 0
    @State private var timeRemaining = 45
    @State private var pairsFound = 0
    @State private var timerTask: Task<Void, Never>?
    @State private var mismatchTask: Task<Void, Never>?
    @State private var history = MatchingHistoryStore.load()
    @State private var sessionSaved = false

    private enum GamePhase {
        case selection
        case playing
        case finished
    }

    private let symbols = [
        "star.fill", "heart.fill", "moon.fill", "sun.max.fill",
        "cloud.fill", "flame.fill", "bolt.fill", "leaf.fill",
        "drop.fill", "snowflake", "pawprint.fill", "bird.fill",
        "fish.fill", "car.fill", "airplane", "bicycle",
        "gamecontroller.fill", "headphones", "camera.fill", "gift.fill",
        "crown.fill", "flag.fill", "bell.fill", "key.fill",
        "lock.fill", "house.fill", "globe", "paperplane.fill",
        "umbrella.fill", "cup.and.saucer.fill", "book.fill", "puzzlepiece.fill"
    ]

    private var elapsedSeconds: Int {
        difficulty.timeLimit - timeRemaining
    }

    var body: some View {
        ZStack {
            NeuroTapStyle.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                switch phase {
                case .selection:
                    selectionScreen
                case .playing:
                    gameScreen
                case .finished:
                    resultsScreen
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            history = MatchingHistoryStore.load()
        }
        .onDisappear {
            timerTask?.cancel()
            mismatchTask?.cancel()
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("NEUROTAP / TRAIN")
                    .font(.caption.bold())
                    .tracking(1.4)
                    .foregroundStyle(NeuroTapStyle.muted)

                Text("Pair Matching")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
            }

            Spacer()

            Button {
                if phase == .playing {
                    stopGame()
                } else {
                    dismiss()
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(NeuroTapStyle.surface, in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 12)
        .padding(.bottom, 20)
    }

    // MARK: Difficulty Selection

    private var selectionScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Choose your challenge")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text("Remember where each symbol appears. Match every pair before time runs out.")
                    .font(.subheadline)
                    .foregroundStyle(NeuroTapStyle.muted)

                ForEach(MatchingDifficulty.allCases) { option in
                    Button {
                        difficulty = option
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "square.grid.3x3.fill")
                                .font(.title2)
                                .foregroundStyle(option.accent)
                                .frame(width: 48, height: 48)
                                .background(
                                    option.accent.opacity(0.14),
                                    in: RoundedRectangle(cornerRadius: 14)
                                )

                            VStack(alignment: .leading, spacing: 5) {
                                Text(option.rawValue)
                                    .font(.headline)
                                    .foregroundStyle(.white)

                                Text(option.description)
                                    .font(.caption)
                                    .foregroundStyle(NeuroTapStyle.muted)

                                Text("\(option.timeLimit) seconds")
                                    .font(.caption.bold())
                                    .foregroundStyle(option.accent)
                            }

                            Spacer()

                            Image(
                                systemName: difficulty == option
                                    ? "largecircle.fill.circle"
                                    : "circle"
                            )
                            .font(.title3)
                            .foregroundStyle(
                                difficulty == option
                                    ? option.accent
                                    : NeuroTapStyle.muted
                            )
                        }
                        .padding(15)
                        .background(NeuroTapStyle.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay {
                            RoundedRectangle(cornerRadius: 18)
                                .strokeBorder(
                                    difficulty == option
                                        ? option.accent.opacity(0.7)
                                        : .white.opacity(0.06),
                                    lineWidth: 1
                                )
                        }
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    startGame()
                } label: {
                    Label("Start Game", systemImage: "play.fill")
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
                .padding(.top, 4)

                if !history.isEmpty {
                    Text("RECENT GAMES")
                        .font(.caption.bold())
                        .tracking(1.3)
                        .foregroundStyle(NeuroTapStyle.muted)
                        .padding(.top, 10)

                    ForEach(Array(history.prefix(3))) { session in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(session.difficulty)
                                    .font(.headline)
                                    .foregroundStyle(.white)

                                Text(
                                    session.completed
                                        ? "\(session.elapsedSeconds)s · \(session.moves) moves"
                                        : "Time expired · \(session.pairsFound)/\(session.totalPairs) pairs"
                                )
                                .font(.caption)
                                .foregroundStyle(NeuroTapStyle.muted)
                            }

                            Spacer()

                            Text(
                                "\(session.pairsFound)/\(session.totalPairs)"
                            )
                            .font(.headline)
                            .foregroundStyle(
                                session.completed
                                    ? NeuroTapStyle.cyan
                                    : .orange
                            )
                        }
                        .padding(13)
                        .background(NeuroTapStyle.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(.bottom, 20)
        }
    }

    // MARK: Game Board

    private var gameScreen: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                statBox(
                    title: "TIME",
                    value: "\(timeRemaining)s",
                    color: timeRemaining <= 10 ? .orange : NeuroTapStyle.cyan
                )

                statBox(
                    title: "MOVES",
                    value: "\(moves)",
                    color: .white
                )

                statBox(
                    title: "PAIRS",
                    value: "\(pairsFound)/\(difficulty.pairCount)",
                    color: NeuroTapStyle.violet
                )
            }

            ProgressView(
                value: Double(timeRemaining),
                total: Double(difficulty.timeLimit)
            )
            .tint(timeRemaining <= 10 ? .orange : NeuroTapStyle.cyan)

            ScrollView {
                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible(), spacing: 5),
                        count: difficulty.dimension
                    ),
                    spacing: 5
                ) {
                    ForEach(cards.indices, id: \.self) { index in
                        cardView(at: index)
                    }
                }
                .padding(.vertical, 4)
            }

            Text("Find every pair before the countdown ends.")
                .font(.caption)
                .foregroundStyle(NeuroTapStyle.muted)
                .padding(.bottom, 4)
        }
    }

    private func cardView(at index: Int) -> some View {
        let card = cards[index]
        let isVisible = card.isFaceUp || card.isMatched
        let isHard = difficulty == .hard

        return Button {
            flipCard(at: index)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: isHard ? 5 : 9)
                    .fill(
                        isVisible
                            ? NeuroTapStyle.surface
                            : NeuroTapStyle.violet.opacity(0.85)
                    )

                RoundedRectangle(cornerRadius: isHard ? 5 : 9)
                    .strokeBorder(
                        card.isMatched
                            ? NeuroTapStyle.cyan
                            : .white.opacity(0.08),
                        lineWidth: card.isMatched ? 1.5 : 1
                    )

                if isVisible {
                    Image(systemName: card.symbol)
                        .font(.system(
                            size: isHard ? 12 : (difficulty == .medium ? 18 : 24),
                            weight: .semibold
                        ))
                        .foregroundStyle(
                            card.isMatched
                                ? NeuroTapStyle.cyan
                                : .white
                        )
                        .minimumScaleFactor(0.5)
                } else {
                    Image(systemName: "sparkle")
                        .font(.system(size: isHard ? 9 : 15))
                        .foregroundStyle(.white.opacity(0.65))
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
        .disabled(
            phase != .playing ||
            card.isMatched ||
            card.isFaceUp ||
            isResolvingMismatch
        )
    }

    // MARK: Results

    private var resultsScreen: some View {
        VStack(spacing: 22) {
            Spacer()

            Image(
                systemName: pairsFound == difficulty.pairCount
                    ? "trophy.fill"
                    : "clock.badge.exclamationmark"
            )
            .font(.system(size: 58))
            .foregroundStyle(
                pairsFound == difficulty.pairCount
                    ? NeuroTapStyle.cyan
                    : .orange
            )

            Text(
                pairsFound == difficulty.pairCount
                    ? "All Pairs Matched!"
                    : "Time's Up!"
            )
            .font(.system(size: 30, weight: .bold))
            .foregroundStyle(.white)

            Text(
                "\(pairsFound) of \(difficulty.pairCount) pairs found"
            )
            .font(.title3)
            .foregroundStyle(NeuroTapStyle.muted)

            HStack(spacing: 12) {
                statBox(
                    title: "MOVES",
                    value: "\(moves)",
                    color: .white
                )

                statBox(
                    title: "TIME USED",
                    value: "\(elapsedSeconds)s",
                    color: NeuroTapStyle.cyan
                )
            }

            Text(
                pairsFound == difficulty.pairCount
                    ? "Great work! Your result has been saved."
                    : "Keep practising. Your result has been saved."
            )
            .font(.subheadline)
            .foregroundStyle(NeuroTapStyle.muted)
            .multilineTextAlignment(.center)

            Button {
                history = MatchingHistoryStore.load()
                phase = .selection
            } label: {
                Label("Play Again", systemImage: "arrow.clockwise")
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

            Button("Back to Memory Lab") {
                dismiss()
            }
            .foregroundStyle(NeuroTapStyle.muted)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func statBox(
        title: String,
        value: String,
        color: Color
    ) -> some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption2.bold())
                .tracking(1)
                .foregroundStyle(NeuroTapStyle.muted)

            Text(value)
                .font(.headline.monospacedDigit())
                .foregroundStyle(color)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(NeuroTapStyle.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: Game Logic

    private func startGame() {
        timerTask?.cancel()
        mismatchTask?.cancel()

        let shuffledSymbols = symbols.shuffled()
        var newCards: [MatchingCard] = []

        for pairID in 0..<difficulty.pairCount {
            let symbol = shuffledSymbols[pairID]
            newCards.append(
                MatchingCard(pairID: pairID, symbol: symbol)
            )
            newCards.append(
                MatchingCard(pairID: pairID, symbol: symbol)
            )
        }

        cards = newCards.shuffled()
        moves = 0
        pairsFound = 0
        timeRemaining = difficulty.timeLimit
        firstFlippedIndex = nil
        isResolvingMismatch = false
        sessionSaved = false
        phase = .playing

        timerTask = Task { @MainActor in
            while !Task.isCancelled && timeRemaining > 0 {
                do {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                } catch {
                    return
                }

                guard !Task.isCancelled, phase == .playing else {
                    return
                }

                timeRemaining -= 1

                if timeRemaining <= 0 {
                    finishGame()
                    return
                }
            }
        }
    }

    private func flipCard(at index: Int) {
        guard phase == .playing else { return }
        guard !isResolvingMismatch else { return }
        guard cards.indices.contains(index) else { return }
        guard !cards[index].isMatched && !cards[index].isFaceUp else {
            return
        }

        cards[index].isFaceUp = true

        if let firstIndex = firstFlippedIndex {
            moves += 1
            firstFlippedIndex = nil

            if cards[firstIndex].pairID == cards[index].pairID {
                cards[firstIndex].isMatched = true
                cards[index].isMatched = true
                pairsFound += 1

                if pairsFound == difficulty.pairCount {
                    finishGame()
                }
            } else {
                isResolvingMismatch = true

                mismatchTask = Task { @MainActor in
                    do {
                        try await Task.sleep(nanoseconds: 750_000_000)
                    } catch {
                        return
                    }

                    guard !Task.isCancelled, phase == .playing else {
                        return
                    }

                    cards[firstIndex].isFaceUp = false
                    cards[index].isFaceUp = false
                    isResolvingMismatch = false
                }
            }
        } else {
            firstFlippedIndex = index
        }
    }

    private func finishGame() {
        guard phase == .playing else { return }

        timerTask?.cancel()
        mismatchTask?.cancel()
        isResolvingMismatch = false
        phase = .finished

        guard !sessionSaved else { return }
        sessionSaved = true

        let session = MatchingSession(
            date: Date(),
            difficulty: difficulty.rawValue,
            completed: pairsFound == difficulty.pairCount,
            moves: moves,
            elapsedSeconds: elapsedSeconds,
            pairsFound: pairsFound,
            totalPairs: difficulty.pairCount
        )

        MatchingHistoryStore.save(session)
        history = MatchingHistoryStore.load()
    }

    private func stopGame() {
        timerTask?.cancel()
        mismatchTask?.cancel()
        dismiss()
    }
}
