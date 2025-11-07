//
//  UserModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/9/24.
//
import Foundation
import SwiftUI

struct UserModel: Codable, Equatable, Sendable {
    
    // User
    let userId: String
    
    // Auth
    let email: String?
    let isAnonymous: Bool?
    
    // Profile
    private(set) var firstName: String?
    private(set) var lastName: String?
    
    // Profile
    private(set) var dateOfBirth: Date?
    private(set) var gender: Gender?
    
    // Mandatory onboarding profile metrics
    private(set) var heightCentimeters: Double?
    private(set) var weightKilograms: Double?
    private(set) var exerciseFrequency: ProfileExerciseFrequency?
    private(set) var dailyActivityLevel: ProfileDailyActivityLevel?
    private(set) var cardioFitnessLevel: ProfileCardioFitnessLevel?
    
    // Preferences
    private(set) var lengthUnitPreference: LengthUnitPreference?
    private(set) var weightUnitPreference: WeightUnitPreference?
    
    // Goals
    private(set) var currentGoalId: String?
    
    // Profile
    private(set) var profileImageUrl: String?
    
    // Creation
    let creationDate: Date?
    let creationVersion: String?
    
    // Sign In
    let lastSignInDate: Date?
    
    // Onboarding
    let didCompleteOnboarding: Bool?
    let onboardingStep: OnboardingStep
    
    // Exercise Templates
    let createdExerciseTemplateIds: [String]?
    let bookmarkedExerciseTemplateIds: [String]?
    let favouritedExerciseTemplateIds: [String]?
    
    // Workout Templates
    let createdWorkoutTemplateIds: [String]?
    let bookmarkedWorkoutTemplateIds: [String]?
    let favouritedWorkoutTemplateIds: [String]?
    
    // Ingredient Templates
    let createdIngredientTemplateIds: [String]?
    let bookmarkedIngredientTemplateIds: [String]?
    let favouritedIngredientTemplateIds: [String]?
    
    // Recipe Templates
    let createdRecipeTemplateIds: [String]?
    let bookmarkedRecipeTemplateIds: [String]?
    let favouritedRecipeTemplateIds: [String]?
    
    // Blocked Users
    let blockedUserIds: [String]?
    
    init(
        userId: String,
        email: String? = nil,
        isAnonymous: Bool? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        dateOfBirth: Date? = nil,
        gender: Gender? = nil,
        heightCentimeters: Double? = nil,
        weightKilograms: Double? = nil,
        exerciseFrequency: ProfileExerciseFrequency? = nil,
        dailyActivityLevel: ProfileDailyActivityLevel? = nil,
        cardioFitnessLevel: ProfileCardioFitnessLevel? = nil,
        lengthUnitPreference: LengthUnitPreference? = nil,
        weightUnitPreference: WeightUnitPreference? = nil,
        currentGoalId: String? = nil,
        profileImageUrl: String? = nil,
        creationDate: Date? = nil,
        creationVersion: String? = nil,
        lastSignInDate: Date? = nil,
        didCompleteOnboarding: Bool? = nil,
        onboardingStep: OnboardingStep = .auth,
        createdExerciseTemplateIds: [String]? = nil,
        bookmarkedExerciseTemplateIds: [String]? = nil,
        favouritedExerciseTemplateIds: [String]? = nil,
        createdWorkoutTemplateIds: [String]? = nil,
        bookmarkedWorkoutTemplateIds: [String]? = nil,
        favouritedWorkoutTemplateIds: [String]? = nil,
        createdIngredientTemplateIds: [String]? = nil,
        bookmarkedIngredientTemplateIds: [String]? = nil,
        favouritedIngredientTemplateIds: [String]? = nil,
        createdRecipeTemplateIds: [String]? = nil,
        bookmarkedRecipeTemplateIds: [String]? = nil,
        favouritedRecipeTemplateIds: [String]? = nil,
        blockedUserIds: [String]? = nil
    ) {
        self.userId = userId
        self.email = email
        self.isAnonymous = isAnonymous
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.heightCentimeters = heightCentimeters
        self.weightKilograms = weightKilograms
        self.exerciseFrequency = exerciseFrequency
        self.dailyActivityLevel = dailyActivityLevel
        self.cardioFitnessLevel = cardioFitnessLevel
        self.lengthUnitPreference = lengthUnitPreference
        self.weightUnitPreference = weightUnitPreference
        self.currentGoalId = currentGoalId
        self.profileImageUrl = profileImageUrl
        self.creationDate = creationDate
        self.creationVersion = creationVersion
        self.lastSignInDate = lastSignInDate
        self.didCompleteOnboarding = didCompleteOnboarding
        self.onboardingStep = onboardingStep
        self.createdExerciseTemplateIds = createdExerciseTemplateIds
        self.bookmarkedExerciseTemplateIds = bookmarkedExerciseTemplateIds
        self.favouritedExerciseTemplateIds = favouritedExerciseTemplateIds
        self.createdWorkoutTemplateIds = createdWorkoutTemplateIds
        self.bookmarkedWorkoutTemplateIds = bookmarkedWorkoutTemplateIds
        self.favouritedWorkoutTemplateIds = favouritedWorkoutTemplateIds
        self.createdIngredientTemplateIds = createdIngredientTemplateIds
        self.bookmarkedIngredientTemplateIds = bookmarkedIngredientTemplateIds
        self.favouritedIngredientTemplateIds = favouritedIngredientTemplateIds
        self.createdRecipeTemplateIds = createdRecipeTemplateIds
        self.bookmarkedRecipeTemplateIds = bookmarkedRecipeTemplateIds
        self.favouritedRecipeTemplateIds = favouritedRecipeTemplateIds
        self.blockedUserIds = blockedUserIds
    }
    
