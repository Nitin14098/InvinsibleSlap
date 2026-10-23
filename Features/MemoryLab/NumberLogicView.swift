
import SwiftUI

// MARK: - Number Logic Models

private enum NumberLogicDifficulty: String {
    case easy = "EASY"
    case normal = "NORMAL"
    case hard = "HARD"

    var color: Color {
        switch self {
        case .easy: return .green
        case .normal: return .orange
        case .hard: return .pink
        }
    }
}

private struct NumberLogicQuestion {
    let numbers: [Int]
    let answer: Int
    let options: [Int]
    let difficulty: NumberLogicDifficulty
    let explanation: String
}

// MARK: - Number Logic Generator

private enum NumberLogicGenerator {

    static func generate() -> NumberLogicQuestion {
        let roll = Int.random(in: 1...100)

        if roll <= 35 {
            return makeEasy()
        } else if roll <= 75 {
            return makeNormal()
        } else {
            return makeHard()
        }
    }

    private static func makeEasy() -> NumberLogicQuestion {
        switch Int.random(in: 1...3) {
        case 1:
            let start = Int.random(in: 2...20)
            let step = Int.random(in: 2...9)
            let numbers = (0..<4).map { start + $0 * step }
            let answer = start + 4 * step

            return makeQuestion(
                numbers: numbers,
                answer: answer,
                difficulty: .easy,
                explanation: "Add \(step) each time."
            )

        case 2:
            let start = Int.random(in: 2...10)
            let step = Int.random(in: 2...6)
            let numbers = (0..<4).map { start + $0 * step * 2 }
            let answer = start + 4 * step * 2

            return makeQuestion(
                numbers: numbers,
                answer: answer,
                difficulty: .easy,
                explanation: "Add \(step * 2) each time."
            )

        default:
            let start = Int.random(in: 1...8)
            let numbers = (0..<4).map { start * ($0 + 1) }
            let answer = start * 5

            return makeQuestion(
                numbers: numbers,
                answer: answer,
                difficulty: .easy,
                explanation: "Multiples of \(start)."
            )
        }
    }

    private static func makeNormal() -> NumberLogicQuestion {
        switch Int.random(in: 1...3) {
        case 1:
            let start = Int.random(in: 1...8)
            let step = Int.random(in: 2...5)

            let numbers = (0..<4).map {
                start + $0 * ($0 + 1) / 2 * step
            }

            let answer = start + 10 * step

            return makeQuestion(
                numbers: numbers,
                answer: answer,
                difficulty: .normal,
                explanation: "The increments increase by \(step) each time."
            )

        case 2:
            let start = Int.random(in: 2...5)
            let multiplier = Int.random(in: 2...3)
            var numbers = [start]

            for _ in 1..<4 {
                numbers.append(numbers.last! * multiplier)
            }

            let answer = numbers.last! * multiplier

            return makeQuestion(
                numbers: numbers,
                answer: answer,
                difficulty: .normal,
                explanation: "Multiply by \(multiplier) each time."
            )

        default:
            let start = Int.random(in: 2...10)
            let step = Int.random(in: 2...7)

            let numbers = (0..<4).map {
                start + $0 * $0 * step
            }

            let answer = start + 16 * step

            return makeQuestion(
                numbers: numbers,
                answer: answer,
                difficulty: .normal,
                explanation: "Add successive square multiples of \(step)."
            )
        }
    }

    private static func makeHard() -> NumberLogicQuestion {
        switch Int.random(in: 1...3) {
        case 1:
            let start = Int.random(in: 2...8)
            let step = Int.random(in: 3...8)

            let numbers = (0..<4).map {
                start + $0 * $0 * $0 * step
            }

            let answer = start + 64 * step

            return makeQuestion(
                numbers: numbers,
                answer: answer,
                difficulty: .hard,
                explanation: "Add successive cube multiples of \(step)."
            )

        case 2:
            let start = Int.random(in: 1...5)
            let step = Int.random(in: 2...5)

            let numbers = (0..<4).map {
                start + $0 * ($0 + 1) * step
            }

            let answer = start + 20 * step

            return makeQuestion(
                numbers: numbers,
                answer: answer,
                difficulty: .hard,
                explanation: "The increments increase by \(2 * step) each step."
            )

        default:
            let start = Int.random(in: 2...6)
            let multiplier = 2
            let addition = Int.random(in: 1...5)

            var numbers = [start]

            for _ in 1..<4 {
                numbers.append(numbers.last! * multiplier + addition)
            }

            let answer = numbers.last! * multiplier + addition

            return makeQuestion(
                numbers: numbers,
                answer: answer,
                difficulty: .hard,
                explanation: "Multiply by 2, then add \(addition)."
            )
        }
    }

    private static func makeQuestion(
        numbers: [Int],
        answer: Int,
        difficulty: NumberLogicDifficulty,
        explanation: String
    ) -> NumberLogicQuestion {
        var options: Set<Int> = [answer]

        while options.count < 4 {
            let offset = Int.random(in: -max(5, answer / 4)...max(5, answer / 4))
            let candidate = answer + offset

            if candidate >= 0 {
                options.insert(candidate)
            }
        }

        return NumberLogicQuestion(
            numbers: numbers,
            answer: answer,
            options: options.shuffled(),
            difficulty: difficulty,
            explanation: explanation
        )
    }
}

