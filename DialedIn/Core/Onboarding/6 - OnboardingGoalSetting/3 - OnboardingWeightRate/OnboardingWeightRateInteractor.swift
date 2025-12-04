//
//  OnboardingWeightRateInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingWeightRateInteractor {
    var currentUser: UserModel? { get }
    func trackEvent(event: LoggableEvent)
}

extension OnbInteractor: OnboardingWeightRateInteractor { }