    init(auth: UserAuthInfo, creationVersion: String?) {
        self.init(
            userId: auth.uid,
            email: auth.email,
            isAnonymous: auth.isAnonymous,
            creationDate: auth.creationDate,
            creationVersion: creationVersion,
            lastSignInDate: auth.lastSignInDate
        )
    }
    
    mutating func updateNameAndImageURL(firstName: String, lastName: String?, imageUrl: String?) {
        self.firstName = firstName
        self.lastName = lastName
        self.profileImageUrl = imageUrl
    }
    
    mutating func updateDateOfBirth(_ dateOfBirth: Date) {
        self.dateOfBirth = dateOfBirth
    }
    
    mutating func updateGender(_ gender: Gender) {
        self.gender = gender
    }
    
    mutating func updateHeight(_ height: Double, lengthUnitPreference: LengthUnitPreference) {
        self.heightCentimeters = height
        self.lengthUnitPreference = lengthUnitPreference
    }
    
    mutating func updateWeight(_ weight: Double, weightUnitPreference: WeightUnitPreference) {
        self.weightKilograms = weight
        self.weightUnitPreference = weightUnitPreference
    }
    
    mutating func updateExerciseFrequency(_ exerciseFrequency: ProfileExerciseFrequency) {
        self.exerciseFrequency = exerciseFrequency
    }
    
    mutating func updateActivityLevel(_ activityLevel: ProfileDailyActivityLevel) {
        self.dailyActivityLevel = activityLevel
    }
    
    mutating func updateCardioFitness(_ level: ProfileCardioFitnessLevel) {
        self.cardioFitnessLevel = level
    }
    
