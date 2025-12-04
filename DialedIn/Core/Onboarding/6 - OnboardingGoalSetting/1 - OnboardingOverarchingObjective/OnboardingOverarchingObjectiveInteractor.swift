//
//  OnboardingOverarchingObjectiveInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingOverarchingObjectiveInteractor {
    var currentUser: UserModel? { get }
    func trackEvent(event: LoggableEvent)
}

extension OnbInteractor: OnboardingOverarchingObjectiveInteractor { }
