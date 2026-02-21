//
//  OnboardingWelcomeInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingWelcomeInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    var onboardingStep: OnboardingStep { get }
}

extension CoreInteractor: OnboardingWelcomeInteractor { }