    mutating func updateImageURL(imageUrl: String) {
        self.profileImageUrl = imageUrl
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case isAnonymous = "is_anonymous"
        case firstName = "first_name"
        case lastName = "last_name"
        case dateOfBirth = "date_of_birth"
        case gender
        case heightCentimeters = "height_cm"
        case weightKilograms = "weight_kg"
        case exerciseFrequency = "exercise_frequency"
        case dailyActivityLevel = "daily_activity_level"
        case cardioFitnessLevel = "cardio_fitness_level"
        case lengthUnitPreference = "length_unit_preference"
        case weightUnitPreference = "weight_unit_preference"
        case currentGoalId = "current_goal_id"
        case profileImageUrl = "profile_image_url"
        case creationDate = "creation_date"
        case creationVersion = "creation_version"
        case lastSignInDate = "last_sign_in_date"
        case didCompleteOnboarding = "did_complete_onboarding"
        case onboardingStep = "onboarding_step"
        case createdExerciseTemplateIds = "created_exercise_template_ids"
        case bookmarkedExerciseTemplateIds = "bookmarked_exercise_template_ids"
        case favouritedExerciseTemplateIds = "favourited_exercise_template_ids"
        case createdWorkoutTemplateIds = "created_workout_template_ids"
        case bookmarkedWorkoutTemplateIds = "bookmarked_workout_template_ids"
        case favouritedWorkoutTemplateIds = "favourited_workout_template_ids"
        case createdIngredientTemplateIds = "created_ingredient_template_ids"
        case bookmarkedIngredientTemplateIds = "bookmarked_ingredient_template_ids"
        case favouritedIngredientTemplateIds = "favourited_ingredient_template_ids"
        case createdRecipeTemplateIds = "created_recipe_template_ids"
        case bookmarkedRecipeTemplateIds = "bookmarked_recipe_template_ids"
        case favouritedRecipeTemplateIds = "favourited_recipe_template_ids"
        case blockedUserIds = "blocked_user_ids"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "user_\(CodingKeys.userId.rawValue)": userId,
            "user_\(CodingKeys.email.rawValue)": email,
            "user_\(CodingKeys.firstName.rawValue)": firstName,
            "user_\(CodingKeys.lastName.rawValue)": lastName,
            "user_\(CodingKeys.dateOfBirth.rawValue)": dateOfBirth,
            "user_\(CodingKeys.gender.rawValue)": gender?.description,
            "user_\(CodingKeys.heightCentimeters.rawValue)": heightCentimeters,
            "user_\(CodingKeys.weightKilograms.rawValue)": weightKilograms,
            "user_\(CodingKeys.exerciseFrequency.rawValue)": exerciseFrequency?.rawValue,
            "user_\(CodingKeys.dailyActivityLevel.rawValue)": dailyActivityLevel?.rawValue,
            "user_\(CodingKeys.cardioFitnessLevel.rawValue)": cardioFitnessLevel?.rawValue,
            "user_\(CodingKeys.lengthUnitPreference.rawValue)": lengthUnitPreference?.rawValue,
            "user_\(CodingKeys.weightUnitPreference.rawValue)": weightUnitPreference?.rawValue,
            "user_\(CodingKeys.currentGoalId.rawValue)": currentGoalId,
            "user_\(CodingKeys.isAnonymous.rawValue)": isAnonymous,
            "user_\(CodingKeys.creationDate.rawValue)": creationDate,
            "user_\(CodingKeys.creationVersion.rawValue)": creationVersion,
            "user_\(CodingKeys.lastSignInDate.rawValue)": lastSignInDate,
            "user_\(CodingKeys.didCompleteOnboarding.rawValue)": didCompleteOnboarding,
            "user_\(CodingKeys.onboardingStep.rawValue)": onboardingStep.rawValue,
            "user_\(CodingKeys.profileImageUrl.rawValue)": profileImageUrl,
            "user_\(CodingKeys.createdExerciseTemplateIds.rawValue)": createdExerciseTemplateIds,
            "user_\(CodingKeys.bookmarkedExerciseTemplateIds.rawValue)": bookmarkedExerciseTemplateIds,
            "user_\(CodingKeys.favouritedExerciseTemplateIds.rawValue)": favouritedExerciseTemplateIds,
            "user_\(CodingKeys.createdWorkoutTemplateIds.rawValue)": createdWorkoutTemplateIds,
            "user_\(CodingKeys.bookmarkedWorkoutTemplateIds.rawValue)": bookmarkedWorkoutTemplateIds,
            "user_\(CodingKeys.favouritedWorkoutTemplateIds.rawValue)": favouritedWorkoutTemplateIds,
            "user_\(CodingKeys.createdIngredientTemplateIds.rawValue)": createdIngredientTemplateIds,
            "user_\(CodingKeys.bookmarkedIngredientTemplateIds.rawValue)": bookmarkedIngredientTemplateIds,
            "user_\(CodingKeys.favouritedIngredientTemplateIds.rawValue)": favouritedIngredientTemplateIds,
            "user_\(CodingKeys.createdRecipeTemplateIds.rawValue)": createdRecipeTemplateIds,
            "user_\(CodingKeys.bookmarkedRecipeTemplateIds.rawValue)": bookmarkedRecipeTemplateIds,
            "user_\(CodingKeys.favouritedRecipeTemplateIds.rawValue)": favouritedRecipeTemplateIds,
            "user_\(CodingKeys.blockedUserIds.rawValue)": blockedUserIds
        ]
        return dict.compactMapValues({ $0 })
    }
    
    static var mock: Self {
        mocks[0]
    }
    
    static func mockWithStep(_ step: OnboardingStep) -> Self {
        let now = Date()
        return UserModel(
            userId: "mockUser",
            email: "mock@example.com",
            isAnonymous: false,
            firstName: "Mock",
            lastName: "User",
            dateOfBirth: Calendar.current.date(from: DateComponents(year: 1990, month: 1, day: 1)),
            gender: .male,
            heightCentimeters: 175.0,
            weightKilograms: 70.0,
            exerciseFrequency: .fiveToSix,
            dailyActivityLevel: .active,
            cardioFitnessLevel: .intermediate,
            creationDate: now,
            creationVersion: "1.0.0",
            lastSignInDate: now,
            didCompleteOnboarding: step == .complete,
            onboardingStep: step
        )
    }

    static var mocks: [Self] {
        let now = Date()
        return [
            UserModel(
                userId: "user1",
                email: "user1@example.com",
                isAnonymous: false,
                firstName: "Alice",
                lastName: "Cooper",
                dateOfBirth: Calendar.current.date(from: DateComponents(year: 2000, month: 11, day: 13)),
                gender: .male,
                heightCentimeters: 175.0,
                weightKilograms: 70.0,
                exerciseFrequency: .daily,
                dailyActivityLevel: .active,
                cardioFitnessLevel: .intermediate,
                creationDate: now,
                creationVersion: "1.0.0",
                lastSignInDate: now,
                didCompleteOnboarding: true,
                onboardingStep: .complete,
                createdExerciseTemplateIds: ["exercise1", "exercise2"],
                bookmarkedExerciseTemplateIds: ["exercise3", "exercise4"],
                favouritedExerciseTemplateIds: ["exercise5", "exercise6"],
                createdWorkoutTemplateIds: ["workout1", "workout2"],
                bookmarkedWorkoutTemplateIds: ["workout3", "workout4"],
                favouritedWorkoutTemplateIds: ["workout5", "workout6"],
                createdIngredientTemplateIds: ["ingredient1", "ingredient2"],
                bookmarkedIngredientTemplateIds: ["ingredient3", "ingredient4"],
                favouritedIngredientTemplateIds: ["ingredient5", "ingredient6"],
                createdRecipeTemplateIds: ["recipe1", "recipe2"],
                bookmarkedRecipeTemplateIds: ["recipe3", "recipe4"],
                favouritedRecipeTemplateIds: ["recipe5", "recipe6"],
                blockedUserIds: ["user2", "user3"]
            ),
            UserModel(
                userId: "user2",
                email: "user2@example.com",
                isAnonymous: false,
                firstName: "Bob",
                creationDate: now.addingTimeInterval(-86400),
                creationVersion: "1.0.0",
                lastSignInDate: now.addingTimeInterval(-3600),
                didCompleteOnboarding: false,
                onboardingStep: .subscription,
                createdExerciseTemplateIds: ["exercise1", "exercise2"],
                bookmarkedExerciseTemplateIds: ["exercise3", "exercise4"],
                favouritedExerciseTemplateIds: ["exercise5", "exercise6"],
                createdWorkoutTemplateIds: ["workout1", "workout2"],
                bookmarkedWorkoutTemplateIds: ["workout3", "workout4"],
                favouritedWorkoutTemplateIds: ["workout5", "workout6"],
                createdIngredientTemplateIds: ["ingredient1", "ingredient2"],
                bookmarkedIngredientTemplateIds: ["ingredient3", "ingredient4"],
                favouritedIngredientTemplateIds: ["ingredient5", "ingredient6"],
                createdRecipeTemplateIds: ["recipe1", "recipe2"],
                bookmarkedRecipeTemplateIds: ["recipe3", "recipe4"],
                favouritedRecipeTemplateIds: ["recipe5", "recipe6"],
                blockedUserIds: ["user1", "user3"]
            ),
            UserModel(
                userId: "user3",
                email: "user3@example.com",
                isAnonymous: false,
                firstName: "Charlie",
                creationDate: now.addingTimeInterval(-3 * 86400 - 2 * 3600),
                creationVersion: "1.0.0",
                lastSignInDate: now.addingTimeInterval(-2 * 3600),
                didCompleteOnboarding: true,
                onboardingStep: .completeAccountSetup,
                createdExerciseTemplateIds: ["exercise1", "exercise2"],
                bookmarkedExerciseTemplateIds: ["exercise3", "exercise4"],
                favouritedExerciseTemplateIds: ["exercise5", "exercise6"],
                createdWorkoutTemplateIds: ["workout1", "workout2"],
                bookmarkedWorkoutTemplateIds: ["workout3", "workout4"],
                favouritedWorkoutTemplateIds: ["workout5", "workout6"],
                createdIngredientTemplateIds: ["ingredient1", "ingredient2"],
                bookmarkedIngredientTemplateIds: ["ingredient3", "ingredient4"],
                favouritedIngredientTemplateIds: ["ingredient5", "ingredient6"],
                createdRecipeTemplateIds: ["recipe1", "recipe2"],
                bookmarkedRecipeTemplateIds: ["recipe3", "recipe4"],
                favouritedRecipeTemplateIds: ["recipe5", "recipe6"],
                blockedUserIds: ["user1", "user2"]
            ),
            UserModel(
                userId: "user5",
                email: "user5@example.com",
                isAnonymous: true,
                firstName: "Andrew",
                creationDate: now.addingTimeInterval(-5 * 86400 - 4 * 3600),
                creationVersion: "1.0.0",
                lastSignInDate: now.addingTimeInterval(-4 * 3600),
                didCompleteOnboarding: nil,
                onboardingStep: .goalSetting,
                createdExerciseTemplateIds: ["exercise1", "exercise2"],
                bookmarkedExerciseTemplateIds: ["exercise3", "exercise4"],
                favouritedExerciseTemplateIds: ["exercise5", "exercise6"],
                createdWorkoutTemplateIds: ["workout1", "workout2"],
                bookmarkedWorkoutTemplateIds: ["workout3", "workout4"],
                favouritedWorkoutTemplateIds: ["workout5", "workout6"],
                createdIngredientTemplateIds: ["ingredient1", "ingredient2"],
                bookmarkedIngredientTemplateIds: ["ingredient3", "ingredient4"],
                favouritedIngredientTemplateIds: ["ingredient5", "ingredient6"],
                createdRecipeTemplateIds: ["recipe1", "recipe2"],
                bookmarkedRecipeTemplateIds: ["recipe3", "recipe4"],
                favouritedRecipeTemplateIds: ["recipe5", "recipe6"],
                blockedUserIds: ["user1", "user2"]
            ),
            UserModel(
                userId: "user6",
                email: "user6@example.com",
                isAnonymous: true,
                firstName: "David",
                creationDate: now.addingTimeInterval(-5 * 86400 - 4 * 3600),
                creationVersion: "1.0.0",
                lastSignInDate: now.addingTimeInterval(-4 * 3600),
                didCompleteOnboarding: nil,
                onboardingStep: .customiseProgram,
                createdExerciseTemplateIds: ["exercise1", "exercise2"],
                bookmarkedExerciseTemplateIds: ["exercise3", "exercise4"],
                favouritedExerciseTemplateIds: ["exercise5", "exercise6"],
                createdWorkoutTemplateIds: ["workout1", "workout2"],
                bookmarkedWorkoutTemplateIds: ["workout3", "workout4"],
                favouritedWorkoutTemplateIds: ["workout5", "workout6"],
                createdIngredientTemplateIds: ["ingredient1", "ingredient2"],
                bookmarkedIngredientTemplateIds: ["ingredient3", "ingredient4"],
                favouritedIngredientTemplateIds: ["ingredient5", "ingredient6"],
                createdRecipeTemplateIds: ["recipe1", "recipe2"],
                bookmarkedRecipeTemplateIds: ["recipe3", "recipe4"],
                favouritedRecipeTemplateIds: ["recipe5", "recipe6"],
                blockedUserIds: ["user1", "user2"]
            )
        ]
    }
}

