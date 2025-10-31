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
    case dateOfBirth
    case height
    case weight
    case exerciseFrequency
    case activityLevel
    case cardioFitness
    case expenditure
    case healthDisclaimer
    
    // MARK: Goal Setting
    case goalSetting
    case overarchingObjective
    case targetWeight
    case weightRate
    case goalSummary
    
    // MARK: Customise Program
    case customiseProgram
    case preferredDiet
    case calorieFloor
    case trainingType
    case calorieDistribution
    case proteinIntake
    case dietPlan
}
