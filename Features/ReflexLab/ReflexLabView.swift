
import SwiftUI
import Charts

// MARK: - Reflex Lab Landing Screen

struct ReflexLabView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var history = ReflexHistoryStore.load()
    private var validHistory: [ReflexSession] {
        history.filter { $0.medianReactionMilliseconds != nil }
    }

    private var bestMedian: Int? {
        validHistory.compactMap(\.medianReactionMilliseconds).min()
    }

    private var latestMedian: Int? {
        validHistory.first?.medianReactionMilliseconds
    }

    private var comparisonText: String {
        guard
            validHistory.count >= 2,
            let latest = validHistory[0].medianReactionMilliseconds,
            let previous = validHistory[1].medianReactionMilliseconds
        else {
            return "Complete two valid sessions to compare results."
        }

        let difference = latest - previous

        if difference < 0 {
            return "\(abs(difference)) ms faster than the previous valid session"
        } else if difference > 0 {
            return "\(difference) ms slower than the previous valid session"
        } else {
            return "Same median as the previous valid session"
        }
    }

    private var recentValidSessions: [ReflexSession] {
        Array(validHistory.reversed().suffix(8))
    }
    private let background = Color(
        red: 0.035, green: 0.045, blue: 0.105
    )
    private let surface = Color(
        red: 0.075, green: 0.09, blue: 0.17
    )
    private let cyan = Color(
        red: 0.30, green: 0.85, blue: 0.98
    )
    private let violet = Color(
        red: 0.60, green: 0.43, blue: 1.0
    )

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(cyan)
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 12) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 34))
                            .foregroundStyle(cyan)

                        Text("Reflex Lab")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("How quickly can you react?")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))

                        Text(
                            "Wait for the green signal, then tap as fast as you can. " +
                            "React too early and that round counts as a false start."
                        )
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.65))
                        .lineSpacing(4)
                    }

                    HStack(spacing: 12) {
                        statCard(
                            value: "5",
                            label: "ROUNDS",
                            color: violet
                        )

                        statCard(
                            value: "ms",
                            label: "PRECISION",
                            color: cyan
                        )
                    }
                    
                    insightsSection

                    NavigationLink {
                        ReflexGameView()
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Reflex Rush")
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(19)
                        .background(violet)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Previous Sessions")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)

                        if history.isEmpty {
                            Text("Your completed games will appear here.")
                                .font(.system(size: 13))
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(18)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(surface)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else {
                            ForEach(history) { session in
                                historyCard(session)
                            }
                        }
                    }

                    Text("For practice and entertainment, not medical diagnosis.")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.45))
                }
                .padding(22)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            history = ReflexHistoryStore.load()
        }
    }
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Insights")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 12
            ) {
                statCard(
                    value: "\(history.count)",
                    label: "SESSIONS",
                    color: violet
                )

                statCard(
                    value: bestMedian.map { "\($0) ms" } ?? "—",
                    label: "BEST MEDIAN",
                    color: cyan
                )

                statCard(
                    value: latestMedian.map { "\($0) ms" } ?? "—",
                    label: "LATEST MEDIAN",
                    color: violet
                )

                statCard(
                    value: "\(validHistory.count)",
                    label: "VALID SESSIONS",
                    color: cyan
                )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Recent comparison")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)

                Text(comparisonText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(cyan)

                Text("Compares the two most recent sessions with valid reaction times.")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.55))
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(surface)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 12) {
                Text("Reaction-time trend")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)

                if recentValidSessions.count >= 2 {
                    Chart(recentValidSessions) { session in
                        if let median = session.medianReactionMilliseconds {
                            LineMark(
                                x: .value("Session date", session.date),
                                y: .value("Median (ms)", median)
                            )
                            .foregroundStyle(cyan)
                            .lineStyle(StrokeStyle(lineWidth: 3))

                            PointMark(
                                x: .value("Session date", session.date),
                                y: .value("Median (ms)", median)
                            )
                            .foregroundStyle(violet)
                        }
                    }
                    .frame(height: 190)
                    .chartYScale(domain: .automatic(includesZero: false))
                    .accessibilityLabel(
                        "Reaction-time trend across the eight most recent valid sessions"
                    )
                } else {
                    Text("Complete at least two sessions with valid reactions to see your trend.")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 24)
                }
            }
            .padding(16)
            .background(surface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    private func statCard(
        value: String,
        label: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(color)

            Text(label)
                .font(.system(size: 10, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(17)
        .background(surface)
        .clipShape(RoundedRectangle(cornerRadius: 17))
    }

    private func historyCard(_ session: ReflexSession) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(
                    session.date.formatted(
                        date: .abbreviated,
                        time: .shortened
                    )
                )
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.6))

                Text(
                    session.medianReactionMilliseconds.map {
                        "\($0) ms median reaction"
                    } ?? "No valid reactions"
                )
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
            }

            Spacer()

            Text("\(session.falseStartCount) false starts")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.orange)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Reflex Rush Game

