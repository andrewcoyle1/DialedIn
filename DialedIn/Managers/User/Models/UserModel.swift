//
//  UserModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/9/24.
//
import Foundation
import SwiftUI

struct UserModel: Codable, Equatable, Sendable {
    
    var id: String {
        userId
    }
    
    // These values come from the user's Auth info
    let userId: String
    let email: String?
    let isAnonymous: Bool?
    let authProviders: [String]?
    let displayName: String?
    let firstName: String?
    let lastName: String?
    let phoneNumber: String?
    let photoUrl: String?
    let creationDate: Date?
    let creationVersion: String?
    let lastSignInDate: Date?
    
    // These values are submitted by the user
    let submittedEmail: String?
    let submittedFirstName: String?
    let submittedLastName: String?
    let submittedProfileImage: String?
    let submittedDateOfBirth: Date?
    let submittedGender: Gender?
    let submittedHeightCentimeters: Double?
    let submittedWeightKilograms: Double?
    let submittedExerciseFrequency: ProfileExerciseFrequency?
    let submittedDailyActivityLevel: ProfileDailyActivityLevel?
    let submittedCardioFitnessLevel: ProfileCardioFitnessLevel?
    let submittedLengthUnitPreference: LengthUnitPreference?
    let submittedWeightUnitPreference: WeightUnitPreference?
    let submittedCurrentGoalId: String?
    let submittedActiveTrainingProgramId: String?
    let submittedFavouriteGymProfileId: String?
    let fcmToken: String?
    let blockedUserIds: [String]?
    let onboardingStep: OnboardingStep
    private(set) var didCompleteOnboarding: Bool?
    let acceptedHealthDisclaimerVersion: String?
    let acceptedHealthDisclaimerDate: Date?
    let acceptedHealthPrivacyPolicyVersion: String?
    let acceptedHealthPrivacyPolicyDate: Date?

    init(
        userId: String,
        email: String? = nil,
        isAnonymous: Bool? = nil,
        authProviders: [String]? = nil,
        displayName: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        phoneNumber: String? = nil,
        photoUrl: String? = nil,
        creationDate: Date? = nil,
        creationVersion: String? = nil,
        lastSignInDate: Date? = nil,
        submittedEmail: String? = nil,
        submittedFirstName: String? = nil,
        submittedLastName: String? = nil,
        submittedProfileImage: String? = nil,
        submittedDateOfBirth: Date? = nil,
        submittedGender: Gender? = nil,
        submittedHeightCentimeters: Double? = nil,
        submittedWeightKilograms: Double? = nil,
        submittedExerciseFrequency: ProfileExerciseFrequency? = nil,
        submittedDailyActivityLevel: ProfileDailyActivityLevel? = nil,
        submittedCardioFitnessLevel: ProfileCardioFitnessLevel? = nil,
        submittedLengthUnitPreference: LengthUnitPreference? = nil,
        submittedWeightUnitPreference: WeightUnitPreference? = nil,
        submittedCurrentGoalId: String? = nil,
        submittedActiveTrainingProgramId: String? = nil,
        submittedFavouriteGymProfileId: String? = nil,
        blockedUserIds: [String]? = nil,
        fcmToken: String? = nil,
        didCompleteOnboarding: Bool? = nil,
        onboardingStep: OnboardingStep = .auth,
        acceptedHealthDisclaimerVersion: String? = nil,
        acceptedHealthDisclaimerDate: Date? = nil,
        acceptedHealthPrivacyPolicyVersion: String? = nil,
        acceptedHealthPrivacyPolicyDate: Date? = nil

    ) {
        self.userId = userId
        self.email = email
        self.isAnonymous = isAnonymous
        self.authProviders = authProviders
        self.displayName = displayName
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.photoUrl = photoUrl
        self.creationDate = creationDate
        self.creationVersion = creationVersion
        self.lastSignInDate = lastSignInDate
        self.submittedFirstName = submittedFirstName
        self.submittedLastName = submittedLastName
        self.submittedEmail = submittedEmail
        self.submittedProfileImage = submittedProfileImage
        self.submittedDateOfBirth = submittedDateOfBirth
        self.submittedGender = submittedGender
        self.submittedHeightCentimeters = submittedHeightCentimeters
        self.submittedWeightKilograms = submittedWeightKilograms
        self.submittedExerciseFrequency = submittedExerciseFrequency
        self.submittedDailyActivityLevel = submittedDailyActivityLevel
        self.submittedCardioFitnessLevel = submittedCardioFitnessLevel
        self.submittedLengthUnitPreference = submittedLengthUnitPreference
        self.submittedWeightUnitPreference = submittedWeightUnitPreference
        self.submittedCurrentGoalId = submittedCurrentGoalId
        self.submittedActiveTrainingProgramId = submittedActiveTrainingProgramId
        self.submittedFavouriteGymProfileId = submittedFavouriteGymProfileId
        self.blockedUserIds = blockedUserIds
        self.fcmToken = fcmToken
        self.onboardingStep = onboardingStep
        self.didCompleteOnboarding = didCompleteOnboarding
        self.acceptedHealthDisclaimerVersion = acceptedHealthDisclaimerVersion
        self.acceptedHealthDisclaimerDate = acceptedHealthDisclaimerDate
        self.acceptedHealthPrivacyPolicyVersion = acceptedHealthPrivacyPolicyVersion
        self.acceptedHealthPrivacyPolicyDate = acceptedHealthPrivacyPolicyDate
    }
    
