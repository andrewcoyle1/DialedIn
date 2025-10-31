//
//  OnboardingCompleteAccountSetupViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingCompleteAccountSetupInteractor {
    var currentUser: UserModel? { get }
    func updateOnboardingStep(step: OnboardingStep) async throws
    func canRequestHealthDataAuthorisation() -> Bool
    func canRequestNotificationAuthorisation() async -> Bool
}

extension CoreInteractor: OnboardingCompleteAccountSetupInteractor { }

@Observable
@MainActor
class OnboardingCompleteAccountSetupViewModel {
    private let interactor: OnboardingCompleteAccountSetupInteractor
    
    var canRequestNotificationsAuthorisation: Bool?
    var canRequestHealthDataAuthorisation: Bool?
    var showAlert: AnyAppAlert?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    init(interactor: OnboardingCompleteAccountSetupInteractor) {
        self.interactor = interactor
    }
    
    func setup() async {
        canRequestHealthDataAuthorisation = checkHealthDataAuthorisationStatus()
        await updateOnboardingStep()
    }
    
    func onContinuePressed(path: Binding<[OnboardingPathOption]>) {
        
        path.wrappedValue.append(.namePhoto)
    }
    
    func updateOnboardingStep() async {
        let target: OnboardingStep = .completeAccountSetup
        if let current = interactor.currentUser?.onboardingStep, current.orderIndex >= target.orderIndex {
            return
        }
        do {
            try await interactor.updateOnboardingStep(step: target)
        } catch {
            showAlert = AnyAppAlert(title: "Internet Connection Failed", subtitle: "Please check your internet connection and try again.") {
                AnyView(
                    HStack {
                        Button(role: .close) {
                            
                        }
                        Button {
                            Task {
                                await self.updateOnboardingStep()
                            }
                        } label: {
                            Text("Try again")
                        }
                    }
                )
            }
        }
    }
    
    func checkHealthDataAuthorisationStatus() -> Bool {
        interactor.canRequestHealthDataAuthorisation()
    }
    
    func canRequestNotificationAuthorisation() async -> Bool {
        await interactor.canRequestNotificationAuthorisation()
    }
}
