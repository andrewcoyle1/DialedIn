//
//  ProgramStartConfigViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol ProgramStartConfigInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ProgramStartConfigInteractor { }

@MainActor
protocol ProgramStartConfigRouter {
    func showProgramPreviewView(delegate: ProgramPreviewViewDelegate)
    func showDevSettingsView()
}

extension CoreRouter: ProgramStartConfigRouter { }

@Observable
@MainActor
class ProgramStartConfigViewModel {
    private let interactor: ProgramStartConfigInteractor
    private let router: ProgramStartConfigRouter

    var startDate = Date()
    var hasEndDate = false
    var endDate = Date()
    var useCustomName = false
    var customName = ""
    
    init(
        interactor: ProgramStartConfigInteractor,
        router: ProgramStartConfigRouter
    ) {
        self.interactor = interactor
        self.router = router
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
    
    func calculateDefaultEndDate(template: ProgramTemplateModel, from startDate: Date) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .weekOfYear, value: template.duration, to: startDate) ?? startDate
    }
    
    func calculateWeeks(from startDate: Date, to endDate: Date) -> Int {
        let calendar = Calendar.current
        let weeks = calendar.dateComponents([.weekOfYear], from: startDate, to: endDate).weekOfYear ?? 0
        return max(weeks, 0)
    }

    func navToProgramPreviewView(template: ProgramTemplateModel) {
        interactor.trackEvent(event: Event.navigate)
        router.showProgramPreviewView(delegate: ProgramPreviewViewDelegate(template: template, startDate: startDate))
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "ProgramStartConfig_Navigate"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .navigate:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .navigate:
                return .info
            }
        }
    }
}