    init(auth: UserAuthInfo, creationVersion: String?) {
        self.init(
            userId: auth.uid,
            email: auth.email,
            isAnonymous: auth.isAnonymous,
            authProviders: auth.authProviders.map({ $0.rawValue }),
            displayName: auth.displayName,
            firstName: auth.firstName,
            lastName: auth.lastName,
            phoneNumber: auth.phoneNumber,
            photoUrl: auth.photoURL?.absoluteString,
            creationDate: auth.creationDate,
            creationVersion: creationVersion,
            lastSignInDate: auth.lastSignInDate
        )
    }
    /// First name, per user's Auth info
    var firstNameCalculated: String? {
        if let submittedFirstName,
        !submittedFirstName.isEmpty {
            return submittedFirstName
        } else if let firstName,
        !firstName.isEmpty {
            return firstName
        } else {
            return nil
        }
    }
    
    /// Last name, per user's Auth info
    var lastNameCalculated: String? {
        if let submittedLastName,
        !submittedLastName.isEmpty {
            return submittedLastName
        } else if let lastName,
        !lastName.isEmpty {
            return lastName
        } else {
            return nil
        }
    }
    
    /// Display name, per user's Auth info
    var displayNameCalculated: String? {
        guard let displayName, !displayName.isEmpty else { return nil }
        return displayName
    }
    
    /// Full name, per user's Auth info
    var fullNameCalculated: String? {
        if let firstNameCalculated, let lastNameCalculated {
            return firstNameCalculated + " " + lastNameCalculated
        } else if let firstNameCalculated {
            return firstNameCalculated
        } else if let lastNameCalculated {
            return lastNameCalculated
        }
        return nil
    }
    
    
    /// Try to get the "best" common name for the user (ie. their preferred first name). Use this most of the time.
    var commonNameCalculated: String? {
        if let displayNameCalculated {
            return displayNameCalculated
        } else if let firstNameCalculated {
            return firstNameCalculated
        }
        return nil
    }
    
    /// Try to get submitted profile image, otherwise user image from user's auth (if available).
    var profileImageNameCalculated: String? {
        if let submittedProfileImage {
            return submittedProfileImage
        } else if let photoUrl {
            return photoUrl
        }
        return nil
    }
    
