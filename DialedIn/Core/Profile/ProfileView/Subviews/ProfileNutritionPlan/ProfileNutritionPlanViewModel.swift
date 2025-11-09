//
//  ProfileNutritionPlanViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol ProfileNutritionPlanInteractor {
    var currentDietPlan: DietPlan? { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ProfileNutritionPlanInteractor { }

@Observable
@MainActor
class ProfileNutritionPlanViewModel {
    private let interactor: ProfileNutritionPlanInteractor
   
    var currentDietPlan: DietPlan? {
        interactor.currentDietPlan
    }
    
    init(interactor: ProfileNutritionPlanInteractor) {
        self.interactor = interactor
    }

    func navToNutritionDetail(path: Binding<[TabBarPathOption]>) {
        interactor.trackEvent(event: Event.navigate(destination: .profileNutritionDetail))
        path.wrappedValue.append(.profileNutritionDetail)
    }

    enum Event: LoggableEvent {
        case navigate(destination: TabBarPathOption)

        var eventName: String {
            switch self {
            case .navigate:     return "Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .navigate(destination: let destination):
                return destination.eventParameters
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
