//
//  OnboardingIntroViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Foundation

protocol OnboardingIntroInteractor {
    
}

extension CoreInteractor: OnboardingIntroInteractor { }

@Observable
@MainActor
class OnboardingIntroViewModel {
    private let interactor: OnboardingIntroInteractor
    
#if DEBUG || MOCK
    var showDebugView: Bool = false
#endif
    
    init(
        interactor: OnboardingIntroInteractor
    ) {
        self.interactor = interactor
    }
}