    /// Try to get submitted email, otherwise user email from user's auth (if available).
    var emailCalculated: String? {
        if let submittedEmail {
            return submittedEmail
        } else if let email {
            return email
        }
        return nil
    }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case isAnonymous = "is_anonymous"
        case authProviders = "auth_providers"
        case displayName = "display_name"
        case firstName = "first_name"
        case lastName = "last_name"
        case phoneNumber = "phone_number"
        case photoUrl = "photo_url"
        case creationDate = "creation_date"
        case creationVersion = "creation_version"
        case lastSignInDate = "last_sign_in_date"
        case submittedFirstName = "submitted_first_name"
        case submittedLastName = "submitted_last_name"
        case submittedEmail = "submitted_email"
        case submittedProfileImage = "submitted_profile_image"
        case submittedDateOfBirth = "date_of_birth"
        case submittedGender = "submitted_gender"
        case submittedHeightCentimeters = "height_cm"
        case submittedWeightKilograms = "weight_kg"
        case submittedExerciseFrequency = "exercise_frequency"
        case submittedDailyActivityLevel = "daily_activity_level"
        case submittedCardioFitnessLevel = "cardio_fitness_level"
        case submittedLengthUnitPreference = "length_unit_preference"
        case submittedWeightUnitPreference = "weight_unit_preference"
        case submittedCurrentGoalId = "current_goal_id"
        case submittedActiveTrainingProgramId = "active_training_program_id"
        case submittedFavouriteGymProfileId = "favourite_gym_profile_id"
        case didCompleteOnboarding = "did_complete_onboarding"
        case onboardingStep = "onboarding_step"
        case blockedUserIds = "blocked_user_ids"
        case fcmToken = "fcm_token"
        case acceptedHealthDisclaimerVersion = "accepted_health_disclaimer_version"
        case acceptedHealthDisclaimerDate = "accepted_health_disclaimer_date"
        case acceptedHealthPrivacyPolicyVersion = "accepted_health_privacy_policy_version"
        case acceptedHealthPrivacyPolicyDate = "accepted_health_privacy_policy_date"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "user_\(CodingKeys.userId.rawValue)": userId,
            "user_\(CodingKeys.email.rawValue)": email,
            "user_\(CodingKeys.isAnonymous.rawValue)": isAnonymous,
            "user_\(CodingKeys.authProviders.rawValue)": authProviders?.sorted().joined(separator: ", "),
            "user_\(CodingKeys.displayName.rawValue)": displayNameCalculated,
            "user_\(CodingKeys.firstName.rawValue)": firstNameCalculated,
            "user_\(CodingKeys.lastName.rawValue)": lastNameCalculated,
            "user_common_name_calc": commonNameCalculated,
            "user_full_name_calc": fullNameCalculated,
            "user_\(CodingKeys.phoneNumber.rawValue)": phoneNumber,
            "user_\(CodingKeys.photoUrl.rawValue)": photoUrl,
            "user_\(CodingKeys.creationDate.rawValue)": creationDate,
            "user_\(CodingKeys.creationVersion.rawValue)": creationVersion,
            "user_\(CodingKeys.lastSignInDate.rawValue)": lastSignInDate,
            "user_\(CodingKeys.submittedFirstName.rawValue)": submittedFirstName,
            "user_\(CodingKeys.submittedLastName.rawValue)": submittedLastName,
            "user_\(CodingKeys.submittedEmail.rawValue)": submittedEmail,
            "user_\(CodingKeys.submittedProfileImage.rawValue)": submittedProfileImage,
            "user_\(CodingKeys.submittedDateOfBirth.rawValue)": submittedDateOfBirth,
            "user_\(CodingKeys.submittedGender.rawValue)": submittedGender?.description,
            "user_\(CodingKeys.submittedHeightCentimeters.rawValue)": submittedHeightCentimeters,
            "user_\(CodingKeys.submittedWeightKilograms.rawValue)": submittedWeightKilograms,
            "user_\(CodingKeys.submittedExerciseFrequency.rawValue)": submittedExerciseFrequency?.rawValue,
            "user_\(CodingKeys.submittedDailyActivityLevel.rawValue)": submittedDailyActivityLevel?.rawValue,
            "user_\(CodingKeys.submittedCardioFitnessLevel.rawValue)": submittedCardioFitnessLevel?.rawValue,
            "user_\(CodingKeys.submittedLengthUnitPreference.rawValue)": submittedLengthUnitPreference?.rawValue,
            "user_\(CodingKeys.submittedWeightUnitPreference.rawValue)": submittedWeightUnitPreference?.rawValue,
            "user_\(CodingKeys.submittedCurrentGoalId.rawValue)": submittedCurrentGoalId,
            "user_\(CodingKeys.submittedProfileImage.rawValue)": submittedProfileImage,
            "user_\(CodingKeys.submittedActiveTrainingProgramId.rawValue)": submittedActiveTrainingProgramId,
            "user_\(CodingKeys.submittedFavouriteGymProfileId.rawValue)": submittedFavouriteGymProfileId,
            "user_\(CodingKeys.blockedUserIds.rawValue)": blockedUserIds,
            "user_has_\(CodingKeys.fcmToken.rawValue)": (fcmToken?.count ?? 0) > 0,
            "user_\(CodingKeys.didCompleteOnboarding.rawValue)": didCompleteOnboarding,
            "user_\(CodingKeys.onboardingStep.rawValue)": onboardingStep.rawValue,
            "user_\(CodingKeys.acceptedHealthDisclaimerVersion.rawValue)" : acceptedHealthDisclaimerVersion,
            "user_\(CodingKeys.acceptedHealthDisclaimerDate.rawValue)" : acceptedHealthDisclaimerDate,
            "user_\(CodingKeys.acceptedHealthPrivacyPolicyVersion.rawValue)" : acceptedHealthPrivacyPolicyVersion,
            "user_\(CodingKeys.acceptedHealthPrivacyPolicyDate.rawValue)" : acceptedHealthPrivacyPolicyDate,
        ]
        return dict.compactMapValues({ $0 })
    }
}

