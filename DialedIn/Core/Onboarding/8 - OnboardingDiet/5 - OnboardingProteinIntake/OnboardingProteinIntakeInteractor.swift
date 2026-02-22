//
//  OnboardingProteinIntakeInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingProteinIntakeInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
}

extension CoreInteractor: OnboardingProteinIntakeInteractor { }
