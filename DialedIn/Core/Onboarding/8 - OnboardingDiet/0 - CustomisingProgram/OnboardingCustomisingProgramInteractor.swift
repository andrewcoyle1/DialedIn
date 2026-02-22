//
//  OnboardingCustomisingProgramInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingCustomisingProgramInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
}

extension CoreInteractor: OnboardingCustomisingProgramInteractor { }