extension UserModel {
    
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
            creationDate: now,
            creationVersion: "1.0.0",
            lastSignInDate: now,
            submittedDateOfBirth: Calendar.current.date(from: DateComponents(year: 1990, month: 1, day: 1)),
            submittedGender: .male,
            submittedHeightCentimeters: 175.0,
            submittedWeightKilograms: 70.0,
            submittedExerciseFrequency: .fiveToSix,
            submittedDailyActivityLevel: .active,
            submittedCardioFitnessLevel: .intermediate,
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
                creationDate: now,
                creationVersion: "1.0.0",
                lastSignInDate: now,
                submittedProfileImage: Constants.randomImage,
                submittedDateOfBirth: Calendar.current.date(from: DateComponents(year: 2000, month: 11, day: 13)),
                submittedGender: .male,
                submittedHeightCentimeters: 175.0,
                submittedWeightKilograms: 70.0,
                submittedExerciseFrequency: .daily,
                submittedDailyActivityLevel: .active,
                submittedCardioFitnessLevel: .intermediate,
                blockedUserIds: ["user2", "user3"],
                didCompleteOnboarding: true,
                onboardingStep: .complete
            ),
            UserModel(
                userId: "user2",
                email: "user2@example.com",
                isAnonymous: false,
                firstName: "Bob",
                creationDate: now.addingTimeInterval(-86400),
                creationVersion: "1.0.0",
                lastSignInDate: now.addingTimeInterval(-3600),
                blockedUserIds: ["user1", "user3"],
                didCompleteOnboarding: false,
                onboardingStep: .subscription
            ),
            UserModel(
                userId: "user3",
                email: "user3@example.com",
                isAnonymous: false,
                firstName: "Charlie",
                creationDate: now.addingTimeInterval(-3 * 86400 - 2 * 3600),
                creationVersion: "1.0.0",
                lastSignInDate: now.addingTimeInterval(-2 * 3600),
                blockedUserIds: ["user1", "user2"],
                didCompleteOnboarding: true,
                onboardingStep: .completeAccountSetup
            ),
            UserModel(
                userId: "user5",
                email: "user5@example.com",
                isAnonymous: true,
                firstName: "Andrew",
                creationDate: now.addingTimeInterval(-5 * 86400 - 4 * 3600),
                creationVersion: "1.0.0",
                lastSignInDate: now.addingTimeInterval(-4 * 3600),
                blockedUserIds: ["user1", "user2"],
                didCompleteOnboarding: nil,
                onboardingStep: .goalSetting
            ),
            UserModel(
                userId: "user6",
                email: "user6@example.com",
                isAnonymous: true,
                firstName: "David",
                creationDate: now.addingTimeInterval(-5 * 86400 - 4 * 3600),
                creationVersion: "1.0.0",
                lastSignInDate: now.addingTimeInterval(-4 * 3600),
                blockedUserIds: ["user1", "user2"],
                didCompleteOnboarding: nil,
                onboardingStep: .customiseProgram
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
    
    var abbreviation: String {
        switch self {
        case .centimeters: return "m"
        case .inches: return "m"
        }
    }
    
    var displayName: String {
        switch self {
        case .centimeters: return "Kilometers & Metres"
        case .inches: return "Miles & Yards"
        }
    }

}

enum HeightUnitPreference: String, Codable, Sendable {
    case centimeters
    case inches
    
    var abbreviation: String {
        switch self {
        case .centimeters: return "cm"
        case .inches: return "\""
        }
    }
    
    var displayName: String {
        switch self {
        case .centimeters: return "Centimeters"
        case .inches: return "Feet & Inches"
        }
    }

}

enum WeightUnitPreference: String, Codable, Sendable {
    case kilograms
    case pounds
    
    var abbreviation: String {
        switch self {
        case .kilograms: return "kg"
        case .pounds: return "lbs"
        }
    }
    
    var displayName: String {
        switch self {
        case .kilograms: return "Kilograms"
        case .pounds: return "Pounds"
        }
    }

}

enum ClockUnitPreference: String, Codable, Sendable {
    case twelveHour
    case twentyFourHour
    
    var abbreviation: String {
        switch self {
        case .twelveHour: return "12hr"
        case .twentyFourHour: return "24hr"
        }
    }
    
    var displayName: String {
        switch self {
        case .twelveHour: return "12 Hour"
        case .twentyFourHour: return "24 Hour"
        }
    }

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
