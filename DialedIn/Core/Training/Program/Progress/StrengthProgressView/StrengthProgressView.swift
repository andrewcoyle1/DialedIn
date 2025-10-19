//
//  StrengthProgressView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import Charts

struct StrengthProgressView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ExerciseTemplateManager.self) private var exerciseTemplateManager
    @Environment(TrainingAnalyticsManager.self) private var trainingAnalytics
    
    @State private var strengthMetrics: StrengthMetrics?
    @State private var selectedExerciseId: String?
    @State private var exerciseProgression: StrengthProgression?
    @State private var isLoading = false
    @State private var selectedPeriod: TimePeriod = .lastThreeMonths
    
    init() {}
    
    enum TimePeriod: String, CaseIterable {
        case lastMonth = "Month"
        case lastThreeMonths = "3 Months"
        case lastSixMonths = "6 Months"
        case allTime = "All Time"
        
        var dateInterval: DateInterval {
            let now = Date()
            let calendar = Calendar.current
            
            switch self {
            case .lastMonth:
                let start = calendar.date(byAdding: .month, value: -1, to: now) ?? now
                return DateInterval(start: start, end: now)
            case .lastThreeMonths:
                let start = calendar.date(byAdding: .month, value: -3, to: now) ?? now
                return DateInterval(start: start, end: now)
            case .lastSixMonths:
                let start = calendar.date(byAdding: .month, value: -6, to: now) ?? now
                return DateInterval(start: start, end: now)
            case .allTime:
                let start = calendar.date(byAdding: .year, value: -1, to: now) ?? now
                return DateInterval(start: start, end: now)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Period picker
                Section {
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .removeListRowFormatting()
                .listSectionSpacing(0)
                
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 200)
                        .removeListRowFormatting()
                } else if let metrics = strengthMetrics {
                    personalRecordsSection(metrics)
                    
                    if let progression = exerciseProgression {
                        progressionChartSection(progression)
                    }
                } else {
                    emptyState
                }
            }
            .navigationTitle("Strength Progress")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadStrengthData()
            }
            .onChange(of: selectedPeriod) { _, _ in
                Task {
                    await loadStrengthData()
                    if let id = selectedExerciseId {
                        await loadExerciseProgression(id)
                    }
                }
            }
            .onChange(of: selectedExerciseId) { _, newValue in
                if let exerciseId = newValue {
                    Task {
                        await loadExerciseProgression(exerciseId)
                    }
                }
            }
        }
    }
    
    private func personalRecordsSection(_ metrics: StrengthMetrics) -> some View {
        Section {
            if !metrics.personalRecords.isEmpty {
                ForEach(metrics.personalRecords.prefix(10)) { personalRecord in
                    Button {
                        selectedExerciseId = personalRecord.exerciseId
                    } label: {
                        PRCard(record: personalRecord, isSelected: selectedExerciseId == personalRecord.exerciseId)
                            .tappableBackground()
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Text("No personal records yet")
                    .foregroundStyle(.secondary)
                    .padding()
            }
        } header: {
            Text("Personal Records")
        }
    }
    
    private func progressionChartSection(_ progression: StrengthProgression) -> some View {
        Section {
            Group {
                // Stats
                statsSection(progression: progression)
                
                // Chart
                chartSection(progression: progression)
            }
            .listRowSeparator(.hidden)
            .listRowSpacing(0)
        } header: {
            HStack(alignment: .firstTextBaseline) {
                Text(progression.exerciseName)
                Text("Estimated 1RM Progression")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    selectedExerciseId = nil
                    exerciseProgression = nil
                } label: {
                    if selectedExerciseId != nil {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.accent)
                    }
                }
            }
        }
    }
    
    private func statsSection(progression: StrengthProgression) -> some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Starting")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(Int(progression.startingWeight)) kg")
                    .font(.headline)
            }
            
            Image(systemName: "arrow.right")
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Current")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(Int(progression.currentWeight)) kg")
                    .font(.headline)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Gain")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 2) {
                    Image(systemName: progression.percentageGain >= 0 ? "arrow.up" : "arrow.down")
                    Text(String(format: "%.1f%%", abs(progression.percentageGain)))
                }
                .font(.headline)
                .foregroundStyle(progression.percentageGain >= 0 ? .green : .red)
            }
        }
    }
    
    @ViewBuilder
    private func chartSection(progression: StrengthProgression) -> some View {
        if !progression.dataPoints.isEmpty {
            Chart(progression.dataPoints) { dataPoint in
                LineMark(
                    x: .value("Date", dataPoint.date),
                    y: .value("1RM", dataPoint.estimatedOneRepMax)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.green)
                
                PointMark(
                    x: .value("Date", dataPoint.date),
                    y: .value("1RM", dataPoint.estimatedOneRepMax)
                )
                .foregroundStyle(.green)
            }
            .frame(height: 200)
            .chartYAxisLabel("Estimated 1RM (kg)")
            .chartXScale(domain: selectedPeriod.dateInterval.start ... selectedPeriod.dateInterval.end)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No strength data")
                .font(.title3)
                .fontWeight(.semibold)
            Text("Complete workouts to track your strength progress")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
    
    private func loadStrengthData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let snapshot = try await trainingAnalytics.getProgressSnapshot(for: selectedPeriod.dateInterval)
            strengthMetrics = snapshot.strengthMetrics
            
            // Auto-select first PR if available
            if let firstPR = snapshot.strengthMetrics.personalRecords.first {
                selectedExerciseId = firstPR.exerciseId
            }
        } catch {
            print("Error loading strength data: \(error)")
        }
    }
    
    private func loadExerciseProgression(_ exerciseId: String) async {
        do {
            let progression = try await trainingAnalytics.getStrengthProgression(
                for: exerciseId,
                in: selectedPeriod.dateInterval
            )
            exerciseProgression = progression
        } catch {
            print("Error loading exercise progression: \(error)")
        }
    }
}

#Preview("Main State") {
    StrengthProgressView()
        .previewEnvironment()
}

#Preview("Is Loading") {
    StrengthProgressView()
        .environment(TrainingAnalyticsManager(services: MockTrainingAnalyticsServices(delay: 3)))
        .previewEnvironment()
}

#Preview("No Data") {
    StrengthProgressView()
        .environment(TrainingAnalyticsManager(services: MockTrainingAnalyticsServices(showError: true)))
        .previewEnvironment()
}
