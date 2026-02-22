//
//  OnboardingTrainingEquipmentInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingTrainingEquipmentInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
}

extension CoreInteractor: OnboardingTrainingEquipmentInteractor { }
