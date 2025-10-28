//
//  OnboardingRouterViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Foundation

protocol OnboardingRouterInteractor {
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
}

extension CoreInteractor: OnboardingRouterInteractor { }

@Observable
@MainActor
class OnboardingRouterViewModel {
    private let interactor: OnboardingRouterInteractor
    
    var auth: UserAuthInfo? {
        interactor.auth
    }
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    init(
        interactor: OnboardingRouterInteractor
    ) {
        self.interactor = interactor
    }
}
