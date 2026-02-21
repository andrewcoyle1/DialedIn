//
//  OnboardingExerciseFrequencyInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingExerciseFrequencyInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingExerciseFrequencyInteractor { }
