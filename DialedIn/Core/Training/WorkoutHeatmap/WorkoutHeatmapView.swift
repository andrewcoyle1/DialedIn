//
//  WorkoutHeatmapView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct WorkoutHeatmapView: View {
    
    @State var presenter: WorkoutHeatmapPresenter

    var body: some View {
        List {
            Section {
                VStack {
                    // Month selector
                    monthNavigator
                    
                    if presenter.isLoading {
                        ProgressView()
                            .padding(40)
                    } else {
                        // Weekday headers
                        weekdayHeaders
                        
                        // Calendar grid
                        calendarGrid
                    }
                }
            } header: {
                Text("Heatmap")
            } footer: {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Workout Frequency")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 4) {
                        Text("Less")
                            .font(.caption2)
                        
                        ForEach(0...4, id: \.self) { level in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(presenter.intensityColor(for: level))
                                .frame(width: 16, height: 16)
                        }
                        
                        Text("More")
                            .font(.caption2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            if !presenter.isLoading {
                // Stats
                if let metrics = presenter.performanceMetrics {
                    Section {
                        heatmapStatsSection(metrics)
                    } header: {
                        Text("Monthly Summary")
                    }
                    
                }
            }
        }
        .navigationTitle("Training Frequency")
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
            await presenter.loadHeatmapData()
        }
        .onChange(of: presenter.selectedMonth) { _, _ in
            Task {
                await presenter.loadHeatmapData()
            }
        }
    }
    
    private var monthNavigator: some View {
        HStack {
            Button {
                if let newMonth = presenter.calendar.date(byAdding: .month, value: -1, to: presenter.selectedMonth) {
                    presenter.selectedMonth = newMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
            }
            
            Spacer()
            
            Text(presenter.selectedMonth.formatted(.dateTime.month(.wide).year()))
                .font(.headline)
            
            Spacer()
            
            Button {
                if let newMonth = presenter.calendar.date(byAdding: .month, value: 1, to: presenter.selectedMonth),
                   newMonth <= Date() {
                    presenter.selectedMonth = newMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
            }
            .disabled(presenter.calendar.isDate(presenter.selectedMonth, equalTo: Date(), toGranularity: .month))
        }
        .padding(.horizontal)
    }
    
    private var weekdayHeaders: some View {
        LazyVGrid(columns: presenter.columns, spacing: 4) {
            ForEach(Array(presenter.calendar.veryShortWeekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(height: 20)
            }
        }
        .padding(.horizontal)
    }
    
    private var calendarGrid: some View {
        LazyVGrid(columns: presenter.columns, spacing: 4) {
            ForEach(presenter.daysInMonth(), id: \.self) { date in
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
        let workoutCount = presenter.heatmapData[presenter.calendar.startOfDay(for: date)] ?? 0
        let intensity = presenter.intensityColor(for: workoutCount)
        let isToday = presenter.calendar.isDateInToday(date)
        
        return ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(intensity)
            
            if isToday {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: 2)
            }
            
            VStack(spacing: 2) {
                Text("\(presenter.calendar.component(.day, from: date))")
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
        Group {
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
                            Text(presenter.calendar.weekdaySymbols[dayIndex - 1])
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
    }
}

extension CoreBuilder {
    func workoutHeatmapView(router: AnyRouter) -> some View {
        WorkoutHeatmapView(
            presenter: WorkoutHeatmapPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }
}

extension CoreRouter {
    func showWorkoutHeatmapView() {
        router.showScreen(.sheet) { router in
            builder.workoutHeatmapView(router: router)
        }
    }
}

#Preview("Loaded") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.workoutHeatmapView(router: router)
    }
    .previewEnvironment()
}

#Preview("Is Loading") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.workoutHeatmapView(router: router)
    }
    .previewEnvironment()
}

#Preview("Fail") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.workoutHeatmapView(router: router)
    }
    .previewEnvironment()
}
