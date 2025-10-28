//
//  OnboardingSubscriptionViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Foundation

protocol OnboardingSubscriptionInteractor {
    
}

extension CoreInteractor: OnboardingSubscriptionInteractor { }

@Observable
@MainActor
class OnboardingSubscriptionViewModel {
    private let interactor: OnboardingSubscriptionInteractor
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(
        interactor: OnboardingSubscriptionInteractor
    ) {
        self.interactor = interactor
    }
}