struct ReflexGameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var engine = ReflexGameEngine()

    private let background = Color(
        red: 0.035, green: 0.045, blue: 0.105
    )

    private var signalColor: Color {
        switch engine.phase {
        case .ready:
            return Color.green
        case .waiting:
            return Color.red
        case .roundResult:
            return Color.orange
        case .idle, .finished:
            return Color(red: 0.60, green: 0.43, blue: 1.0)
        }
    }

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Label("Exit", systemImage: "chevron.left")
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("REFLEX RUSH")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.6))
                }

                if engine.phase != .idle && engine.phase != .finished {
                    VStack(spacing: 6) {
                        Text("ROUND \(engine.currentRound) OF \(engine.totalRounds)")
                            .font(.system(size: 13, weight: .bold))
                            .tracking(1.5)
                            .foregroundStyle(.white.opacity(0.65))

                        ProgressView(
                            value: Double(engine.results.count),
                            total: Double(engine.totalRounds)
                        )
                        .tint(.cyan)
                    }
                }

                Spacer(minLength: 8)

                gameContent

                Spacer(minLength: 8)

                HStack(spacing: 12) {
                    miniStat(
                        title: "VALID",
                        value: "\(engine.validReactionTimes.count)"
                    )

                    miniStat(
                        title: "FALSE STARTS",
                        value: "\(engine.falseStartCount)"
                    )
                }
            }
            .padding(24)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private var gameContent: some View {
        switch engine.phase {
        case .idle:
            VStack(spacing: 20) {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.cyan)

                Text("Ready to react?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Complete five rounds. Don't tap until the signal turns green.")
                    .font(.system(size: 15))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.65))

                Button("Begin") {
                    engine.start()
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(Color(red: 0.60, green: 0.43, blue: 1.0))
                .clipShape(Capsule())
            }

        case .waiting, .ready:
            VStack(spacing: 22) {
                Text(engine.phase == .ready ? "TAP NOW!" : "WAIT FOR GREEN")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(signalColor)

                Button {
                    engine.handleTap()
                } label: {
                    ZStack {
                        Circle()
                            .fill(signalColor.opacity(0.14))
                            .frame(width: 240, height: 240)

                        Circle()
                            .fill(signalColor)
                            .frame(width: 180, height: 180)

                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    engine.phase == .ready
                        ? "Tap now"
                        : "Waiting for signal"
                )

                Text(
                    engine.phase == .ready
                        ? "Tap the circle immediately."
                        : "Don't tap yet. Be patient."
                )
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.65))
            }

        case .roundResult:
            VStack(spacing: 18) {
                Image(
                    systemName: engine.lastWasFalseStart
                        ? "exclamationmark.circle.fill"
                        : "checkmark.circle.fill"
                )
                .font(.system(size: 54))
                .foregroundStyle(
                    engine.lastWasFalseStart ? .orange : .green
                )

                Text(
                    engine.lastWasFalseStart
                        ? "Too early!"
                        : "\(engine.lastReactionMilliseconds ?? 0) ms"
                )
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

                Text(
                    engine.lastWasFalseStart
                        ? "That round counts as a false start."
                        : "Reaction recorded. Get ready for the next round."
                )
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.65))
            }

        case .finished:
            resultsContent
        }
    }

    private var resultsContent: some View {
        VStack(spacing: 20) {
            Image(systemName: "flag.checkered")
                .font(.system(size: 46))
                .foregroundStyle(.cyan)

            Text("Session complete")
                .font(.system(size: 27, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            if let median = engine.medianReactionMilliseconds {
                Text("\(median) ms")
                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                    .foregroundStyle(.cyan)

                Text("Median reaction time")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.65))
            } else {
                Text("No valid reaction times recorded.")
                    .foregroundStyle(.white.opacity(0.7))
            }

            VStack(spacing: 10) {
                resultRow(
                    "Valid reactions",
                    value: "\(engine.validReactionTimes.count)"
                )

                resultRow(
                    "False starts",
                    value: "\(engine.falseStartCount)"
                )

                resultRow(
                    "Rounds completed",
                    value: "\(engine.results.count)/\(engine.totalRounds)"
                )
            }

            VStack(spacing: 8) {
                ForEach(engine.results) { result in
                    HStack {
                        Text("Round \(result.roundNumber)")
                            .foregroundStyle(.white.opacity(0.7))

                        Spacer()

                        Text(
                            result.wasFalseStart
                                ? "False start"
                                : "\(result.reactionMilliseconds ?? 0) ms"
                        )
                        .foregroundStyle(
                            result.wasFalseStart ? .orange : .green
                        )
                    }
                    .font(.system(size: 13, weight: .medium))
                }
            }
            .padding(16)
            .background(.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Button {
                engine.restart()
            } label: {
                Label("Play again", systemImage: "arrow.clockwise")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        Color(red: 0.60, green: 0.43, blue: 1.0)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
        }
    }

    private func miniStat(title: String, value: String) -> some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)

            Text(title)
                .font(.system(size: 9, weight: .bold))
                .tracking(1)
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func resultRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.white.opacity(0.65))

            Spacer()

            Text(value)
                .foregroundStyle(.white)
                .fontWeight(.semibold)
        }
        .font(.system(size: 14))
    }
}
