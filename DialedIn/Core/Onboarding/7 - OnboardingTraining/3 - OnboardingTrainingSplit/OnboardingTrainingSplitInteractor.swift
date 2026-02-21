//
//  OnboardingTrainingSplitInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingTrainingSplitInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingTrainingSplitInteractor { }
