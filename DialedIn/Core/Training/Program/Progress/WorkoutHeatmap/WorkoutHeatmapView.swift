//
//  WorkoutHeatmapView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct WorkoutHeatmapView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var progressAnalytics: ProgressAnalyticsService
    @State private var performanceMetrics: PerformanceMetrics?
    @State private var heatmapData: [Date: Int] = [:]
    @State private var isLoading = false
    @State private var selectedMonth: Date = Date()
    
    init(progressAnalytics: ProgressAnalyticsService) {
        self.progressAnalytics = progressAnalytics
    }
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Month selector
                    monthNavigator
                    
                    if isLoading {
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
                        if let metrics = performanceMetrics {
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
                await loadHeatmapData()
            }
            .onChange(of: selectedMonth) { _, _ in
                Task {
                    await loadHeatmapData()
                }
            }
        }
    }
    
    private var monthNavigator: some View {
        HStack {
            Button {
                if let newMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) {
                    selectedMonth = newMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
            }
            
            Spacer()
            
            Text(selectedMonth.formatted(.dateTime.month(.wide).year()))
                .font(.headline)
            
            Spacer()
            
            Button {
                if let newMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth),
                   newMonth <= Date() {
                    selectedMonth = newMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
            }
            .disabled(calendar.isDate(selectedMonth, equalTo: Date(), toGranularity: .month))
        }
        .padding(.horizontal)
    }
    
    private var weekdayHeaders: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(Array(calendar.veryShortWeekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(height: 20)
            }
        }
        .padding(.horizontal)
    }
    
    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(daysInMonth(), id: \.self) { date in
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
        let workoutCount = heatmapData[calendar.startOfDay(for: date)] ?? 0
        let intensity = intensityColor(for: workoutCount)
        let isToday = calendar.isDateInToday(date)
        
        return ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(intensity)
            
            if isToday {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: 2)
            }
            
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
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
                            Text(calendar.weekdaySymbols[dayIndex - 1])
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
                        .fill(intensityColor(for: level))
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
    
    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedMonth) else {
            return []
        }
        
        let monthStart = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 0
        
        var days: [Date?] = []
        
        // Add leading empty cells
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add actual days
        for day in 0..<daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day, to: monthStart) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func intensityColor(for workoutCount: Int) -> Color {
        switch workoutCount {
        case 0:
            return Color.gray.opacity(0.1)
        case 1:
            return Color.green.opacity(0.3)
        case 2:
            return Color.green.opacity(0.6)
        case 3:
            return Color.green.opacity(0.8)
        default:
            return Color.green
        }
    }
    
    private func loadHeatmapData() async {
        isLoading = true
        defer { isLoading = false }
        
        // Get month interval
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedMonth) else {
            return
        }
        
        do {
            let snapshot = try await progressAnalytics.getProgressSnapshot(for: monthInterval)
            performanceMetrics = snapshot.performanceMetrics
            
            // For now, create mock heatmap data
            // In production, this would come from actual workout sessions
            var data: [Date: Int] = [:]
            for day in 0..<30 {
                if let date = calendar.date(byAdding: .day, value: day, to: monthInterval.start) {
                    let workoutCount = Int.random(in: 0...2)
                    if workoutCount > 0 {
                        data[calendar.startOfDay(for: date)] = workoutCount
                    }
                }
            }
            heatmapData = data
        } catch {
            print("Error loading heatmap data: \(error)")
        }
    }
}

#Preview("Loaded") {
    let workoutSessionManager = WorkoutSessionManager(services: MockWorkoutSessionServices())
    let exerciseTemplateManager = ExerciseTemplateManager(services: MockExerciseTemplateServices())
    let analytics = ProgressAnalyticsService(
        workoutSessionManager: workoutSessionManager,
        exerciseTemplateManager: exerciseTemplateManager
    )
    
    return WorkoutHeatmapView(progressAnalytics: analytics)
        .previewEnvironment()
}

#Preview("Is Loading") {
    let workoutSessionManager = WorkoutSessionManager(services: MockWorkoutSessionServices())
    let exerciseTemplateManager = ExerciseTemplateManager(services: MockExerciseTemplateServices())
    let analytics = ProgressAnalyticsService(
        workoutSessionManager: workoutSessionManager,
        exerciseTemplateManager: exerciseTemplateManager
    )
    
    return WorkoutHeatmapView(progressAnalytics: analytics)
        .previewEnvironment()
}

#Preview("fail") {
    let workoutSessionManager = WorkoutSessionManager(services: MockWorkoutSessionServices())
    let exerciseTemplateManager = ExerciseTemplateManager(services: MockExerciseTemplateServices())
    let analytics = ProgressAnalyticsService(
        workoutSessionManager: workoutSessionManager,
        exerciseTemplateManager: exerciseTemplateManager
    )
    
    return WorkoutHeatmapView(progressAnalytics: analytics)
        .previewEnvironment()
}
