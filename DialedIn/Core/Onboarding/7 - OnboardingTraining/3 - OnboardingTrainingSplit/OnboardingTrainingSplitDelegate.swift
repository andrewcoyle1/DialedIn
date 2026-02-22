//
//  OnboardingTrainingSplitDelegate.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

struct OnboardingTrainingSplitDelegate {
    
    let trainingExperience: TrainingExperience
    let selectedDays: Int
    
    init(delegate: OnboardingTrainingDaysPerWeekDelegate, selectedDays: Int) {
        self.trainingExperience = delegate.trainingExperience
        self.selectedDays = selectedDays
    }
    
    static var mock: Self {
        Self(delegate: .mock, selectedDays: 3)
    }
}
