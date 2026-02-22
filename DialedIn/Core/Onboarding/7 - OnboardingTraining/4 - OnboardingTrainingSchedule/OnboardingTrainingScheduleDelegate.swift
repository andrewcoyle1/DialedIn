//
//  OnboardingTrainingScheduleDelegate.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

struct OnboardingTrainingScheduleDelegate {
    
    let trainingExperience: TrainingExperience
    let selectedDays: Int
    let trainingSplitType: TrainingSplitType
    
    init(delegate: OnboardingTrainingSplitDelegate, trainingSplitType: TrainingSplitType) {
        self.trainingExperience = delegate.trainingExperience
        self.selectedDays = delegate.selectedDays
        self.trainingSplitType = trainingSplitType
    }
    
    static var mock: Self {
        Self(delegate: .mock, trainingSplitType: .ppl)
    }
}
