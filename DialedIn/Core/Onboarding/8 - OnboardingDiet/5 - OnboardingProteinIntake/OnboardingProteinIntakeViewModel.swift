//
//  OnboardingProteinIntakeViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingProteinIntakeInteractor {
    var currentUser: UserModel? { get }
    var currentTrainingPlan: TrainingPlan? { get }
    func get(id: String) -> ProgramTemplateModel?
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
    var trainingDifficulty: DifficultyLevel?
    var hasTrainingPlan: Bool = false
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(interactor: OnboardingProteinIntakeInteractor) {
        self.interactor = interactor
        loadTrainingContext()
    }
    
    private func loadTrainingContext() {
        if let plan = interactor.currentTrainingPlan {
            hasTrainingPlan = true
            // Get template difficulty if available
            if let templateId = plan.programTemplateId,
               let template = interactor.get(id: templateId) {
                trainingDifficulty = template.difficulty
                prefillProteinIntake(difficulty: template.difficulty)
            }
            interactor.trackEvent(event: Event.trainingContextLoaded(difficulty: trainingDifficulty))
        }
    }
    
    private func prefillProteinIntake(difficulty: DifficultyLevel) {
        // Heuristic: beginner -> moderate, intermediate -> high, advanced -> veryHigh
        if selectedProteinIntake == nil {
            switch difficulty {
            case .beginner:
                selectedProteinIntake = .moderate
            case .intermediate:
                selectedProteinIntake = .high
            case .advanced:
                selectedProteinIntake = .veryHigh
            }
            interactor.trackEvent(event: Event.proteinIntakePrefilled(
                intake: selectedProteinIntake ?? .moderate,
                reason: "training_difficulty_\(difficulty.rawValue)"
            ))
        }
    }

    func navigate(path: Binding<[OnboardingPathOption]>, dietPlanBuilder: DietPlanBuilder) {
        if let proteinIntake = selectedProteinIntake {
            var builder = dietPlanBuilder
            builder.setProteinIntake(proteinIntake)
            interactor.trackEvent(event: Event.navigate(destination: .dietPlan(dietPlanBuilder: builder)))
            path.wrappedValue.append(.dietPlan(dietPlanBuilder: builder))
        }
    }

    enum Event: LoggableEvent {
        case trainingContextLoaded(difficulty: DifficultyLevel?)
        case proteinIntakePrefilled(intake: ProteinIntake, reason: String)
        case navigate(destination: OnboardingPathOption)

        var eventName: String {
            switch self {
            case .trainingContextLoaded: return "Onboarding_ProteinIntake_TrainingContextLoaded"
            case .proteinIntakePrefilled: return "Onboarding_ProteinIntake_Prefilled"
            case .navigate: return "Onboarding_ProteinIntake_Navigate"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .trainingContextLoaded(difficulty: let difficulty):
                return ["difficulty": difficulty?.rawValue as Any]
            case .proteinIntakePrefilled(intake: let intake, reason: let reason):
                return ["intake": intake.rawValue, "reason": reason]
            case .navigate(destination: let destination):
                return destination.eventParameters
            }
        }
        
        var type: LogType {
            switch self {
            case .navigate, .trainingContextLoaded, .proteinIntakePrefilled:
                return .info
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
