
import SwiftUI

// MARK: - Difficulty

private enum MathDifficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"

    var id: String { rawValue }

    var weights: [Int] {
        switch self {
        case .easy:   return [70, 25, 5]
        case .normal: return [20, 60, 20]
        case .hard:   return [5, 25, 70]
        }
    }

    var accent: Color {
        switch self {
        case .easy: return .green
        case .normal: return .orange
        case .hard: return .pink
        }
    }

    var description: String {
        switch self {
        case .easy: return "Mostly simple calculations"
        case .normal: return "A balanced mental workout"
        case .hard: return "Mostly challenging calculations"
        }
    }
}

// MARK: - Question Model

private enum QuestionLevel: Int {
    case easy = 0
    case normal = 1
    case hard = 2

    var name: String {
        switch self {
        case .easy: return "EASY"
        case .normal: return "NORMAL"
        case .hard: return "HARD"
        }
    }

    var color: Color {
        switch self {
        case .easy: return .green
        case .normal: return .orange
        case .hard: return .pink
        }
    }
}

private struct MathQuestion {
    let expression: String
    let answer: Int
    let level: QuestionLevel
}

// MARK: - Question Generator

private enum MathQuestionGenerator {

    static func generate(for mode: MathDifficulty) -> MathQuestion {
        let roll = Int.random(in: 1...100)

        let level: QuestionLevel

        switch mode {
        case .easy:
            if roll <= 70 {
                level = .easy
            } else if roll <= 95 {
                level = .normal
            } else {
                level = .hard
            }

        case .normal:
            if roll <= 20 {
                level = .easy
            } else if roll <= 80 {
                level = .normal
            } else {
                level = .hard
            }

        case .hard:
            if roll <= 5 {
                level = .easy
            } else if roll <= 30 {
                level = .normal
            } else {
                level = .hard
            }
        }

        return makeQuestion(level: level)
    }

    private static func makeQuestion(
        level: QuestionLevel
    ) -> MathQuestion {
        switch level {
        case .easy:
            return makeEasy()

        case .normal:
            return makeNormal()

        case .hard:
            return makeHard()
        }
    }

    private static func makeEasy() -> MathQuestion {
        let a = Int.random(in: 2...30)
        let b = Int.random(in: 2...30)

        if Bool.random() {
            return MathQuestion(
                expression: "\(a) + \(b)",
                answer: a + b,
                level: .easy
            )
        }

        let larger = max(a, b)
        let smaller = min(a, b)

        return MathQuestion(
            expression: "\(larger) − \(smaller)",
            answer: larger - smaller,
            level: .easy
        )
    }

    private static func makeNormal() -> MathQuestion {
        switch Int.random(in: 1...3) {
        case 1:
            let a = Int.random(in: 3...15)
            let b = Int.random(in: 3...12)

            return MathQuestion(
                expression: "\(a) × \(b)",
                answer: a * b,
                level: .normal
            )

        case 2:
            let divisor = Int.random(in: 2...12)
            let quotient = Int.random(in: 2...15)

            return MathQuestion(
                expression: "\(divisor * quotient) ÷ \(divisor)",
                answer: quotient,
                level: .normal
            )

        default:
            let a = Int.random(in: 5...30)
            let b = Int.random(in: 2...12)
            let c = Int.random(in: 2...20)

            return MathQuestion(
                expression: "\(a) + \(b) × \(c)",
                answer: a + b * c,
                level: .normal
            )
        }
    }

    private static func makeHard() -> MathQuestion {
        switch Int.random(in: 1...4) {
        case 1:
            let a = Int.random(in: 12...35)
            let b = Int.random(in: 11...28)
            let c = Int.random(in: 10...25)

            return MathQuestion(
                expression: "\(a) × \(b) − \(c)",
                answer: a * b - c,
                level: .hard
            )

        case 2:
            let divisor = Int.random(in: 3...15)
            let quotient = Int.random(in: 12...40)
            let addend = Int.random(in: 10...50)

            return MathQuestion(
                expression: "\(divisor * quotient) ÷ \(divisor) + \(addend)",
                answer: quotient + addend,
                level: .hard
            )

        case 3:
            let a = Int.random(in: 12...30)
            let b = Int.random(in: 11...25)
            let c = Int.random(in: 2...12)

            return MathQuestion(
                expression: "(\(a) + \(b)) × \(c)",
                answer: (a + b) * c,
                level: .hard
            )

        default:
            let a = Int.random(in: 15...35)
            let b = Int.random(in: 12...28)
            let c = Int.random(in: 2...9)

            return MathQuestion(
                expression: "\(a) × \(b) + \(c) × \(c)",
                answer: a * b + c * c,
                level: .hard
            )
        }
    }
}

