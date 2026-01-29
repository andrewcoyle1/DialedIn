//
//  StrengthProgressView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import Charts
import SwiftfulRouting

struct StrengthProgressView: View {
    @State var presenter: StrengthProgressPresenter

    var body: some View {
            List {
                // Period picker
                Section {
                    Picker("Period", selection: $presenter.selectedPeriod) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .removeListRowFormatting()
                .listSectionSpacing(0)
                
                if presenter.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 200)
                        .removeListRowFormatting()
                } else if let metrics = presenter.strengthMetrics {
                    personalRecordsSection(metrics)
                    
                    if let progression = presenter.exerciseProgression {
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
                    Button {
                        presenter.onDismissPressed()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .task {
                await presenter.loadStrengthData()
            }
            .onChange(of: presenter.selectedPeriod) { _, _ in
                Task {
                    await presenter.loadStrengthData()
                    if let id = presenter.selectedExerciseId {
                        await presenter.loadExerciseProgression(id)
                    }
                }
            }
            .onChange(of: presenter.selectedExerciseId) { _, newValue in
                if let exerciseId = newValue {
                    Task {
                        await presenter.loadExerciseProgression(exerciseId)
                    }
                }
            }
    }
    
    private func personalRecordsSection(_ metrics: StrengthMetrics) -> some View {
        Section {
            if !metrics.personalRecords.isEmpty {
                ForEach(metrics.personalRecords.prefix(10)) { personalRecord in
                    Button {
                        presenter.selectedExerciseId = personalRecord.exerciseId
                    } label: {
                        PRCard(record: personalRecord, isSelected: presenter.selectedExerciseId == personalRecord.exerciseId)
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
                    presenter.selectedExerciseId = nil
                    presenter.exerciseProgression = nil
                } label: {
                    if presenter.selectedExerciseId != nil {
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
            .chartXScale(domain: presenter.selectedPeriod.dateInterval.start ... presenter.selectedPeriod.dateInterval.end)
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
}

extension CoreBuilder {
    func strengthProgressView(router: AnyRouter) -> some View {
        StrengthProgressView(
            presenter: StrengthProgressPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }
}

extension CoreRouter {
    func showStrengthProgressView() {
        router.showScreen(.sheet) { router in
            builder.strengthProgressView(router: router)
        }
    }
}

#Preview("Main State") {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.strengthProgressView(router: router)
    }
    .previewEnvironment()
}

#Preview("Is Loading") {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.strengthProgressView(router: router)
    }
    .previewEnvironment()
}

#Preview("No Data") {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.strengthProgressView(router: router)
    }
    .previewEnvironment()
}
