import SwiftUI

struct InsightsView: View {
    @State private var selectedFilter: ActivityType? = nil
    @State private var refreshToken = UUID()

    private var activities: [ActivityRecord] {
        _ = refreshToken
        let all = ActivityHistoryService.loadRecentActivities()
        guard let selectedFilter else { return all }
        return all.filter { $0.type == selectedFilter }
    }

    var body: some View {
        ZStack {
            NeuroTapStyle.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("YOUR PROGRESS").font(.caption.bold()).tracking(2).foregroundStyle(NeuroTapStyle.cyan)
                        Text("Insights").font(.largeTitle.bold()).foregroundStyle(NeuroTapStyle.primaryText)
                        Text("A clear view of the practice recorded on this device.")
                            .font(.subheadline).foregroundStyle(NeuroTapStyle.muted)
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        metric(title: "Total sessions", value: "\(ActivityHistoryService.totalRecordedSessions())", symbol: "chart.bar.fill", color: NeuroTapStyle.violet)
                        metric(title: "Memory Lab", value: "\(ActivityHistoryService.memorySessionCount())", symbol: "brain.head.profile", color: NeuroTapStyle.cyan)
                        metric(title: "Reflex Lab", value: "\(ActivityHistoryService.reflexSessionCount())", symbol: "bolt.fill", color: .green)
                        metric(title: "Focus minutes", value: "\(ActivityHistoryService.totalCompletedFocusSeconds() / 60)", symbol: "timer", color: .orange)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("RECENT ACTIVITY").font(.caption.bold()).tracking(1.5).foregroundStyle(NeuroTapStyle.muted)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                filterChip(title: "All", type: nil)
                                ForEach(ActivityType.allCases) { type in filterChip(title: type.title, type: type) }
                            }
                        }
                        if activities.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "chart.xyaxis.line").font(.system(size: 32)).foregroundStyle(NeuroTapStyle.violet)
                                Text("No activity yet").font(.headline).foregroundStyle(NeuroTapStyle.primaryText)
                                Text("Complete a Memory, Reflex, or Focus session and it will appear here.")
                                    .font(.subheadline).foregroundStyle(NeuroTapStyle.muted).multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity).padding(28).background(NeuroTapStyle.surface).clipShape(RoundedRectangle(cornerRadius: 18))
                        } else {
                            LazyVStack(spacing: 10) {
                                ForEach(activities) { record in
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: symbol(for: record.type))
                                            .font(.headline).foregroundStyle(color(for: record.type)).frame(width: 42, height: 42)
                                            .background(color(for: record.type).opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: 12))
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(record.title).font(.headline).foregroundStyle(NeuroTapStyle.primaryText)
                                            Text(record.detail).font(.subheadline).foregroundStyle(NeuroTapStyle.muted)
                                            Text(record.date.formatted(date: .abbreviated, time: .shortened)).font(.caption).foregroundStyle(NeuroTapStyle.muted.opacity(0.8))
                                        }
                                        Spacer(minLength: 0)
                                    }
                                    .padding(14).frame(maxWidth: .infinity, alignment: .leading)
                                    .background(NeuroTapStyle.surface).clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                            }
                        }
                    }
                }
                .padding(22)
            }
        }
        .navigationTitle("Insights")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Button { refreshToken = UUID() } label: { Image(systemName: "arrow.clockwise") } } }
    }

    private func metric(title: String, value: String, symbol: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: symbol).font(.title3).foregroundStyle(color)
            Text(value).font(.title.bold()).foregroundStyle(NeuroTapStyle.primaryText)
            Text(title).font(.caption).foregroundStyle(NeuroTapStyle.muted)
        }
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .leading).padding(16)
        .background(NeuroTapStyle.surface).clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func filterChip(title: String, type: ActivityType?) -> some View {
        let isSelected = selectedFilter == type
        return Button { selectedFilter = type } label: {
            Text(title).font(.caption.bold()).padding(.horizontal, 13).padding(.vertical, 9)
                .background(isSelected ? NeuroTapStyle.violet.opacity(0.3) : NeuroTapStyle.surface)
                .foregroundStyle(NeuroTapStyle.primaryText).clipShape(Capsule())
                .overlay(Capsule().stroke(isSelected ? NeuroTapStyle.violet : .clear, lineWidth: 1))
        }.buttonStyle(.plain)
    }

    private func symbol(for type: ActivityType) -> String {
        switch type { case .memory: "brain.head.profile"; case .reflex: "bolt.fill"; case .focus: "timer" }
    }
    private func color(for type: ActivityType) -> Color {
        switch type { case .memory: NeuroTapStyle.violet; case .reflex: .green; case .focus: NeuroTapStyle.cyan }
    }
}

#Preview { NavigationStack { InsightsView() } }
