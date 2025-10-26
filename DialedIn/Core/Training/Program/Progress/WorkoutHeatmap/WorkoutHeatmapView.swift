//
//  WorkoutHeatmapView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct WorkoutHeatmapView: View {
    @State var viewModel: WorkoutHeatmapViewModel
    @Environment(\.dismiss) private var dismiss
   
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Month selector
                    monthNavigator
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(40)
                    } else {
                        // Weekday headers
                        weekdayHeaders
                        
                        // Calendar grid
                        calendarGrid
                        
                        // Legend
                        heatmapLegend
                        
                        // Stats
                        if let metrics = viewModel.performanceMetrics {
                            heatmapStatsSection(metrics)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Training Frequency")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.loadHeatmapData()
            }
            .onChange(of: viewModel.selectedMonth) { _, _ in
                Task {
                    await viewModel.loadHeatmapData()
                }
            }
        }
    }
    
    private var monthNavigator: some View {
        HStack {
            Button {
                if let newMonth = viewModel.calendar.date(byAdding: .month, value: -1, to: viewModel.selectedMonth) {
                    viewModel.selectedMonth = newMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
            }
            
            Spacer()
            
            Text(viewModel.selectedMonth.formatted(.dateTime.month(.wide).year()))
                .font(.headline)
            
            Spacer()
            
            Button {
                if let newMonth = viewModel.calendar.date(byAdding: .month, value: 1, to: viewModel.selectedMonth),
                   newMonth <= Date() {
                    viewModel.selectedMonth = newMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
            }
            .disabled(viewModel.calendar.isDate(viewModel.selectedMonth, equalTo: Date(), toGranularity: .month))
        }
        .padding(.horizontal)
    }
    
    private var weekdayHeaders: some View {
        LazyVGrid(columns: viewModel.columns, spacing: 4) {
            ForEach(Array(viewModel.calendar.veryShortWeekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(height: 20)
            }
        }
        .padding(.horizontal)
    }
    
    private var calendarGrid: some View {
        LazyVGrid(columns: viewModel.columns, spacing: 4) {
            ForEach(viewModel.daysInMonth(), id: \.self) { date in
                if let date = date {
                    dayCell(for: date)
                } else {
                    Color.clear
                        .frame(height: 44)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func dayCell(for date: Date) -> some View {
        let workoutCount = viewModel.heatmapData[viewModel.calendar.startOfDay(for: date)] ?? 0
        let intensity = viewModel.intensityColor(for: workoutCount)
        let isToday = viewModel.calendar.isDateInToday(date)
        
        return ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(intensity)
            
            if isToday {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: 2)
            }
            
            VStack(spacing: 2) {
                Text("\(viewModel.calendar.component(.day, from: date))")
                    .font(.caption)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(workoutCount > 0 ? .white : .primary)
                
                if workoutCount > 0 {
                    Text("\(workoutCount)")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(height: 44)
    }
    
    private func heatmapStatsSection(_ metrics: PerformanceMetrics) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Summary")
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Workouts")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(metrics.totalWorkouts)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Avg per Week")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f", metrics.trainingFrequency))
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            
            if !metrics.restDayPattern.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Most Common Rest Days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 8) {
                        ForEach(metrics.restDayPattern.prefix(3), id: \.self) { dayIndex in
                            Text(viewModel.calendar.weekdaySymbols[dayIndex - 1])
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.blue.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var heatmapLegend: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Workout Frequency")
                .font(.caption)
                .fontWeight(.medium)
            
            HStack(spacing: 4) {
                Text("Less")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                ForEach(0...4, id: \.self) { level in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(viewModel.intensityColor(for: level))
                        .frame(width: 16, height: 16)
                }
                
                Text("More")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview("Loaded") {
    let workoutSessionManager = WorkoutSessionManager(services: MockWorkoutSessionServices())
    let exerciseTemplateManager = ExerciseTemplateManager(services: MockExerciseTemplateServices())
    let analytics = ProgressAnalyticsService(
        workoutSessionManager: workoutSessionManager,
        exerciseTemplateManager: exerciseTemplateManager
    )
    
    return WorkoutHeatmapView(
        viewModel: WorkoutHeatmapViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            ),
            progressAnalytics: analytics
        )
    )
        .previewEnvironment()
}

#Preview("Is Loading") {
    let workoutSessionManager = WorkoutSessionManager(services: MockWorkoutSessionServices())
    let exerciseTemplateManager = ExerciseTemplateManager(services: MockExerciseTemplateServices())
    let analytics = ProgressAnalyticsService(
        workoutSessionManager: workoutSessionManager,
        exerciseTemplateManager: exerciseTemplateManager
    )
    
    return WorkoutHeatmapView(viewModel: WorkoutHeatmapViewModel(interactor: CoreInteractor(
        container: DevPreview.shared.container
    ), progressAnalytics: analytics))
        .previewEnvironment()
}

#Preview("Fail") {
    let workoutSessionManager = WorkoutSessionManager(services: MockWorkoutSessionServices())
    let exerciseTemplateManager = ExerciseTemplateManager(services: MockExerciseTemplateServices())
    let analytics = ProgressAnalyticsService(
        workoutSessionManager: workoutSessionManager,
        exerciseTemplateManager: exerciseTemplateManager
    )
    
    return WorkoutHeatmapView(viewModel: WorkoutHeatmapViewModel(interactor: CoreInteractor(
        container: DevPreview.shared.container
    ), progressAnalytics: analytics))
        .previewEnvironment()
}
