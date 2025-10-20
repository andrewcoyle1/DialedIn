//
//  EnhancedScheduleView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct EnhancedScheduleView: View {
    let scheduledWorkouts: [ScheduledWorkout]
    let onDateSelected: (Date) -> Void
    let onDateTapped: (Date) -> Void
    
    @State private var selectedDate: Date = Date()
    @State private var selectedTime: Date = Date()
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 16) {
            // Month navigation
            monthNavigator
            
            // Weekday headers
            weekdayHeaders
            
            // Calendar grid
            calendarGrid
        }
        // .padding()
    }
    
    private var monthNavigator: some View {
        HStack {
            Button {
                if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
                    selectedDate = newDate
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body)
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.gray.opacity(0.1)))
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Text(selectedDate.formatted(.dateTime.month(.wide).year()))
                .font(.headline)
            
            Spacer()
            
            Button {
                if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
                    selectedDate = newDate
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.gray.opacity(0.1)))
            }
            .buttonStyle(.plain)
        }
    }
    
    private var weekdayHeaders: some View {
        HStack(spacing: 0) {
            ForEach(Array(calendar.veryShortWeekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var calendarGrid: some View {
        let days = daysInMonth()
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
    }
    
    private func dayCell(for date: Date) -> some View {
        let workouts = workoutsForDate(date)
        let isToday = calendar.isDateInToday(date)
        let hasWorkouts = !workouts.isEmpty
        let completedCount = workouts.filter { $0.isCompleted }.count
        let missedCount = workouts.filter { $0.isMissed }.count
        
        return Button {
            selectedDate = date
            onDateTapped(date)
            if hasWorkouts {
                onDateSelected(date)
            }
        } label: {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
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
    
    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate) else {
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
    
    private func workoutsForDate(_ date: Date) -> [ScheduledWorkout] {
        scheduledWorkouts.filter { workout in
            guard let scheduledDate = workout.scheduledDate else { return false }
            return calendar.isDate(scheduledDate, inSameDayAs: date)
        }
    }
}

#Preview {
    EnhancedScheduleView(
        scheduledWorkouts: ScheduledWorkout.mocksWeek1,
        onDateSelected: { _ in
            
        }, onDateTapped: { _ in
            
        }
    )
    .previewEnvironment()
}
