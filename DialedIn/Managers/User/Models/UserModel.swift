//
//  UserModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/9/24.
//
import Foundation
import SwiftUI

struct UserModel: DataSyncModelProtocol, Equatable {
    
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
    let submittedExerciseFrequency: ExerciseFrequency?
    let submittedDailyActivityLevel: ActivityLevel?
    let submittedCardioFitnessLevel: CardioFitnessLevel?
    let submittedLengthUnitPreference: LengthUnitPreference?
    let submittedWeightUnitPreference: WeightUnitPreference?
    let submittedCurrentGoalId: String?
    let submittedFavouriteGymProfileId: String?
    let submittedActiveTrainingProgramId: String?
    let fcmToken: String?
    let blockedUserIds: [String]?
    let followingIds: [String]?
    var didCompleteOnboarding: Bool
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
        submittedExerciseFrequency: ExerciseFrequency? = nil,
        submittedDailyActivityLevel: ActivityLevel? = nil,
        submittedCardioFitnessLevel: CardioFitnessLevel? = nil,
        submittedLengthUnitPreference: LengthUnitPreference? = nil,
        submittedWeightUnitPreference: WeightUnitPreference? = nil,
        submittedCurrentGoalId: String? = nil,
        submittedActiveTrainingProgramId: String? = nil,
        submittedFavouriteGymProfileId: String? = nil,
        blockedUserIds: [String]? = nil,
        followingIds: [String]? = nil,
        fcmToken: String? = nil,
        didCompleteOnboarding: Bool = false,
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
        self.followingIds = followingIds
        self.fcmToken = fcmToken
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
        case submittedDateOfBirth = "submitted_date_of_birth"
        case submittedGender = "submitted_gender"
        case submittedHeightCentimeters = "submitted_height_centimeters"
        case submittedWeightKilograms = "submitted_weight_kilograms"
        case submittedExerciseFrequency = "submitted_exercise_frequency"
        case submittedDailyActivityLevel = "submitted_daily_activity_level"
        case submittedCardioFitnessLevel = "submitted_cardio_fitness_level"
        case submittedLengthUnitPreference = "submitted_length_unit_preference"
        case submittedWeightUnitPreference = "submitted_weight_unit_preference"
        case submittedCurrentGoalId = "submitted_current_goal_id"
        case submittedActiveTrainingProgramId = "submitted_active_training_program_id"
        case submittedFavouriteGymProfileId = "submitted_favourite_gym_profile_id"
        case didCompleteOnboarding = "did_complete_onboarding"
        case blockedUserIds = "blocked_user_ids"
        case followingIds = "following_ids"
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
            "user_\(CodingKeys.submittedActiveTrainingProgramId.rawValue)": submittedActiveTrainingProgramId,
            "user_\(CodingKeys.submittedFavouriteGymProfileId.rawValue)": submittedFavouriteGymProfileId,
            "user_\(CodingKeys.blockedUserIds.rawValue)": blockedUserIds,
            "user_has_\(CodingKeys.fcmToken.rawValue)": (fcmToken?.count ?? 0) > 0,
            "user_\(CodingKeys.didCompleteOnboarding.rawValue)": didCompleteOnboarding,
            "user_\(CodingKeys.acceptedHealthDisclaimerVersion.rawValue)": acceptedHealthDisclaimerVersion,
            "user_\(CodingKeys.acceptedHealthDisclaimerDate.rawValue)": acceptedHealthDisclaimerDate,
            "user_\(CodingKeys.acceptedHealthPrivacyPolicyVersion.rawValue)": acceptedHealthPrivacyPolicyVersion,
            "user_\(CodingKeys.acceptedHealthPrivacyPolicyDate.rawValue)": acceptedHealthPrivacyPolicyDate
        ]
        return dict.compactMapValues({ $0 })
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

    /// Infer the user's current onboarding step from which fields have been filled.
    var inferredOnboardingStep: OnboardingStep {
        guard submittedDateOfBirth != nil,
              submittedGender != nil,
              submittedHeightCentimeters != nil,
              submittedWeightKilograms != nil,
              submittedExerciseFrequency != nil,
              submittedDailyActivityLevel != nil,
              submittedCardioFitnessLevel != nil else {
            return .completeAccountSetup
        }
        guard acceptedHealthDisclaimerVersion != nil else { return .healthDisclaimer }
        guard submittedCurrentGoalId != nil else { return .goalSetting }
        guard submittedFavouriteGymProfileId != nil else { return .gymProfileSetup }
        guard submittedActiveTrainingProgramId != nil else { return .trainingProgramSetup }
        guard didCompleteOnboarding else { return .customiseProgram }
        return .complete
    }
    
    mutating func markDidCompleteOnboarding() {
        didCompleteOnboarding = true
    }
}

