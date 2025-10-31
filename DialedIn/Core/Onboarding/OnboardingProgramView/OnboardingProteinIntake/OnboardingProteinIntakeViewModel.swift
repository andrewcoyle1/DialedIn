//
//  OnboardingProteinIntakeViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingProteinIntakeInteractor {
    var currentUser: UserModel? { get }
    var dietPlanDraft: DietPlanDraft { get }
    func createAndSaveDietPlan(user: UserModel?, configuration: DietPlanConfiguration) async throws
    func resetDietPlanDraft()
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingProteinIntakeInteractor { }

@Observable
@MainActor
class OnboardingProteinIntakeViewModel {
    private let interactor: OnboardingProteinIntakeInteractor
        
    var selectedProteinIntake: ProteinIntake?
    var navigateToNextStep: Bool = false
    var showModal: Bool = false
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(interactor: OnboardingProteinIntakeInteractor) {
        self.interactor = interactor
    }
    
    func createPlan(path: Binding<[OnboardingPathOption]>) {
        showModal = true
        interactor.trackEvent(event: Event.createPlanStart)
        Task {
            do {
                if let proteinIntake = selectedProteinIntake {
                    let diet = interactor.dietPlanDraft
                    guard let preferredDiet = diet.preferredDiet,
                          let calorieFloor = diet.calorieFloor,
                          let trainingType = diet.trainingType,
                          let calorieDistribution = diet.calorieDistribution else {
                        throw NSError(domain: "DietPlanError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Diet plan draft is incomplete"])
                    }
                    
                    let configuration = DietPlanConfiguration(
                        preferredDiet: preferredDiet,
                        calorieFloor: calorieFloor,
                        trainingType: trainingType,
                        calorieDistribution: calorieDistribution,
                        proteinIntake: proteinIntake
                    )
                    try await interactor.createAndSaveDietPlan(
                        user: interactor.currentUser,
                        configuration: configuration
                    )
                    interactor.resetDietPlanDraft()
                    interactor.trackEvent(event: Event.createPlanSuccess)
                    path.wrappedValue.append(.dietPlan)
                }
            } catch {
                interactor.trackEvent(event: Event.createPlanFail(error: error))
            }
            showModal = false
        }
    }
        
    enum Event: LoggableEvent {
        case createPlanStart
        case createPlanSuccess
        case createPlanFail(error: Error)

        var eventName: String {
            switch self {
            case .createPlanStart:   return "OnboardingDietPlan_CreatePlan_Start"
            case .createPlanSuccess: return "OnboardingDietPlan_CreatePlan_Success"
            case .createPlanFail:    return "OnboardingDietPlan_CreatePlan_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .createPlanFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .createPlanFail:
                return .severe
            default:
                return .analytic
                
            }
        }
    }
}

enum ProteinIntake: String, CaseIterable, Identifiable {
    case low
    case moderate
    case high
    case veryHigh
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .low:
            return "Low"
        case .moderate:
            return "Moderate"
        case .high:
            return "High"
        case .veryHigh:
            return "Very High"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .low:
            return "On the low side of the optimal range."
        case .moderate:
            return "In the middle of the optimal range."
        case .high:
            return "On the high end of the optimal range."
        case .veryHigh:
            return "Highest recommended intake."
        }
    }
}