// MARK: - Number Logic History

private struct NumberLogicSession: Codable, Identifiable {
    var id = UUID()
    let date: Date
    let score: Int
    let correctAnswers: Int
    let questionsAnswered: Int
    let accuracy: Int
}

private enum NumberLogicHistory {
    private static let key = "neurotap.numberlogic.sessions"

    static func load() -> [NumberLogicSession] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let sessions = try? JSONDecoder().decode(
                [NumberLogicSession].self,
                from: data
            )
        else {
            return []
        }

        return sessions.sorted { $0.date > $1.date }
    }

    static func save(_ session: NumberLogicSession) {
        var sessions = load()
        sessions.insert(session, at: 0)
        sessions = Array(sessions.prefix(100))

        guard let data = try? JSONEncoder().encode(sessions) else {
            return
        }

        UserDefaults.standard.set(data, forKey: key)
    }
}

// MARK: - Number Logic View

struct NumberLogicView: View {
    @Environment(\.dismiss) private var dismiss

    private let totalQuestions = 10

    @State private var question: NumberLogicQuestion?
    @State private var questionNumber = 1
    @State private var score = 0
    @State private var correctAnswers = 0
    @State private var questionsAnswered = 0

    @State private var isPlaying = false
    @State private var isFinished = false
    @State private var selectedAnswer: Int?
    @State private var isShowingFeedback = false

    @State private var feedback = "Find the rule behind the sequence."
    @State private var feedbackColor: Color = NeuroTapStyle.muted

    @State private var advanceTask: Task<Void, Never>?
    @State private var history = NumberLogicHistory.load()
    @State private var sessionSaved = false

    private var accuracy: Int {
        guard questionsAnswered > 0 else { return 0 }

        return Int(
            (
                Double(correctAnswers) /
                Double(questionsAnswered) * 100
            ).rounded()
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
            advanceTask?.cancel()
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            Button {
                advanceTask?.cancel()
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

            Text("NUMBER LOGIC")
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
                Image(systemName: "function")
                    .font(.system(size: 42))
                    .foregroundStyle(NeuroTapStyle.violet)

                Text("Crack the sequence.")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(NeuroTapStyle.primaryText)

                Text(
                    "Each sequence follows a mathematical rule. " +
                    "Discover the rule and choose the next number."
                )
                .font(.subheadline)
                .foregroundStyle(NeuroTapStyle.muted)

                instructionRow("1", "Look for differences or multiplication.")
                instructionRow("2", "Work out the number that comes next.")
                instructionRow("3", "Choose one of four possible answers.")

                HStack(spacing: 12) {
                    infoTile(title: "QUESTIONS", value: "\(totalQuestions)")
                    infoTile(title: "CORRECT", value: "+10 points")
                    infoTile(title: "OPTIONS", value: "4 choices")
                }

                Button {
                    startGame()
                } label: {
                    Text("Start Number Logic")
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
                    title: "QUESTION",
                    value: "\(questionNumber)/\(totalQuestions)",
                    color: NeuroTapStyle.cyan
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
                value: Double(questionNumber),
                total: Double(totalQuestions)
            )
            .tint(NeuroTapStyle.cyan)

            Spacer(minLength: 4)

            if let question {
                VStack(spacing: 20) {
                    Text(question.difficulty.rawValue)
                        .font(.caption.bold())
                        .tracking(2)
                        .foregroundStyle(question.difficulty.color)

                    Text("What comes next?")
                        .font(.headline)
                        .foregroundStyle(NeuroTapStyle.muted)

                    HStack(spacing: 8) {
                        ForEach(
                            Array(question.numbers.enumerated()),
                            id: \.offset
                        ) { _, number in
                            Text("\(number)")
                                .font(.system(size: 20, weight: .bold))
                                .monospacedDigit()
                                .foregroundStyle(NeuroTapStyle.primaryText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 17)
                                .background(
                                    NeuroTapStyle.surface,
                                    in: RoundedRectangle(cornerRadius: 12)
                                )
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        }

                        Text("?")
                            .font(.system(size: 25, weight: .bold))
                            .foregroundStyle(NeuroTapStyle.cyan)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(
                                NeuroTapStyle.cyan.opacity(0.12),
                                in: RoundedRectangle(cornerRadius: 12)
                            )
                    }

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 12
                    ) {
                        ForEach(question.options, id: \.self) { option in
                            optionButton(
                                option,
                                question: question
                            )
                        }
                    }
                }
                .padding(18)
                .frame(maxWidth: .infinity)
                .background(NeuroTapStyle.surface.opacity(0.65))
                .clipShape(RoundedRectangle(cornerRadius: 22))
            }

            Text(feedback)
                .font(.subheadline)
                .foregroundStyle(feedbackColor)
                .multilineTextAlignment(.center)
                .frame(minHeight: 45)

            Spacer(minLength: 4)
        }
    }

