//
//  OnboardingWelcomeViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Foundation

protocol OnboardingWelcomeInteractor {
    
}

extension CoreInteractor: OnboardingWelcomeInteractor { }

@Observable
@MainActor
class OnboardingWelcomeViewModel {
    private let interactor: OnboardingWelcomeInteractor
    
    var imageName: String = Constants.randomImage
    var showSignInView: Bool = false

    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(
        interactor: OnboardingWelcomeInteractor
    ) {
        self.interactor = interactor
    }
}
