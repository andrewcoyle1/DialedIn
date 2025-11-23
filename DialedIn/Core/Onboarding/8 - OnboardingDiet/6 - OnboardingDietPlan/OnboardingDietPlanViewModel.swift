//
//  OnboardingDietPlanViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingDietPlanInteractor {
    var currentUser: UserModel? { get }
    var currentTrainingPlan: TrainingPlan? { get }
    func computeDietPlan(user: UserModel?, builder: DietPlanBuilder) -> DietPlan
    func saveDietPlan(plan: DietPlan) async throws
    func updateOnboardingStep(step: OnboardingStep) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingDietPlanInteractor { }

@MainActor
protocol OnboardingDietPlanRouter {
    func showDevSettingsView()
    func showOnboardingCompletedView()
}

extension CoreRouter: OnboardingDietPlanRouter { }

@Observable
@MainActor
class OnboardingDietPlanViewModel {
    private let interactor: OnboardingDietPlanInteractor
    private let router: OnboardingDietPlanRouter

    private(set) var plan: DietPlan?
    var trainingProgramName: String?
    var trainingDaysPerWeek: Int?

    var showAlert: AnyAppAlert?
    var isLoading: Bool = false
    
    init(
        interactor: OnboardingDietPlanInteractor,
        router: OnboardingDietPlanRouter
    ) {
        self.interactor = interactor
        self.router = router
        loadTrainingContext()
    }
    
    private func loadTrainingContext() {
        if let plan = interactor.currentTrainingPlan {
            trainingProgramName = plan.name
            // Calculate days per week from first week's scheduled workouts
            if let firstWeek = plan.weeks.first {
                trainingDaysPerWeek = firstWeek.scheduledWorkouts.count
            }
        }
    }

    var currentUser: UserModel? {
        interactor.currentUser
    }

    func createPlan(dietPlanBuilder: DietPlanBuilder) {
        plan = interactor.computeDietPlan(user: currentUser, builder: dietPlanBuilder)
    }
    
    func navigate() {
        guard let plan = plan else { return }
        isLoading = true
        Task {
            interactor.trackEvent(event: Event.saveDietPlanStart)
            do {
                try await interactor.saveDietPlan(plan: plan)
                interactor.trackEvent(event: Event.saveDietPlanSuccess)
                try? await interactor.updateOnboardingStep(step: .complete)
                interactor.trackEvent(event: Event.navigate)
                router.showOnboardingCompletedView()
            } catch {
                showAlert = AnyAppAlert(title: "Unable to update your profile", subtitle: "Please check your internet connection and try again")
                interactor.trackEvent(event: Event.saveDietPlanFail(error: error))
            }
            isLoading = false
        }
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case saveDietPlanStart
        case saveDietPlanSuccess
        case saveDietPlanFail(error: Error)
        case navigate

        var eventName: String {
            switch self {
            case .saveDietPlanStart:            return "DietView_SaveDietPlan_Start"
            case .saveDietPlanSuccess:          return "DietView_SaveDietPlan_Success"
            case .saveDietPlanFail:             return "DietView_SaveDietPlan_Fail"
            case .navigate:                     return "DietView_Navigate"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .saveDietPlanFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .saveDietPlanFail:
                return .severe
            case .navigate:
                return .info
            default:
                return .analytic
                
            }
        }
    }
}
