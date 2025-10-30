//
//  OnboardingPathOption.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/12/24.
//

import Foundation

enum OnboardingPathOption: Hashable, Sendable {
    
    // MARK: Auth
    case authOptions
    case signIn
    case signUp
    case emailVerification
    
    // MARK: Subscription
    case subscriptionInfo
    case subscriptionPlan
    
    // MARK: Complete Account Setup
    case completeAccount
    case healthData
    case notifications
    case namePhoto
    case gender
    case dateOfBirth(
        gender: Gender
    )
    case height(
        gender: Gender,
        dateOfBirth: Date
    )
    case weight(
        gender: Gender,
        dateOfBirth: Date,
        height: Double,
        lengthUnitPreference: LengthUnitPreference
    )
    case exerciseFrequency(
        gender: Gender,
        dateOfBirth: Date,
        height: Double,
        weight: Double,
        lengthUnitPreference: LengthUnitPreference,
        weightUnitPreference: WeightUnitPreference
    )
    case activityLevel(
        gender: Gender,
        dateOfBirth: Date,
        height: Double,
        weight: Double,
        exerciseFrequency: ExerciseFrequency,
        lengthUnitPreference: LengthUnitPreference,
        weightUnitPreference: WeightUnitPreference
    )
    case cardioFitness(
        gender: Gender,
        dateOfBirth: Date,
        height: Double,
        weight: Double,
        exerciseFrequency: ExerciseFrequency,
        activityLevel: ActivityLevel,
        lengthUnitPreference: LengthUnitPreference,
        weightUnitPreference: WeightUnitPreference
    )
    case expenditure(
        gender: Gender,
        dateOfBirth: Date,
        height: Double,
        weight: Double,
        exerciseFrequency: ExerciseFrequency,
        activityLevel: ActivityLevel,
        lengthUnitPreference: LengthUnitPreference,
        weightUnitPreference: WeightUnitPreference,
        selectedCardioFitness: CardioFitnessLevel
    )
    case healthDisclaimer
    
    // MARK: Goal Setting
    case goalSetting
    case overarchingObjective
    case targetWeight(
        objective: OverarchingObjective
    )
    case weightRate(
        objective: OverarchingObjective,
        targetWeight: Double
    )
    case goalSummary(
        objective: OverarchingObjective,
        targetWeight: Double,
        weightRate: Double
    )
    
    // MARK: Customise Program
    case customiseProgram
    case preferredDiet
    case calorieFloor(
        preferredDiet: PreferredDiet
    )
    case trainingType(
        preferredDiet: PreferredDiet,
        calorieFloor: CalorieFloor
    )
    case calorieDistribution(
        preferredDiet: PreferredDiet,
        calorieFloor: CalorieFloor,
        trainingType: TrainingType
    )
    case proteinIntake(
        preferredDiet: PreferredDiet,
        calorieFloor: CalorieFloor,
        trainingType: TrainingType,
        calorieDistribution: CalorieDistribution
    )
    case dietPlan
}
