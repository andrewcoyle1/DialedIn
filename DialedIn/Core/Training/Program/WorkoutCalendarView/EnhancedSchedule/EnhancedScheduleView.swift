//
//  EnhancedScheduleView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct EnhancedScheduleViewDelegate {
    var getScheduledWorkouts: () -> [ScheduledWorkout]
    var onDateSelected: (Date) -> Void
    var onDateTapped: (Date) -> Void
}

struct EnhancedScheduleView: View {
    
    @State var viewModel: EnhancedScheduleViewModel

    var delegate: EnhancedScheduleViewDelegate

    var body: some View {
        VStack(spacing: 16) {
            // Month navigation
            monthNavigator
            
            // Weekday headers
            weekdayHeaders
            
            // Calendar grid
            calendarGrid
        }
    }
    
    private var monthNavigator: some View {
        HStack {
            Button {
                if let newDate = viewModel.calendar.date(byAdding: .month, value: -1, to: viewModel.selectedDate) {
                    viewModel.selectedDate = newDate
                }
            } label: {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.borderedProminent)
            Spacer()
            
            Text(viewModel.selectedDate.formatted(.dateTime.month(.wide).year()))
                .font(.headline)
            
            Spacer()
            
            Button {
                if let newDate = viewModel.calendar.date(byAdding: .month, value: 1, to: viewModel.selectedDate) {
                    viewModel.selectedDate = newDate
                }
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private var weekdayHeaders: some View {
        HStack(spacing: 0) {
            ForEach(Array(viewModel.calendar.veryShortWeekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var calendarGrid: some View {
        let days = viewModel.daysInMonth()
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
        
        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(days.indices, id: \.self) { index in
                if let date = days[index] {
                    dayCell(for: date)
                } else {
                    Color.clear
                        .frame(height: 50)
                }
            }
        }
        .id("\(viewModel.calendar.component(.month, from: viewModel.selectedDate))-\(viewModel.calendar.component(.year, from: viewModel.selectedDate))")
    }
    
    private func dayCell(for date: Date) -> some View {
        let workouts = viewModel.workoutsForDate(date, getScheduledWorkouts: delegate.getScheduledWorkouts)
        let isToday = viewModel.calendar.isDateInToday(date)
        let hasWorkouts = !workouts.isEmpty
        let completedCount = workouts.filter { $0.isCompleted }.count
        let missedCount = workouts.filter { $0.isMissed }.count
        
        return Button {
            viewModel.selectedDate = date
            delegate.onDateTapped(date)
            if hasWorkouts {
                delegate.onDateSelected(date)
            }
        } label: {
            VStack(spacing: 4) {
                Text("\(viewModel.calendar.component(.day, from: date))")
                    .font(.system(size: 16))
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(isToday ? .blue : .primary)
                
                // Workout indicators
                HStack(spacing: 2) {
                    if completedCount > 0 {
                        Circle()
                            .fill(.green)
                            .frame(width: 6, height: 6)
                    }
                    if missedCount > 0 {
                        Circle()
                            .fill(.red)
                            .frame(width: 6, height: 6)
                    }
                    if workouts.count > completedCount + missedCount {
                        Circle()
                            .fill(.orange)
                            .frame(width: 6, height: 6)
                    }
                }
                .frame(height: 8)
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(hasWorkouts ? Color.blue.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isToday ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.enhancedScheduleView(
        delegate: EnhancedScheduleViewDelegate(
            getScheduledWorkouts: { ScheduledWorkout.mocksWeek1 },
            onDateSelected: { _ in

            }, onDateTapped: { _ in

            }
        )
    )
    .previewEnvironment()
}
