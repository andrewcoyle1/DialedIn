//
//  OnboardingTrainingScheduleInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingTrainingScheduleInteractor {
    func trackEvent(event: LoggableEvent)
}

extension OnbInteractor: OnboardingTrainingScheduleInteractor { }
