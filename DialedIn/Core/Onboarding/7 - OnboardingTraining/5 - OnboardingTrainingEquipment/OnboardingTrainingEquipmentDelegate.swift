//
//  OnboardingTrainingEquipmentDelegate.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

struct OnboardingTrainingEquipmentDelegate {
    
    let trainingExperience: TrainingExperience
    let selectedDays: Int
    let trainingSplitType: TrainingSplitType
    let scheduledDays: Set<Int>
    
    init(delegate: OnboardingTrainingScheduleDelegate, scheduledDays: Set<Int>) {
        self.trainingExperience = delegate.trainingExperience
        self.selectedDays = delegate.selectedDays
        self.trainingSplitType = delegate.trainingSplitType
        self.scheduledDays = scheduledDays
    }
    
    static var mock: Self {
        Self(delegate: .mock, scheduledDays: [0, 1, 2, 3, 4, 5, 6])
    }
}
