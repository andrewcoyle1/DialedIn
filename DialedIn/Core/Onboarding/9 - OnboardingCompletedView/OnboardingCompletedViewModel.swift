//
//  OnboardingCompletedViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Foundation

protocol OnboardingCompletedInteractor {
    func updateOnboardingStep(step: OnboardingStep) async throws
}

extension CoreInteractor: OnboardingCompletedInteractor { }

@Observable
@MainActor
class OnboardingCompletedViewModel {
    private let interactor: OnboardingCompletedInteractor
    
    var isCompletingProfileSetup: Bool = false

    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(
        interactor: OnboardingCompletedInteractor
    ) {
        self.interactor = interactor
    }
    
    func onFinishButtonPressed() {
        isCompletingProfileSetup = true
        Task {
            isCompletingProfileSetup = false
            // other logic to complete onboarding
            do {
                try await interactor.updateOnboardingStep(step: .complete)
            } catch {
                // Proceed even if saving goal fails
            }
            // AppView will switch to main automatically once onboardingStep is .complete
        }
    }
}
