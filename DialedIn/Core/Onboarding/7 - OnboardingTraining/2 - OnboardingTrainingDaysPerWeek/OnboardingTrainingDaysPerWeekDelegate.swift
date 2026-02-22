//
//  OnboardingTrainingDaysPerWeekDelegate.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

struct OnboardingTrainingDaysPerWeekDelegate {
    
    let trainingExperience: TrainingExperience
    
    init(delegate: OnboardingTrainingExperienceDelegate, trainingExperience: TrainingExperience) {
        self.trainingExperience = trainingExperience
        
    }
    
    static var mock: Self {
        Self(delegate: .mock, trainingExperience: .beginner)
    }
}
