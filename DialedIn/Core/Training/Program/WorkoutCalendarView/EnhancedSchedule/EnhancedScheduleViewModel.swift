//
//  EnhancedScheduleViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

protocol EnhancedScheduleInteractor {
    
}

extension CoreInteractor: EnhancedScheduleInteractor { }

@Observable
@MainActor
class EnhancedScheduleViewModel {
    let interactor: EnhancedScheduleInteractor
    let calendar = Calendar.current

    var selectedDate: Date = Date()
    var selectedTime: Date = Date()

    init(interactor: EnhancedScheduleInteractor) {
        self.interactor = interactor
    }
    
    func daysInMonth() -> [Date?] {
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
    
    func workoutsForDate(_ date: Date, getScheduledWorkouts: () -> [ScheduledWorkout]) -> [ScheduledWorkout] {
        getScheduledWorkouts().filter { workout in
            guard let scheduledDate = workout.scheduledDate else { return false }
            return calendar.isDate(scheduledDate, inSameDayAs: date)
        }
    }
}
