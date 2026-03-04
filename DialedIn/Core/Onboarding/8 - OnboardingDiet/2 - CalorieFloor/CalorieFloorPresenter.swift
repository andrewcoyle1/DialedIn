//
//  CalorieFloorPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class CalorieFloorPresenter {
    private let interactor: CalorieFloorInteractor
    private let router: CalorieFloorRouter

    var selectedFloor: CalorieFloor?
    var trainingDaysPerWeek: Int?
    var hasTrainingPlan: Bool = false

    init(
        interactor: CalorieFloorInteractor,
        router: CalorieFloorRouter
    ) {
        self.interactor = interactor
        self.router = router
        loadTrainingContext()
    }
    
    private func loadTrainingContext() {
    }
    
    private func prefillCalorieFloor(daysPerWeek: Int) {
        // Heuristic: 1-2 days = standard (conservative), 3-4 = standard, 5-6 = standard
        // Since we only have standard and low, default to standard for all
        if selectedFloor == nil {
            selectedFloor = .standard
            interactor.trackEvent(event: Event.calorieFloorPrefilled(floor: .standard, reason: "training_days_\(daysPerWeek)"))
        }
    }
    
    func onContinuePressed(delegate oldDelegate: CalorieFloorDelegate) {
        guard let floor = selectedFloor else { return }
        let delegate = CalorieDistributionDelegate(delegate: oldDelegate, calorieFloor: floor)
        interactor.trackEvent(event: Event.navigate())
        router.showCalorieDistributionView(delegate: delegate)
        
    }

#if DEV || MOCK
func onDevSettingsPressed() {
    router.showDevSettingsView()
}
#endif

    enum Event: LoggableEvent {
        case trainingContextLoaded(daysPerWeek: Int?)
        case calorieFloorPrefilled(floor: CalorieFloor, reason: String)
        case navigate(skipReason: String? = nil)

        var eventName: String {
            switch self {
            case .trainingContextLoaded: return "Onboarding_CalFloor_TrainingContextLoaded"
            case .calorieFloorPrefilled: return "Onboarding_CalFloor_Prefilled"
            case .navigate: return "Onboarding_CalFloor_Navigate"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .trainingContextLoaded(daysPerWeek: let days):
                return ["daysPerWeek": days as Any]
            case .calorieFloorPrefilled(floor: let floor, reason: let reason):
                return ["floor": floor.rawValue, "reason": reason]
            case .navigate(skipReason: let skipReason):
                var params: [String: Any] = [:]
                if let skipReason = skipReason {
                    params["skipReason"] = skipReason
                }
                return params
            }
        }
        
        var type: LogType {
            switch self {
            case .navigate, .trainingContextLoaded, .calorieFloorPrefilled:
                return .info
            }
        }
    }
}

enum CalorieFloor: String, CaseIterable, Identifiable {
    case standard
    case low
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .standard:
            return "Standard Floor (Recommended)"
        case .low:
            return "Low Floor"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .standard:
            return "Your recommendations will never go below 1200 calories per day, even if your TDEE is lower."
        case .low:
            return "Your recommendations will never go below 800 calories per day. Proceed with caution."
        }
    }
}