    // MARK: Answer Option

    private func optionButton(
        _ option: Int,
        question: NumberLogicQuestion
    ) -> some View {
        let isSelected = selectedAnswer == option
        let isCorrect = option == question.answer

        let backgroundColor: Color = {
            guard isShowingFeedback else {
                return NeuroTapStyle.surface
            }

            if isCorrect {
                return Color.green.opacity(0.2)
            }

            if isSelected {
                return Color.pink.opacity(0.2)
            }

            return NeuroTapStyle.surface
        }()

        let foregroundColor: Color = {
            guard isShowingFeedback else { return .white }

            if isCorrect { return .green }
            if isSelected { return .pink }

            return .white
        }()

        return Button {
            chooseAnswer(option)
        } label: {
            HStack {
                Spacer()

                Text("\(option)")
                    .font(.system(size: 22, weight: .bold))
                    .monospacedDigit()

                Spacer()

                if isShowingFeedback && isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                } else if isShowingFeedback && isSelected {
                    Image(systemName: "xmark.circle.fill")
                }
            }
            .foregroundStyle(foregroundColor)
            .padding(16)
            .background(
                backgroundColor,
                in: RoundedRectangle(cornerRadius: 14)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        isShowingFeedback && (isCorrect || isSelected)
                            ? foregroundColor.opacity(0.7)
                            : .white.opacity(0.07),
                        lineWidth: 1
                    )
            }
        }
        .buttonStyle(.plain)
        .disabled(isShowingFeedback)
    }

    // MARK: Results

    private var resultsScreen: some View {
        VStack(spacing: 22) {
            Spacer()

            Image(systemName: "brain")
                .font(.system(size: 58))
                .foregroundStyle(NeuroTapStyle.cyan)

            Text("Logic Complete")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(NeuroTapStyle.primaryText)

            Text("\(score) points")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(NeuroTapStyle.cyan)

            HStack(spacing: 12) {
                statBox(
                    title: "CORRECT",
                    value: "\(correctAnswers)/\(totalQuestions)",
                    color: .green
                )

                statBox(
                    title: "ACCURACY",
                    value: "\(accuracy)%",
                    color: NeuroTapStyle.violet
                )
            }

            Text(resultMessage)
                .font(.subheadline)
                .foregroundStyle(NeuroTapStyle.muted)
                .multilineTextAlignment(.center)

            Button {
                isFinished = false
                history = NumberLogicHistory.load()
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

    private var resultMessage: String {
        switch correctAnswers {
        case 9...10:
            return "Excellent reasoning. You spotted almost every pattern."
        case 7...8:
            return "Great work. Your number-pattern skills are getting sharper."
        case 4...6:
            return "Good effort. Look for differences and changing increments."
        default:
            return "Keep practising. Every sequence is a chance to learn."
        }
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
                                "\(session.correctAnswers)/\(session.questionsAnswered) correct · " +
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
        advanceTask?.cancel()

        questionNumber = 1
        score = 0
        correctAnswers = 0
        questionsAnswered = 0
        selectedAnswer = nil
        isShowingFeedback = false
        sessionSaved = false
        isFinished = false
        isPlaying = true

        feedback = "Find the rule behind the sequence."
        feedbackColor = NeuroTapStyle.muted

        loadQuestion()
    }

    private func loadQuestion() {
        guard isPlaying else { return }

        question = NumberLogicGenerator.generate()
        selectedAnswer = nil
        isShowingFeedback = false
        feedback = "Find the next number."
        feedbackColor = NeuroTapStyle.muted
    }

    private func chooseAnswer(_ answer: Int) {
        guard
            isPlaying,
            !isShowingFeedback,
            let question
        else {
            return
        }

        selectedAnswer = answer
        isShowingFeedback = true
        questionsAnswered += 1

        if answer == question.answer {
            correctAnswers += 1
            score += 10
            feedback = "Correct! +10 points. \(question.explanation)"
            feedbackColor = .green
        } else {
            feedback = "Answer: \(question.answer). \(question.explanation)"
            feedbackColor = .orange
        }

        advanceTask?.cancel()

        advanceTask = Task { @MainActor in
            do {
                try await Task.sleep(nanoseconds: 1_500_000_000)
            } catch {
                return
            }

            guard !Task.isCancelled, isPlaying else { return }

            if questionNumber >= totalQuestions {
                finishGame()
            } else {
                questionNumber += 1
                loadQuestion()
            }
        }
    }

    private func finishGame() {
        guard isPlaying else { return }

        advanceTask?.cancel()
        isPlaying = false
        isFinished = true

        guard !sessionSaved else { return }
        sessionSaved = true

        let session = NumberLogicSession(
            date: Date(),
            score: score,
            correctAnswers: correctAnswers,
            questionsAnswered: questionsAnswered,
            accuracy: accuracy
        )

        NumberLogicHistory.save(session)
        history = NumberLogicHistory.load()
    }
}