// MARK: - Saved Session

private struct MathSprintSession: Codable, Identifiable {
    var id = UUID()
    let date: Date
    let mode: String
    let score: Int
    let correctAnswers: Int
    let questionsAnswered: Int
    let accuracy: Int
    let duration: Int
}

private enum MathSprintHistory {
    private static let key = "neurotap.mathsprint.sessions"

    static func load() -> [MathSprintSession] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let sessions = try? JSONDecoder().decode(
                [MathSprintSession].self,
                from: data
            )
        else {
            return []
        }

        return sessions.sorted { $0.date > $1.date }
    }

    static func save(_ session: MathSprintSession) {
        var sessions = load()
        sessions.insert(session, at: 0)
        sessions = Array(sessions.prefix(100))

        guard let data = try? JSONEncoder().encode(sessions) else {
            return
        }

        UserDefaults.standard.set(data, forKey: key)
    }
}

// MARK: - Math Sprint

struct MathSprintView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var mode: MathDifficulty = .easy
    @State private var isPlaying = false
    @State private var isFinished = false

    @State private var question: MathQuestion?
    @State private var answerInput = ""

    @State private var score = 0
    @State private var correctAnswers = 0
    @State private var questionsAnswered = 0
    @State private var timeRemaining = 60

    @State private var feedback = ""
    @State private var feedbackColor: Color = .white
    @State private var timerTask: Task<Void, Never>?
    @State private var history = MathSprintHistory.load()
    @State private var sessionSaved = false

    private let duration = 60

    private var accuracy: Int {
        guard questionsAnswered > 0 else { return 0 }
        return Int(
            (Double(correctAnswers) /
             Double(questionsAnswered) * 100).rounded()
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
                    selectionScreen
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onDisappear {
            timerTask?.cancel()
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            Button {
                timerTask?.cancel()
                dismiss()
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("MATH SPRINT")
                .font(.caption.bold())
                .tracking(1.5)
                .foregroundStyle(NeuroTapStyle.muted)
        }
        .padding(.top, 12)
        .padding(.bottom, 24)
    }

    // MARK: Mode Selection

    private var selectionScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Think fast.")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)

                Text("Solve as many questions as you can in 60 seconds.")
                    .font(.subheadline)
                    .foregroundStyle(NeuroTapStyle.muted)

                ForEach(MathDifficulty.allCases) { option in
                    Button {
                        mode = option
                    } label: {
                        HStack(spacing: 14) {
                            Circle()
                                .fill(option.accent.opacity(0.15))
                                .frame(width: 48, height: 48)
                                .overlay {
                                    Image(systemName: "function")
                                        .font(.title3.bold())
                                        .foregroundStyle(option.accent)
                                }

                            VStack(alignment: .leading, spacing: 5) {
                                Text(option.rawValue)
                                    .font(.headline)
                                    .foregroundStyle(.white)

                                Text(option.description)
                                    .font(.caption)
                                    .foregroundStyle(NeuroTapStyle.muted)

                                Text(
                                    "Easy \(option.weights[0])% · " +
                                    "Normal \(option.weights[1])% · " +
                                    "Hard \(option.weights[2])%"
                                )
                                .font(.caption2)
                                .foregroundStyle(option.accent)
                            }

                            Spacer()

                            Image(
                                systemName: mode == option
                                    ? "largecircle.fill.circle"
                                    : "circle"
                            )
                            .foregroundStyle(
                                mode == option
                                    ? option.accent
                                    : NeuroTapStyle.muted
                            )
                        }
                        .padding(15)
                        .background(NeuroTapStyle.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 17))
                        .overlay {
                            RoundedRectangle(cornerRadius: 17)
                                .strokeBorder(
                                    mode == option
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
                    Text("Start Sprint")
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

                if !history.isEmpty {
                    Text("PREVIOUS BEST")
                        .font(.caption.bold())
                        .tracking(1.3)
                        .foregroundStyle(NeuroTapStyle.muted)

                    ForEach(
                        Array(history.prefix(3))
                    ) { session in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(session.mode) Mode")
                                    .font(.headline)
                                    .foregroundStyle(.white)

                                Text(
                                    "\(session.correctAnswers) correct · " +
                                    "\(session.accuracy)% accuracy"
                                )
                                .font(.caption)
                                .foregroundStyle(NeuroTapStyle.muted)
                            }

                            Spacer()

                            Text("\(session.score)")
                                .font(.title3.bold())
                                .foregroundStyle(NeuroTapStyle.cyan)
                        }
                        .padding(12)
                        .background(NeuroTapStyle.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.bottom, 20)
        }
    }

    // MARK: Active Game

    private var gameScreen: some View {
        VStack(spacing: 24) {
            HStack(spacing: 12) {
                statBox(
                    title: "TIME",
                    value: "\(timeRemaining)s",
                    color: timeRemaining <= 10 ? .pink : NeuroTapStyle.cyan
                )

                statBox(
                    title: "SCORE",
                    value: "\(score)",
                    color: NeuroTapStyle.violet
                )

                statBox(
                    title: "ACCURACY",
                    value: "\(accuracy)%",
                    color: .green
                )
            }

            ProgressView(
                value: Double(timeRemaining),
                total: Double(duration)
            )
            .tint(timeRemaining <= 10 ? .pink : NeuroTapStyle.cyan)

            Spacer(minLength: 10)

            if let question {
                VStack(spacing: 12) {
                    Text(question.level.name)
                        .font(.caption.bold())
                        .tracking(2)
                        .foregroundStyle(question.level.color)

                    Text(question.expression)
                        .font(.system(size: 37, weight: .bold))
                        .monospacedDigit()
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                        .foregroundStyle(.white)

                    Text("What's the answer?")
                        .font(.subheadline)
                        .foregroundStyle(NeuroTapStyle.muted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(NeuroTapStyle.surface)
                .clipShape(RoundedRectangle(cornerRadius: 22))
            }

            TextField("Enter answer", text: $answerInput)
                .font(.system(size: 25, weight: .semibold))
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(17)
                .background(NeuroTapStyle.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .onSubmit {
                    submitAnswer()
                }

            Button {
                submitAnswer()
            } label: {
                Text("Submit Answer")
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
            .disabled(answerInput.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty)

            Text(feedback.isEmpty ? "Every correct answer earns 10 points." : feedback)
                .font(.subheadline)
                .foregroundStyle(
                    feedback.isEmpty
                        ? NeuroTapStyle.muted
                        : feedbackColor
                )
                .multilineTextAlignment(.center)
                .frame(minHeight: 22)

            Spacer(minLength: 10)
        }
    }

    // MARK: Results

    private var resultsScreen: some View {
        VStack(spacing: 22) {
            Spacer()

            Image(systemName: "trophy.fill")
                .font(.system(size: 58))
                .foregroundStyle(NeuroTapStyle.cyan)

            Text("Sprint Complete")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.white)

            Text("\(score) points")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(NeuroTapStyle.cyan)

            HStack(spacing: 12) {
                statBox(
                    title: "CORRECT",
                    value: "\(correctAnswers)",
                    color: .green
                )

                statBox(
                    title: "ANSWERED",
                    value: "\(questionsAnswered)",
                    color: .white
                )

                statBox(
                    title: "ACCURACY",
                    value: "\(accuracy)%",
                    color: NeuroTapStyle.violet
                )
            }

            Text("Your result has been saved on this device.")
                .font(.subheadline)
                .foregroundStyle(NeuroTapStyle.muted)
                .multilineTextAlignment(.center)

            Button {
                isFinished = false
                history = MathSprintHistory.load()
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

    private func statBox(
        title: String,
        value: String,
        color: Color
    ) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption2.bold())
                .tracking(0.8)
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
        timerTask?.cancel()

        score = 0
        correctAnswers = 0
        questionsAnswered = 0
        timeRemaining = duration
        answerInput = ""
        feedback = ""
        sessionSaved = false

        question = MathQuestionGenerator.generate(for: mode)
        isFinished = false
        isPlaying = true

        timerTask = Task { @MainActor in
            while !Task.isCancelled && timeRemaining > 0 {
                do {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                } catch {
                    return
                }

                guard !Task.isCancelled, isPlaying else {
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

    private func submitAnswer() {
        guard isPlaying, let question else { return }

        let cleanedAnswer = answerInput.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard let submittedAnswer = Int(cleanedAnswer) else {
            feedback = "Enter a whole-number answer."
            feedbackColor = .orange
            return
        }

        questionsAnswered += 1

        if submittedAnswer == question.answer {
            correctAnswers += 1
            score += 10
            feedback = "Correct! +10 points"
            feedbackColor = .green
        } else {
            feedback = "Not quite. The answer was \(question.answer)."
            feedbackColor = .orange
        }

        answerInput = ""
        self.question = MathQuestionGenerator.generate(for: mode)
    }

    private func finishGame() {
        guard isPlaying else { return }

        timerTask?.cancel()
        isPlaying = false
        isFinished = true

        guard !sessionSaved else { return }
        sessionSaved = true

        let session = MathSprintSession(
            date: Date(),
            mode: mode.rawValue,
            score: score,
            correctAnswers: correctAnswers,
            questionsAnswered: questionsAnswered,
            accuracy: accuracy,
            duration: duration
        )

        MathSprintHistory.save(session)
        history = MathSprintHistory.load()
    }
}
