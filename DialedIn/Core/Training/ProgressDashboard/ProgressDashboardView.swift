//
//  ProgressDashboardView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import Charts
import SwiftfulRouting

struct ProgressDashboardView: View {
    
    @State var presenter: ProgressDashboardPresenter

    var body: some View {
        List {
            // Period selector
            periodPicker
            
            if presenter.isLoading {
                ProgressView()
                    .padding(40)
            } else if let snapshot = presenter.progressSnapshot {
                // Performance metrics
                performanceSection(snapshot.performanceMetrics)
                
                // Volume metrics
                volumeSection(snapshot.volumeMetrics)
                
                // Strength metrics
                strengthSection(snapshot.strengthMetrics)
            } else {
                emptyState
            }
        }
        .navigationTitle("Progress Analytics")
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
            await presenter.loadProgressData()
        }
        .onChange(of: presenter.selectedPeriod) { _, _ in
            Task {
                await presenter.loadProgressData()
            }
        }
    }
    
    private var periodPicker: some View {
        Picker("Period", selection: $presenter.selectedPeriod) {
            ForEach(TimePeriod.allCases, id: \.self) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .removeListRowFormatting()
    }
    
    private func performanceSection(_ metrics: PerformanceMetrics) -> some View {
        Section {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                MetricCard(
                    title: "Completion Rate",
                    value: "\(Int(metrics.adherencePercentage))%",
                    icon: "checkmark.circle.fill",
                    color: metrics.completionRate >= 0.8 ? .green : .orange
                )
                
                MetricCard(
                    title: "Training Frequency",
                    value: String(format: "%.1f/week", metrics.trainingFrequency),
                    icon: "calendar",
                    color: .blue
                )
                
                MetricCard(
                    title: "Current Streak",
                    value: "\(metrics.currentStreak) days",
                    icon: "flame.fill",
                    color: .orange
                )
                
                MetricCard(
                    title: "Total Workouts",
                    value: "\(metrics.totalWorkouts)",
                    icon: "figure.strengthtraining.traditional",
                    color: .purple
                )
            }
            .removeListRowFormatting()
        } header: {
            Text("Performance")
        }
    }
    
    private func volumeSection(_ metrics: VolumeMetrics) -> some View {
        Section {
            VStack {
                // Total volume
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Volume")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("\(Int(metrics.totalVolume)) kg")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Avg per Workout")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("\(Int(metrics.averageVolumePerWorkout)) kg")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .background(.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Volume by muscle group
                if !metrics.volumeByMuscleGroup.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Volume by Muscle Group")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        ForEach(Array(metrics.volumeByMuscleGroup.sorted(by: { $0.value > $1.value })), id: \.key) { muscleGroup, volume in
                            HStack {
                                Text(muscleGroup.description)
                                    .font(.caption)
                                Spacer()
                                Text("\(Int(volume)) kg")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                
                                // Progress bar
                                let maxVolume = metrics.volumeByMuscleGroup.values.max() ?? 1
                                ProgressView(value: volume / maxVolume)
                                    .frame(width: 60)
                            }
                        }
                    }
                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Training Volume")
        }
    }
    
    private func strengthSection(_ metrics: StrengthMetrics) -> some View {
        Section {
            Group {
                if !metrics.personalRecords.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Personal Records")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        ForEach(metrics.personalRecords.prefix(5)) { personalRecord in
                            PersonalRecordRow(record: personalRecord)
                        }
                    }
                } else {
                    Text("No personal records yet. Keep training to set your first PR!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding()
                }
                
                // Progression rate
                if metrics.strengthProgressionRate > 0 {
                    HStack {
                        Image(systemName: "arrow.up.right")
                            .foregroundStyle(.green)
                        Text("Strength increasing by \(String(format: "%.1f%%", metrics.strengthProgressionRate)) per period")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Strength Progress")
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No data available")
                .font(.title3)
                .fontWeight(.semibold)
            Text("Complete some workouts to see your progress analytics")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.progressDashboardView(router: router)
    }
    .previewEnvironment()
}
