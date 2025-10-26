//
//  ProgramStartConfigViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol ProgramStartConfigInteractor {
    
}

extension CoreInteractor: ProgramStartConfigInteractor { }

@Observable
@MainActor
class ProgramStartConfigViewModel {
    private let interactor: ProgramStartConfigInteractor
    
    var startDate = Date()
    var hasEndDate = false
    var endDate = Date()
    var useCustomName = false
    var customName = ""
    
    private(set) var template: ProgramTemplateModel!
    private(set) var onStart: ((Date, Date?, String?) -> Void)!
    
    init(
        interactor: ProgramStartConfigInteractor
    ) {
        self.interactor = interactor
    }
    
    func setTemplate(_ template: ProgramTemplateModel) {
        self.template = template
    }
    
    func setOnStart(_ onStart: @escaping (Date, Date?, String?) -> Void) {
        self.onStart = onStart
    }
    
    func dayName(for dayOfWeek: Int) -> String {
        let calendar = Calendar.current
        let weekdaySymbols = calendar.weekdaySymbols
        let index = (dayOfWeek - 1) % 7
        return weekdaySymbols[index]
    }
    
    func calculatedDate(for dayOfWeek: Int) -> Date {
        let calendar = Calendar.current
        let currentDayOfWeek = calendar.component(.weekday, from: startDate)
        
        // If start date is the target day, return start date
        if currentDayOfWeek == dayOfWeek {
            return startDate
        }
        
        // Calculate days to add
        var daysToAdd = dayOfWeek - currentDayOfWeek
        if daysToAdd < 0 {
            daysToAdd += 7 // Move to next week
        }
        
        return calendar.date(byAdding: .day, value: daysToAdd, to: startDate) ?? startDate
    }
    
    func calculateDefaultEndDate(from startDate: Date) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .weekOfYear, value: template.duration, to: startDate) ?? startDate
    }
    
    func calculateWeeks(from startDate: Date, to endDate: Date) -> Int {
        let calendar = Calendar.current
        let weeks = calendar.dateComponents([.weekOfYear], from: startDate, to: endDate).weekOfYear ?? 0
        return max(weeks, 0)
    }
}