extension UserModel {
    
    static var mock: Self {
        mocks[0]
    }

    /// A complete, fully-onboarded user whose userId matches `UserAuthInfo.mock().uid`.
    /// Use this in mock scenarios where an existing authenticated user is required.
    static var mockExisting: Self {
        UserModel(
            userId: "mock_user_123",
            email: "alice@example.com",
            isAnonymous: false,
            firstName: "Alice",
            lastName: "Cooper",
            creationDate: Date().addingTimeInterval(-30 * 86400),
            creationVersion: "1.0.0",
            lastSignInDate: Date(),
            submittedProfileImage: "https://picsum.photos/200",
            submittedDateOfBirth: Calendar.current.date(from: DateComponents(year: 2000, month: 11, day: 13)),
            submittedGender: .male,
            submittedHeightCentimeters: 175.0,
            submittedWeightKilograms: 70.0,
            submittedExerciseFrequency: .daily,
            submittedDailyActivityLevel: .active,
            submittedCardioFitnessLevel: .intermediate,
            submittedCurrentGoalId: "goal1",
            submittedActiveTrainingProgramId: TrainingProgram.mock.id,
            submittedFavouriteGymProfileId: GymProfileModel.mock.id,
            didCompleteOnboarding: true,
            acceptedHealthDisclaimerVersion: "2025.10.05"
        )
    }

    static func mockWithStep(_ step: OnboardingStep) -> Self {
        let now = Date()
        let hasProfile = step.orderIndex >= OnboardingStep.completeAccountSetup.orderIndex
        let hasDisclaimer = step.orderIndex >= OnboardingStep.healthDisclaimer.orderIndex
        let hasGoal = step.orderIndex >= OnboardingStep.goalSetting.orderIndex
        return UserModel(
            userId: "mockUser",
            email: "mock@example.com",
            isAnonymous: false,
            firstName: "Mock",
            lastName: "User",
            creationDate: now,
            creationVersion: "1.0.0",
            lastSignInDate: now,
            submittedDateOfBirth: hasProfile ? Calendar.current.date(from: DateComponents(year: 1990, month: 1, day: 1)) : nil,
            submittedGender: hasProfile ? .male : nil,
            submittedHeightCentimeters: hasProfile ? 175.0 : nil,
            submittedWeightKilograms: hasProfile ? 70.0 : nil,
            submittedExerciseFrequency: hasProfile ? .fiveToSix : nil,
            submittedDailyActivityLevel: hasProfile ? .active : nil,
            submittedCardioFitnessLevel: hasProfile ? .intermediate : nil,
            submittedCurrentGoalId: hasGoal ? "mock_goal_id" : nil,
            didCompleteOnboarding: step == .complete,
            acceptedHealthDisclaimerVersion: hasDisclaimer ? "2025.10.05" : nil
        )
    }