enum Gender: String, Codable, Sendable {
    case male
    case female
    var description: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        }
    }
}

enum ProfileExerciseFrequency: String, Codable, Sendable {
    case never
    case oneToTwo = "1-2"
    case threeToFour = "3-4"
    case fiveToSix = "5-6"
    case daily
}

enum ProfileDailyActivityLevel: String, Codable, Sendable {
    case sedentary
    case light
    case moderate
    case active
    case veryActive = "very_active"
}

enum ProfileCardioFitnessLevel: String, Codable, Sendable {
    case beginner
    case novice
    case intermediate
    case advanced
    case elite
}

enum LengthUnitPreference: String, Codable, Sendable {
    case centimeters
    case inches
}

enum WeightUnitPreference: String, Codable, Sendable {
    case kilograms
    case pounds
}

enum OnboardingStep: String, Codable, Sendable {
    case auth
    case subscription
    case completeAccountSetup
    case notifications
    case healthData
    case healthDisclaimer
    case goalSetting
    case customiseProgram
    case complete
    
    var onboardingPathOption: OnboardingPathOption {
        switch self {
        case .auth: return .authOptions
        case .subscription: return .subscriptionInfo
        case .completeAccountSetup: return .completeAccount
        case .notifications: return .notifications
        case .healthData: return .healthData
        case .healthDisclaimer: return .healthDisclaimer
        case .goalSetting: return .goalSetting
        case .customiseProgram: return .customiseProgram
        case .complete: return .complete
        }
    }

    var eventParameters: [String: Any] {
        let params: [String: Any] = [
            "onboarding_step": self
        ]

        return params
    }
}

extension OnboardingStep {
    var orderIndex: Int {
        switch self {
        case .auth: return 0
        case .subscription: return 1
        case .completeAccountSetup: return 2
        case .notifications: return 3
        case .healthData: return 4
        case .healthDisclaimer: return 5
        case .goalSetting: return 6
        case .customiseProgram: return 7
        case .complete: return 8
        }
    }
}
