//
//  OnboardingTrainingReviewDelegate.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

struct OnboardingTrainingReviewDelegate {
    
    let trainingExperience: TrainingExperience
    let selectedDays: Int
    let trainingSplitType: TrainingSplitType
    let scheduledDays: Set<Int>
    let gymProfile: GymProfileModel
    
    init(delegate: OnboardingTrainingEquipmentDelegate, gymProfile: GymProfileModel) {
        self.trainingExperience = delegate.trainingExperience
        self.selectedDays = delegate.selectedDays
        self.trainingSplitType = delegate.trainingSplitType
        self.scheduledDays = delegate.scheduledDays
        self.gymProfile = gymProfile
    }
    
    static var mock: Self {
        Self(delegate: .mock, gymProfile: GymProfileModel.mock)
    }
}