    static var mocks: [Self] {
        let now = Date()
        return [
            UserModel(
                userId: "mock_user_123",
                email: "anonymous@example.com",
                isAnonymous: false,
                firstName: "Andrew",
                lastName: "Coyle",
                creationDate: now,
                creationVersion: "1.0.0",
                lastSignInDate: now,
                submittedProfileImage: Constants.randomImage,
                submittedDateOfBirth: Calendar.current.date(from: DateComponents(year: 2000, month: 11, day: 13)),
                submittedGender: .male,
                submittedHeightCentimeters: 175,
                submittedWeightKilograms: 82.0,
                submittedExerciseFrequency: .daily,
                submittedDailyActivityLevel: .active,
                submittedCardioFitnessLevel: .intermediate,
                submittedLengthUnitPreference: .centimeters,
                submittedWeightUnitPreference: .kilograms,
                submittedCurrentGoalId: WeightGoal.mocks.first!.id,
                submittedActiveTrainingProgramId: TrainingProgram.mock.id,
                submittedFavouriteGymProfileId: GymProfileModel.mock.id,
                followingIds: ["user_1"],
                didCompleteOnboarding: true,
                acceptedHealthDisclaimerVersion: "2025.10.05",
                acceptedHealthDisclaimerDate: now,
                acceptedHealthPrivacyPolicyVersion: "2025.10.05",
                acceptedHealthPrivacyPolicyDate: now
            ),
            UserModel(
                userId: "user_1",
                email: "user1@example.com",
                isAnonymous: false,
                firstName: "Alice",
                lastName: "Cooper",
                creationDate: now,
                creationVersion: "1.0.0",
                lastSignInDate: now,
                submittedProfileImage: "https://picsum.photos/200",
                submittedDateOfBirth: Calendar.current.date(from: DateComponents(year: 2000, month: 11, day: 13)),
                submittedGender: .male,
                submittedHeightCentimeters: 175.0,
                submittedWeightKilograms: 70.0,
                submittedExerciseFrequency: .daily,
                submittedDailyActivityLevel: .active,
                submittedCardioFitnessLevel: .intermediate,
                submittedCurrentGoalId: "goal1",
                blockedUserIds: ["user2", "user3"],
                didCompleteOnboarding: true,
                acceptedHealthDisclaimerVersion: "2025.10.05"
            ),
            UserModel(
                userId: "user2",
                email: "user2@example.com",
                isAnonymous: false,
                firstName: "Bob",
                creationDate: now.addingTimeInterval(-86400),
                creationVersion: "1.0.0",
                lastSignInDate: now.addingTimeInterval(-3600),
                blockedUserIds: ["mock_user_123", "user3"],
                didCompleteOnboarding: false
            ),
            UserModel(
                userId: "user3",
                email: "user3@example.com",
                isAnonymous: false,
                firstName: "Charlie",
                creationDate: now.addingTimeInterval(-3 * 86400 - 2 * 3600),
                creationVersion: "1.0.0",
                lastSignInDate: now.addingTimeInterval(-2 * 3600),
                submittedDateOfBirth: Calendar.current.date(from: DateComponents(year: 1985, month: 6, day: 15)),
                submittedGender: .female,
                submittedHeightCentimeters: 165.0,
                submittedWeightKilograms: 60.0,
                submittedExerciseFrequency: .threeToFour,
                submittedDailyActivityLevel: .moderate,
                submittedCardioFitnessLevel: .novice,
                submittedCurrentGoalId: "goal3",
                blockedUserIds: ["mock_user_123", "user2"],
                didCompleteOnboarding: true,
                acceptedHealthDisclaimerVersion: "2025.10.05"
            ),
            UserModel(
                userId: "user5",
                email: "user5@example.com",
                isAnonymous: true,
                firstName: "Andrew",
                creationDate: now.addingTimeInterval(-5 * 86400 - 4 * 3600),
                creationVersion: "1.0.0",
                lastSignInDate: now.addingTimeInterval(-4 * 3600),
                submittedDateOfBirth: Calendar.current.date(from: DateComponents(year: 1995, month: 3, day: 22)),
                submittedGender: .male,
                submittedHeightCentimeters: 180.0,
                submittedWeightKilograms: 80.0,
                submittedExerciseFrequency: .fiveToSix,
                submittedDailyActivityLevel: .active,
                submittedCardioFitnessLevel: .intermediate,
                blockedUserIds: ["mock_user_123", "user2"],
                didCompleteOnboarding: false,
                acceptedHealthDisclaimerVersion: "2025.10.05"
            ),
            UserModel(
                userId: "user6",
                email: "user6@example.com",
                isAnonymous: true,
                firstName: "David",
                creationDate: now.addingTimeInterval(-5 * 86400 - 4 * 3600),
                creationVersion: "1.0.0",
                lastSignInDate: now.addingTimeInterval(-4 * 3600),
                submittedDateOfBirth: Calendar.current.date(from: DateComponents(year: 1992, month: 9, day: 8)),
                submittedGender: .male,
                submittedHeightCentimeters: 178.0,
                submittedWeightKilograms: 75.0,
                submittedExerciseFrequency: .threeToFour,
                submittedDailyActivityLevel: .light,
                submittedCardioFitnessLevel: .beginner,
                submittedCurrentGoalId: "goal6",
                blockedUserIds: ["user1", "user2"],
                didCompleteOnboarding: false,
                acceptedHealthDisclaimerVersion: "2025.10.05"
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
    case gymProfileSetup
    case trainingProgramSetup
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
        case .trainingProgramSetup: return 7
        case .gymProfileSetup: return 8
        case .customiseProgram: return 9
        case .complete: return 10
        }
    }
}
