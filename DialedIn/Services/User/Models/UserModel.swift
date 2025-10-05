//
//  UserModel.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 10/9/24.
//
import Foundation
import SwiftUI

struct UserModel: Codable, Equatable {
    
    // User
    let userId: String

    // Auth
    let email: String?
    let isAnonymous: Bool?
    
    // Profile
    let firstName: String?
    let lastName: String?
    
    // Profile
    let dateOfBirth: Date?
    let gender: Gender?
    // Mandatory onboarding profile metrics
    let heightCentimeters: Double?
    let weightKilograms: Double?
    let exerciseFrequency: ProfileExerciseFrequency?
    let dailyActivityLevel: ProfileDailyActivityLevel?
    let cardioFitnessLevel: ProfileCardioFitnessLevel?
    // Preferences
    let lengthUnitPreference: LengthUnitPreference?
    let weightUnitPreference: WeightUnitPreference?
    
    // Profile
    private(set) var profileImageUrl: String?

    // Creation
    let creationDate: Date?
    let creationVersion: String?
    
    // Sign In
    let lastSignInDate: Date?
    
    // Onboarding
    let didCompleteOnboarding: Bool?
    
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
        profileImageUrl: String? = nil,
        creationDate: Date? = nil,
        creationVersion: String? = nil,
        lastSignInDate: Date? = nil,
        didCompleteOnboarding: Bool? = nil,
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
        self.profileImageUrl = profileImageUrl
        self.creationDate = creationDate
        self.creationVersion = creationVersion
        self.lastSignInDate = lastSignInDate
        self.didCompleteOnboarding = didCompleteOnboarding
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
        case profileImageUrl = "profile_image_url"
        case creationDate = "creation_date"
        case creationVersion = "creation_version"
        case lastSignInDate = "last_sign_in_date"
        case didCompleteOnboarding = "did_complete_onboarding"
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
            "user_\(CodingKeys.isAnonymous.rawValue)": isAnonymous,
            "user_\(CodingKeys.creationDate.rawValue)": creationDate,
            "user_\(CodingKeys.creationVersion.rawValue)": creationVersion,
            "user_\(CodingKeys.lastSignInDate.rawValue)": lastSignInDate,
            "user_\(CodingKeys.didCompleteOnboarding.rawValue)": didCompleteOnboarding,
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
                userId: "user4",
                email: "user4@example.com",
                isAnonymous: true,
                firstName: "Dana",
                creationDate: now.addingTimeInterval(-5 * 86400 - 4 * 3600),
                creationVersion: "1.0.0",
                lastSignInDate: now.addingTimeInterval(-4 * 3600),
                didCompleteOnboarding: nil,
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

enum Gender: String, Codable {
    case male
    case female
    var description: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        }
    }
}

enum ProfileExerciseFrequency: String, Codable {
    case never
    case oneToTwo = "1-2"
    case threeToFour = "3-4"
    case fiveToSix = "5-6"
    case daily
}

enum ProfileDailyActivityLevel: String, Codable {
    case sedentary
    case light
    case moderate
    case active
    case veryActive = "very_active"
}

enum ProfileCardioFitnessLevel: String, Codable {
    case beginner
    case novice
    case intermediate
    case advanced
    case elite
}

enum LengthUnitPreference: String, Codable {
    case centimeters
    case inches
}

enum WeightUnitPreference: String, Codable {
    case kilograms
    case pounds
}
