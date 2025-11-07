//
//  OnboardingPathOption.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/12/24.
//

import Foundation

enum OnboardingPathOption: Hashable, Sendable {

    // MARK: Intro
    case intro

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
    case dateOfBirth(userModelBuilder: UserModelBuilder)
    case height(userModelBuilder: UserModelBuilder)
    case weight(userModelBuilder: UserModelBuilder)
    case exerciseFrequency(userModelBuilder: UserModelBuilder)
    case activityLevel(userModelBuilder: UserModelBuilder)
    case cardioFitness(userModelBuilder: UserModelBuilder)
    case expenditure(userModelBuilder: UserModelBuilder)
    case healthDisclaimer
    
    // MARK: Goal Setting
    case goalSetting
    case overarchingObjective
    case targetWeight(weightGoalBuilder: WeightGoalBuilder)
    case weightRate(weightGoalBuilder: WeightGoalBuilder)
    case goalSummary(weightGoalBuilder: WeightGoalBuilder)
    
    // MARK: Customise Program
    case customiseProgram
    case trainingExperience(trainingProgramBuilder: TrainingProgramBuilder)
    case trainingDaysPerWeek(trainingProgramBuilder: TrainingProgramBuilder)
    case trainingSplit(trainingProgramBuilder: TrainingProgramBuilder)
    case trainingSchedule(trainingProgramBuilder: TrainingProgramBuilder)
    case trainingEquipment(trainingProgramBuilder: TrainingProgramBuilder)
    case trainingReview(trainingProgramBuilder: TrainingProgramBuilder)
    case preferredDiet
    case calorieFloor(dietPlanBuilder: DietPlanBuilder)
    case trainingType(dietPlanBuilder: DietPlanBuilder)
    case calorieDistribution(dietPlanBuilder: DietPlanBuilder)
    case proteinIntake(dietPlanBuilder: DietPlanBuilder)
    case dietPlan(dietPlanBuilder: DietPlanBuilder)

    // MARK: Onboarding Complete
    case complete

    var description: String {
        switch self {

            // MARK: Intro
        case .intro:                return "Intro"

            // MARK: Auth
        case .authOptions:          return "AuthOptions"
        case .signIn:               return "SignIn"
        case .signUp:               return "SignUp"
        case .emailVerification:    return "EmailVerification"

            // MARK: Subscription
        case .subscriptionInfo:     return "SubscriptionInfo"
        case .subscriptionPlan:     return "SubscriptionPlan"

            // MARK: Complete Account Setup
        case .completeAccount:      return "CompleteAccount"
        case .namePhoto:            return "NamePhoto"
        case .gender:               return "Gender"
        case .dateOfBirth:          return "DateOfBirth"
        case .height:               return "Height"
        case .weight:               return "Weight"
        case .exerciseFrequency:    return "ExerciseFrequency"
        case .activityLevel:        return "ActivityLevel"
        case .cardioFitness:        return "CardioFitnessLevel"
        case .expenditure:          return "Expenditure"
        case .notifications:        return "Notifications"
        case .healthData:           return "HealthData"
        case .healthDisclaimer:     return "HealthDisclaimer"

            // MARK: Goal Setting
        case .goalSetting:          return "GoalSetting"
        case .overarchingObjective: return "OverarchingObjective"
        case .targetWeight:         return "TargetWeight"
        case .weightRate:           return "WeightRate"
        case .goalSummary:          return "GoalSummary"

            // MARK: Customise Program
        case .customiseProgram:     return "CustomiseProgram"
        case .trainingExperience:    return "TrainingExperience"
        case .trainingDaysPerWeek:  return "TrainingDaysPerWeek"
        case .trainingSplit:        return "TrainingSplit"
        case .trainingSchedule:     return "TrainingSchedule"
        case .trainingEquipment:    return "TrainingEquipment"
        case .trainingReview:       return "TrainingReview"
        case .preferredDiet:        return "PreferredDiet"
        case .calorieFloor:         return "CalorieFloor"
        case .trainingType:         return "TrainingType"
        case .calorieDistribution:  return "CalorieDistribution"
        case .proteinIntake:        return "ProteinIntake"
        case .dietPlan:             return "DietPlan"

            // MARK: Onboarding Complete
        case .complete:             return "Complete"
        }
    }

    var eventParameters: [String: Any] {
        let params: [String: Any] = [
            "destination": self
        ]

        return params
    }

    var onboardingStep: OnboardingStep {
        switch self {
        case .intro:                return .auth
        case .authOptions:          return .auth
        case .signIn:               return .auth
        case .signUp:               return .auth
        case .emailVerification:    return .auth

            // MARK: Subscription
        case .subscriptionInfo:     return .subscription
        case .subscriptionPlan:     return .subscription

            // MARK: Complete Account Setup
        case .completeAccount:      return .completeAccountSetup
        case .namePhoto:            return .completeAccountSetup
        case .gender:               return .completeAccountSetup
        case .dateOfBirth:          return .completeAccountSetup
        case .height:               return .completeAccountSetup
        case .weight:               return .completeAccountSetup
        case .exerciseFrequency:    return .completeAccountSetup
        case .activityLevel:        return .completeAccountSetup
        case .cardioFitness:        return .completeAccountSetup
        case .expenditure:          return .completeAccountSetup
        case .healthData:           return .completeAccountSetup
        case .notifications:        return .completeAccountSetup
        case .healthDisclaimer:     return .healthDisclaimer

            // MARK: Goal Setting
        case .goalSetting:          return .goalSetting
        case .overarchingObjective: return .goalSetting
        case .targetWeight:         return .goalSetting
        case .weightRate:           return .goalSetting
        case .goalSummary:          return .goalSetting

            // MARK: Customise Program
        case .customiseProgram:     return .customiseProgram
        case .trainingExperience:   return .customiseProgram
        case .trainingDaysPerWeek:   return .customiseProgram
        case .trainingSplit:        return .customiseProgram
        case .trainingSchedule:      return .customiseProgram
        case .trainingEquipment:    return .customiseProgram
        case .trainingReview:       return .customiseProgram
        case .preferredDiet:        return .customiseProgram
        case .calorieFloor:         return .customiseProgram
        case .trainingType:         return .customiseProgram
        case .calorieDistribution:  return .customiseProgram
        case .proteinIntake:        return .customiseProgram
        case .dietPlan:             return .customiseProgram

            // MARK: Complete Onboarding
        case .complete:             return .complete
        }
    }
}
