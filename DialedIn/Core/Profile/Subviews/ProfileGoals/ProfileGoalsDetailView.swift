//
//  ProfileGoalsDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct ProfileGoalsDetailView: View {

    @State var presenter: ProfileGoalsDetailPresenter

    var body: some View {
        List {
            if let goal = presenter.currentGoal,
               let user = presenter.currentUser {
                goalOverviewSection(goal: goal)
                weightDetailsSection(goal: goal, currentWeight: user.weightKilograms, unit: user.weightUnitPreference ?? .kilograms)
                timelineSection(goal: goal, currentWeight: user.weightKilograms, unit: user.weightUnitPreference ?? .kilograms)
                progressSection(goal: goal, currentWeight: user.weightKilograms, unit: user.weightUnitPreference ?? .kilograms)
                motivationSection(goal: goal)
            } else {
                Section {
                    Text("No goal data available")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Goal Details")
        .navigationBarTitleDisplayMode(.large)
        .scrollIndicators(.hidden)
        .toolbar {
            toolbarContent
        }
        .task {
            await presenter.getActiveGoal()
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                presenter.showLogWeightSheet = true
            } label: {
                Label("Log Weight", systemImage: "plus")
            }
            .buttonStyle(.glassProminent)
        }
    }
    
    private func goalOverviewSection(goal: WeightGoal) -> some View {
        Section {
            HStack {
                Text(goal.objective.description.capitalized)
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Image(systemName: presenter.objectiveIcon(goal.objective.description))
                    .font(.system(size: 20))
                    .foregroundStyle(.accent)
            }
            
            Text(presenter.objectiveDescription(goal.objective.description))
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        } header: {
            Text("Your Goal")
        }
    }
    
    private func weightDetailsSection(goal: WeightGoal, currentWeight: Double?, unit: WeightUnitPreference) -> some View {
        Section("Weight Details") {
            weightCard(
                label: "Starting Weight",
                weight: goal.startingWeightKg,
                unit: unit,
                color: .orange
            )
            
            if let currentWeight = currentWeight {
                weightCard(
                    label: "Current Weight",
                    weight: currentWeight,
                    unit: unit,
                    color: .blue
                )
            }
            
            weightCard(
                label: "Target Weight",
                weight: goal.targetWeightKg,
                unit: unit,
                color: .green
            )
            
            if let currentWeight = currentWeight {
                let difference = abs(goal.targetWeightKg - currentWeight)
                weightCard(
                    label: "Weight Remaining",
                    weight: difference,
                    unit: unit,
                    color: .purple
                )
            }
            
            if goal.weeklyChangeKg > 0 {
                weightCard(
                    label: "Weekly Rate",
                    weight: goal.weeklyChangeKg,
                    unit: unit,
                    color: .pink,
                    suffix: "/week"
                )
            }
        }
    }
    
    private func timelineSection(goal: WeightGoal, currentWeight: Double?, unit: WeightUnitPreference) -> some View {
        Section("Estimated Timeline") {
            if let currentWeight = currentWeight, goal.weeklyChangeKg > 0 {
                let weeks = Int(ceil(abs(goal.targetWeightKg - currentWeight) / goal.weeklyChangeKg))
                let months = Int(ceil(Double(weeks) / 4.33))

                VStack(spacing: 8) {
                    Text("\(weeks)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.accent)
                    Text("weeks")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowSeparator(.hidden)

                Text("Approximately \(months) month\(months != 1 ? "s" : "")")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)

                Text("Based on your selected rate of \(presenter.formatWeight(goal.weeklyChangeKg, unit: unit)) per week")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("Not enough data to estimate timeline")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func progressSection(goal: WeightGoal, currentWeight: Double?, unit: WeightUnitPreference) -> some View {
        Section("Progress") {
            if let currentWeight = currentWeight {
                let progress = goal.calculateProgress(currentWeight: currentWeight)
                let weightChanged = goal.weightChanged(currentWeight: currentWeight)
                let weightRemaining = goal.weightRemaining(currentWeight: currentWeight)
                let isLosing = goal.isLosing

                progressPercentageCard(progress: progress, objective: goal.objective.description)
                let progressState = ProgressState(
                    startingWeight: goal.startingWeightKg,
                    currentWeight: currentWeight,
                    weightChanged: weightChanged,
                    weightRemaining: weightRemaining,
                    isLosing: isLosing,
                    unit: unit
                )

                progressStatistics(
                    progressState: progressState
                )

                if goal.weeklyChangeKg > 0, goal.startingWeightKg != currentWeight {
                    onTrackStatusView(
                        current: currentWeight,
                        start: goal.startingWeightKg,
                        target: goal.targetWeightKg,
                        weeklyRate: goal.weeklyChangeKg
                    )
                }

                if goal.startingWeightKg != currentWeight {
                    weightTrendSection(
                        start: goal.startingWeightKg,
                        current: currentWeight,
                        target: goal.targetWeightKg,
                        unit: unit
                    )
                }

                if progress > 0 {
                    motivationalMessageView(progress: progress, objective: goal.objective.description)
                }
            } else {
                Text("Not enough data to show progress")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func motivationSection(goal: WeightGoal) -> some View {
        Section("Motivation") {
            HStack {
                Image(systemName: "heart.fill")
                    .font(.title2)
                    .foregroundStyle(.pink)
                Text("You've Got This!")
                    .font(.headline)
                Spacer()
            }
            
            Text(presenter.motivationalMessage(goal.objective.description))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private func weightCard(label: String, weight: Double, unit: WeightUnitPreference, color: Color, suffix: String = "") -> some View {
        HStack(spacing: 16) {
            Image(systemName: "scalemass")
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(presenter.formatWeight(weight, unit: unit) + suffix)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Progress View Components
    
    private func progressPercentageCard(progress: Double, objective: String) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundStyle(.accent)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(.accent)
                    Text("Complete")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            ProgressView(value: progress, total: 1.0)
                .tint(progressColor(objective: objective))
                .frame(height: 8)
        }
        .padding(.vertical, 8)
    }
    
    struct ProgressState {
        let startingWeight: Double
        let currentWeight: Double
        let weightChanged: Double
        let weightRemaining: Double
        let isLosing: Bool
        let unit: WeightUnitPreference
    }
    
    private func progressStatistics(
        progressState: ProgressState
    ) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Starting Weight")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(presenter.formatWeight(progressState.startingWeight, unit: progressState.unit))
                        .font(.headline)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Current Weight")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(presenter.formatWeight(progressState.currentWeight, unit: progressState.unit))
                        .font(.headline)
                }
            }
            
            Divider()
            
            HStack(spacing: 32) {
                VStack(spacing: 4) {
                    Text(formatWeightChange(abs(progressState.weightChanged), unit: progressState.unit))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(progressState.weightChanged != 0 ? (progressState.isLosing && progressState.weightChanged > 0 ? .green : !progressState.isLosing && progressState.weightChanged < 0 ? .green : .orange) : .secondary)
                    Text("Changed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text(formatWeightChange(progressState.weightRemaining, unit: progressState.unit))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                    Text("Remaining")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func onTrackStatusView(current: Double, start: Double, target: Double, weeklyRate: Double) -> some View {
        let status = calculateTrackingStatus(
            current: current,
            start: start,
            target: target,
            weeklyRate: weeklyRate,
            weeksElapsed: 4
        )
        
        return HStack(spacing: 12) {
            Image(systemName: status.iconName)
                .font(.title3)
                .foregroundStyle(status.color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(status.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(status.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
    
    private func weightTrendSection(start: Double, current: Double, target: Double, unit: WeightUnitPreference) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Weight Trend")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !presenter.realWeightHistory.isEmpty {
                    Text("Real Data")
                        .font(.caption2)
                        .foregroundStyle(.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Capsule())
                } else {
                    Text("Demo Data")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            
            let history: [WeightDataPoint] = !presenter.realWeightHistory.isEmpty
            ? presenter.realWeightHistory.map { entry in
                WeightDataPoint(date: entry.date, weightKg: entry.weightKg)
              }
            : generateMockWeightHistory(
                start: start,
                current: current,
                target: target,
                weeks: 8
              )

            weightTrendChart(history: history, unit: unit)
        }
    }
    
    private func motivationalMessageView(progress: Double, objective: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: progress >= 1.0 ? "trophy.fill" : "flame.fill")
                .font(.title3)
                .foregroundStyle(progress >= 1.0 ? .yellow : .orange)
            
            Text(motivationalProgressMessage(progress: progress, objective: objective))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
        }
    }
    
    // MARK: - Progress Helper Functions
    
    private func calculateProgress(current: Double, start: Double, target: Double) -> Double {
        guard target != start else { return 0 }
        let totalChange = abs(target - start)
        let currentChange = abs(start - current)
        let progress = min(max(currentChange / totalChange, 0), 1)
        return progress
    }
    
    private func progressColor(objective: String) -> Color {
        if objective.lowercased().contains("lose") {
            return .green
        } else if objective.lowercased().contains("gain") {
            return .blue
        } else {
            return .orange
        }
    }
    
    private func formatWeightChange(_ weightKg: Double, unit: WeightUnitPreference) -> String {
        switch unit {
        case .kilograms:
            return String(format: "%.1f kg", weightKg)
        case .pounds:
            let pounds = weightKg * 2.20462
            return String(format: "%.1f lbs", pounds)
        }
    }
    
    private func calculateTrackingStatus(current: Double, start: Double, target: Double, weeklyRate: Double, weeksElapsed: Int) -> TrackingStatus {
        let expectedChange = weeklyRate * Double(weeksElapsed)
        let actualChange = abs(start - current)
        
        let tolerance = weeklyRate * 0.5 // 50% tolerance
        
        if actualChange >= expectedChange - tolerance && actualChange <= expectedChange + tolerance {
            return .onTrack
        } else if actualChange < expectedChange - tolerance {
            return .slightlyBehind
        } else {
            return .aheadOfSchedule
        }
    }
    
    private func generateMockWeightHistory(start: Double, current: Double, target: Double, weeks: Int) -> [WeightDataPoint] {
        var history: [WeightDataPoint] = []
        let totalChange = current - start
        let changePerWeek = totalChange / Double(weeks - 1)
        
        for week in 0..<weeks {
            let date = Calendar.current.date(byAdding: .weekOfYear, value: -weeks + week, to: Date()) ?? Date()
            
            // Add some natural variance (±0.3 kg)
            let variance = Double.random(in: -0.3...0.3)
            let weight = start + (changePerWeek * Double(week)) + variance
            
            // Clamp to reasonable range
            let clampedWeight = min(max(weight, min(start, target) - 5), max(start, target) + 5)
            
            history.append(WeightDataPoint(date: date, weightKg: clampedWeight))
        }
        
        // Ensure last data point is current weight
        if let lastIndex = history.indices.last {
            history[lastIndex] = WeightDataPoint(date: Date(), weightKg: current)
        }
        
        return history
    }
    
    private func weightTrendChart(history: [WeightDataPoint], unit: WeightUnitPreference) -> some View {
        VStack(spacing: 4) {
            if history.isEmpty {
                Text("No data available")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                let minWeight = history.map(\.weightKg).min() ?? 0
                let maxWeight = history.map(\.weightKg).max() ?? 100
                let range = maxWeight - minWeight
                
                // Simple bar chart visualization
                GeometryReader { proxy in
                    let availableWidth = max(proxy.size.width - 80, 0)
                    HStack(alignment: .bottom, spacing: 4) {
                        ForEach(history) { dataPoint in
                            VStack(spacing: 2) {
                                let normalizedHeight = range > 0 ? (dataPoint.weightKg - minWeight) / range : 0.5
                                let barHeight = max(40 * normalizedHeight, 4)
                                let barWidth = max((availableWidth / CGFloat(history.count)) - 4, 8)

                                Rectangle()
                                    .fill(dataPoint.date.timeIntervalSinceNow > -86400 ? Color.accentColor : Color.accentColor.opacity(0.5))
                                    .frame(width: barWidth, height: barHeight)
                                    .clipShape(RoundedRectangle(cornerRadius: 2))
                            }
                        }
                    }
                }
                .frame(height: 60)
                
                // Labels
                HStack {
                    Text(presenter.formatWeight(minWeight, unit: unit))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    
                    Spacer()
                    
                    Text(presenter.formatWeight(maxWeight, unit: unit))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                
                Text("\(history.count) weeks")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func motivationalProgressMessage(progress: Double, objective: String) -> String {
        if progress >= 1.0 {
            return "Congratulations! You've reached your goal! Keep up the great work to maintain your progress."
        } else if progress >= 0.75 {
            return "You're so close! The finish line is in sight. Stay focused and keep going!"
        } else if progress >= 0.5 {
            return "You're halfway there! Your dedication is paying off. Keep up the excellent work!"
        } else if progress >= 0.25 {
            return "Great progress! You're building momentum. Stay consistent with your plan!"
        } else if progress > 0 {
            return "Every journey begins with a single step. You've started strong—keep going!"
        } else {
            return "You're at the beginning of your journey. Stay committed and results will follow!"
        }
    }
}

// MARK: - Data Models

struct WeightDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let weightKg: Double
}

enum TrackingStatus {
    case onTrack
    case slightlyBehind
    case aheadOfSchedule
    
    var color: Color {
        switch self {
        case .onTrack: return .green
        case .slightlyBehind: return .orange
        case .aheadOfSchedule: return .blue
        }
    }
    
    var title: String {
        switch self {
        case .onTrack: return "On Track"
        case .slightlyBehind: return "Slightly Behind"
        case .aheadOfSchedule: return "Ahead of Schedule"
        }
    }
    
    var message: String {
        switch self {
        case .onTrack: return "You're progressing at your target rate"
        case .slightlyBehind: return "Consider reviewing your plan"
        case .aheadOfSchedule: return "You're making great progress!"
        }
    }
    
    var iconName: String {
        switch self {
        case .onTrack: return "checkmark.circle.fill"
        case .slightlyBehind: return "exclamationmark.circle.fill"
        case .aheadOfSchedule: return "star.circle.fill"
        }
    }
}

extension CoreBuilder {
    func profileGoalsDetailView(router: AnyRouter) -> some View {
        ProfileGoalsDetailView(
            presenter: ProfileGoalsDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }
}

extension CoreRouter {
    func showProfileGoalsView() {
        router.showScreen(.push) { router in
            builder.profileGoalsDetailView(router: router)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.profileGoalsDetailView(router: router)
    }
    .previewEnvironment()
}
