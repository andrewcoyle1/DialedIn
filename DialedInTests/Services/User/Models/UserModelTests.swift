//
//  UserModelTests.swift
//  DialedInTests
//
//  Created by Andrew Coyle on 25/10/2025.
//

import Testing
import Foundation

struct UserModelTests {

    // MARK: - Initialization Tests
    
    @Test("Test Basic Initialisation")
    func testBasicInitialization() {
        
        let randomUserId = String.random
        let randomEmail = "\(String.random)@example.com"
        let randomFirstName = "\(String.random)"
        let randomLastName = "\(String.random)"
        
        let user = UserModel(
            userId: randomUserId,
            email: randomEmail,
            firstName: randomFirstName,
            lastName: randomLastName
        )
        
        #expect(user.userId == randomUserId)
        #expect(user.email == randomEmail)
        #expect(user.firstName == randomFirstName)
        #expect(user.lastName == randomLastName)
    }
    
    @Test("Test Initialization With All Properties")
    func testInitializationWithAllProperties() {
        let testData = createUserTestData()
        let user = createUserWithAllProperties(data: testData)
        verifyUserProperties(user: user, data: testData)
    }
    
    private func createUserTestData() -> UserTestData {
        return UserTestData(
            dateOfBirth: Date.random,
            creationDate: Date.random,
            lastSignInDate: Date.random,
            userId: String.random,
            email: "\(String.random)@example.com",
            firstName: String.random,
            lastName: String.random,
            goalId: String.random,
            imageUrl: "https://example.com/\(String.random).jpg",
            version: String.random,
            exercise1: String.random,
            exercise2: String.random,
            exercise3: String.random,
            exercise4: String.random,
            workout1: String.random,
            workout2: String.random,
            workout3: String.random,
            ingredient1: String.random,
            ingredient2: String.random,
            ingredient3: String.random,
            recipe1: String.random,
            recipe2: String.random,
            recipe3: String.random,
            user1: String.random
        )
    }
    
    private struct UserTestData {
        let dateOfBirth: Date
        let creationDate: Date
        let lastSignInDate: Date
        let userId: String
        let email: String
        let firstName: String
        let lastName: String
        let goalId: String
        let imageUrl: String
        let version: String
        let exercise1: String
        let exercise2: String
        let exercise3: String
        let exercise4: String
        let workout1: String
        let workout2: String
        let workout3: String
        let ingredient1: String
        let ingredient2: String
        let ingredient3: String
        let recipe1: String
        let recipe2: String
        let recipe3: String
        let user1: String
    }
    
    private func createUserWithAllProperties(data: UserTestData) -> UserModel {
        return UserModel(
            userId: data.userId,
            email: data.email,
            isAnonymous: Bool.random,
            firstName: data.firstName,
            lastName: data.lastName,
            dateOfBirth: data.dateOfBirth,
            gender: .male,
            heightCentimeters: 175.0,
            weightKilograms: 70.0,
            exerciseFrequency: .daily,
            dailyActivityLevel: .active,
            cardioFitnessLevel: .intermediate,
            lengthUnitPreference: .centimeters,
            weightUnitPreference: .kilograms,
            currentGoalId: data.goalId,
            profileImageUrl: data.imageUrl,
            creationDate: data.creationDate,
            creationVersion: data.version,
            lastSignInDate: data.lastSignInDate,
            didCompleteOnboarding: Bool.random,
            onboardingStep: .complete,
            createdExerciseTemplateIds: [data.exercise1, data.exercise2],
            bookmarkedExerciseTemplateIds: [data.exercise3],
            favouritedExerciseTemplateIds: [data.exercise4],
            createdWorkoutTemplateIds: [data.workout1],
            bookmarkedWorkoutTemplateIds: [data.workout2],
            favouritedWorkoutTemplateIds: [data.workout3],
            createdIngredientTemplateIds: [data.ingredient1],
            bookmarkedIngredientTemplateIds: [data.ingredient2],
            favouritedIngredientTemplateIds: [data.ingredient3],
            createdRecipeTemplateIds: [data.recipe1],
            bookmarkedRecipeTemplateIds: [data.recipe2],
            favouritedRecipeTemplateIds: [data.recipe3],
            blockedUserIds: [data.user1]
        )
    }
    
    private func verifyUserProperties(user: UserModel, data: UserTestData) {
        #expect(user.userId == data.userId)
        #expect(user.email == data.email)
        #expect(user.firstName == data.firstName)
        #expect(user.lastName == data.lastName)
        #expect(user.dateOfBirth == data.dateOfBirth)
        #expect(user.gender == .male)
        #expect(user.heightCentimeters == 175.0)
        #expect(user.weightKilograms == 70.0)
        #expect(user.exerciseFrequency == .daily)
        #expect(user.dailyActivityLevel == .active)
        #expect(user.cardioFitnessLevel == .intermediate)
        #expect(user.lengthUnitPreference == .centimeters)
        #expect(user.weightUnitPreference == .kilograms)
        #expect(user.currentGoalId == data.goalId)
        #expect(user.profileImageUrl == data.imageUrl)
        #expect(user.creationDate == data.creationDate)
        #expect(user.creationVersion == data.version)
        #expect(user.lastSignInDate == data.lastSignInDate)
        #expect(user.onboardingStep == .complete)
        #expect(user.createdExerciseTemplateIds == [data.exercise1, data.exercise2])
        #expect(user.bookmarkedExerciseTemplateIds == [data.exercise3])
        #expect(user.favouritedExerciseTemplateIds == [data.exercise4])
        #expect(user.createdWorkoutTemplateIds == [data.workout1])
        #expect(user.bookmarkedWorkoutTemplateIds == [data.workout2])
        #expect(user.favouritedWorkoutTemplateIds == [data.workout3])
        #expect(user.createdIngredientTemplateIds ==    [data.ingredient1])
        #expect(user.bookmarkedIngredientTemplateIds == [data.ingredient2])
        #expect(user.favouritedIngredientTemplateIds == [data.ingredient3])
        #expect(user.createdRecipeTemplateIds ==    [data.recipe1])
        #expect(user.bookmarkedRecipeTemplateIds == [data.recipe2])
        #expect(user.favouritedRecipeTemplateIds == [data.recipe3])
        #expect(user.blockedUserIds == [data.user1])
    }
    
    @Test("Test Initialization From User Auth Info")
    func testInitializationFromUserAuthInfo() {
        let creationDate = Date.random
        let lastSignInDate = Date.random
        let randomUid = String.random
        let randomEmail = "\(String.random)@example.com"
        let randomVersion = String.random
        
        let authInfo = UserAuthInfo(
            uid: randomUid,
            email: randomEmail,
            isAnonymous: Bool.random,
            creationDate: creationDate,
            lastSignInDate: lastSignInDate,
            isNewUser: Bool.random
        )
        
        let user = UserModel(auth: authInfo, creationVersion: randomVersion)
        
        #expect(user.userId == randomUid)
        #expect(user.email == randomEmail)
        #expect(user.isAnonymous == authInfo.isAnonymous)
        #expect(user.creationDate == creationDate)
        #expect(user.creationVersion == randomVersion)
        #expect(user.lastSignInDate == lastSignInDate)
    }
    
    @Test("Test Initialization With Nil Values")
    func testInitializationWithNilValues() {
        let randomUserId = String.random
        let user = UserModel(userId: randomUserId)
        
        #expect(user.userId == randomUserId)
        #expect(user.email == nil)
        #expect(user.firstName == nil)
        #expect(user.lastName == nil)
        #expect(user.dateOfBirth == nil)
        #expect(user.gender == nil)
    }
    
    // MARK: - Mutating Function Tests
    
    @Test("Test Update Image URL")
    func testUpdateImageURL() {
        let randomUserId = String.random
        let randomImageUrl = "https://example.com/\(String.random).jpg"
        
        var user = UserModel(userId: randomUserId)
        
        #expect(user.profileImageUrl == nil)
        
        user.updateImageURL(imageUrl: randomImageUrl)
        
        #expect(user.profileImageUrl == randomImageUrl)
    }
    
    // MARK: - Equatable Tests
    
    @Test("Test Equality With Same Properties")
    func testEqualityWithSameProperties() {
        let randomUserId = String.random
        let randomEmail = "\(String.random)@example.com"
        let randomFirstName = String.random
        
        let user1 = UserModel(
            userId: randomUserId,
            email: randomEmail,
            firstName: randomFirstName
        )
        
        let user2 = UserModel(
            userId: randomUserId,
            email: randomEmail,
            firstName: randomFirstName
        )
        
        #expect(user1 == user2)
    }
    
    @Test("Test Inequality With Different User Id")
    func testInequalityWithDifferentUserId() {
        let randomUserId1 = String.random
        let randomUserId2 = String.random
        
        let user1 = UserModel(userId: randomUserId1)
        let user2 = UserModel(userId: randomUserId2)
        
        #expect(user1 != user2)
    }
    
    @Test("Test Inequality With Different Email")
    func testInequalityWithDifferentEmail() {
        let randomUserId = String.random
        let randomEmail1 = "\(String.random)@example.com"
        let randomEmail2 = "\(String.random)@example.com"
        
        let user1 = UserModel(userId: randomUserId, email: randomEmail1)
        let user2 = UserModel(userId: randomUserId, email: randomEmail2)
        
        #expect(user1 != user2)
    }
    
    // MARK: - Codable Tests
    
    @Test("Test Encoding And Decoding")
    func testEncodingAndDecoding() throws {
        let randomUserId = String.random
        let randomEmail = "\(String.random)@example.com"
        let randomFirstName = String.random
        let randomLastName = String.random
        let randomVersion = String.random
        let randomEx1 = String.random
        let randomEx2 = String.random
        let randomUser1 = String.random
        let creationDate = Date.random
        let randomDidComplete = Bool.random
        
        let originalUser = UserModel(
            userId: randomUserId,
            email: randomEmail,
            isAnonymous: false,
            firstName: randomFirstName,
            lastName: randomLastName,
            gender: .male,
            heightCentimeters: 175.0,
            weightKilograms: 70.0,
            exerciseFrequency: .daily,
            dailyActivityLevel: .active,
            cardioFitnessLevel: .intermediate,
            lengthUnitPreference: .centimeters,
            weightUnitPreference: .kilograms,
            creationDate: creationDate,
            creationVersion: randomVersion,
            didCompleteOnboarding: randomDidComplete,
            onboardingStep: .complete,
            createdExerciseTemplateIds: [randomEx1, randomEx2],
            blockedUserIds: [randomUser1]
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let encodedData = try encoder.encode(originalUser)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let decodedUser = try decoder.decode(UserModel.self, from: encodedData)
        
        // With millisecondsSince1970, dates preserve sub-second precision
        #expect(decodedUser == originalUser)
    }
    
    @Test("Test Encoding Nil Values")
    func testEncodingNilValues() throws {
        let randomUserId = String.random
        let user = UserModel(userId: randomUserId)
        
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(user)
        
        let decoder = JSONDecoder()
        let decodedUser = try decoder.decode(UserModel.self, from: encodedData)
        
        #expect(decodedUser.userId == randomUserId)
        #expect(decodedUser.email == nil)
        #expect(decodedUser.firstName == nil)
    }
    
    @Test("Test Coding Keys Mapping")
    func testCodingKeysMapping() throws {
        let randomUserId = String.random
        let randomEmail = "\(String.random)@example.com"
        let randomFirstName = String.random
        let randomLastName = String.random
        
        let user = UserModel(
            userId: randomUserId,
            email: randomEmail,
            firstName: randomFirstName,
            lastName: randomLastName
        )
        
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(user)
        
        let json = try JSONSerialization.jsonObject(with: encodedData) as? [String: Any]
        
        #expect(json?["user_id"] as? String == randomUserId)
        #expect(json?["email"] as? String == randomEmail)
        #expect(json?["first_name"] as? String == randomFirstName)
        #expect(json?["last_name"] as? String == randomLastName)
    }
    
    // MARK: - Event Parameters Tests
    
    @Test("Test Event Parameters")
    func testEventParameters() {
        let randomUserId = String.random
        let randomEmail = "\(String.random)@example.com"
        let randomFirstName = String.random
        let randomLastName = String.random
        let randomVersion = String.random
        let randomDidComplete = Bool.random
        
        let user = UserModel(
            userId: randomUserId,
            email: randomEmail,
            firstName: randomFirstName,
            lastName: randomLastName,
            gender: .male,
            heightCentimeters: 175.0,
            exerciseFrequency: .daily,
            dailyActivityLevel: .active,
            cardioFitnessLevel: .intermediate,
            creationVersion: randomVersion,
            didCompleteOnboarding: randomDidComplete,
            onboardingStep: .complete
        )
        
        let eventParams = user.eventParameters
        
        #expect(eventParams["user_user_id"] as? String == randomUserId)
        #expect(eventParams["user_email"] as? String == randomEmail)
        #expect(eventParams["user_first_name"] as? String == randomFirstName)
        #expect(eventParams["user_last_name"] as? String == randomLastName)
        #expect(eventParams["user_gender"] as? String == "Male")
        #expect(eventParams["user_height_cm"] as? Double == 175.0)
        #expect(eventParams["user_exercise_frequency"] as? String == "daily")
        #expect(eventParams["user_daily_activity_level"] as? String == "active")
        #expect(eventParams["user_cardio_fitness_level"] as? String == "intermediate")
        #expect(eventParams["user_creation_version"] as? String == randomVersion)
        #expect(eventParams["user_did_complete_onboarding"] as? Bool == randomDidComplete)
        #expect(eventParams["user_onboarding_step"] as? String == "complete")
    }
    
    @Test("Test Event Parameters Filters Nil Values")
    func testEventParametersFiltersNilValues() {
        let randomUserId = String.random
        let user = UserModel(userId: randomUserId)
        
        let eventParams = user.eventParameters
        
        #expect(eventParams["user_user_id"] as? String == randomUserId)
        #expect(eventParams["user_email"] == nil)
        #expect(eventParams["user_first_name"] == nil)
    }
    
    // MARK: - Mock Tests
    
    @Test("Test Mock Property")
    func testMockProperty() {
        let mock = UserModel.mock
        
        #expect(mock.userId == "user1")
        #expect(mock.email == "user1@example.com")
        #expect(mock.firstName == "Alice")
        #expect(mock.lastName == "Cooper")
    }
    
    @Test("Test Mock With Step Complete")
    func testMockWithStepComplete() {
        let mock = UserModel.mockWithStep(.complete)
        
        #expect(mock.onboardingStep == .complete)
        #expect(mock.didCompleteOnboarding == true)
    }
    
    @Test("Test Mock With Step Nil")
    func testMockWithStepNil() {
        let mock = UserModel.mockWithStep(nil)
        
        #expect(mock.onboardingStep == nil)
        #expect(mock.didCompleteOnboarding == false)
    }
    
    @Test("Test Mock With Step Goal Setting")
    func testMockWithStepGoalSetting() {
        let mock = UserModel.mockWithStep(.goalSetting)
        
        #expect(mock.onboardingStep == .goalSetting)
        #expect(mock.didCompleteOnboarding == false)
    }
    
    @Test("Test Mocks Property")
    func testMocksProperty() {
        let mocks = UserModel.mocks
        
        #expect(mocks.count == 5)
        #expect(mocks[0].userId == "user1")
        #expect(mocks[1].userId == "user2")
        #expect(mocks[2].userId == "user3")
        #expect(mocks[3].userId == "user5")
        #expect(mocks[4].userId == "user6")
    }
    
    @Test("Test Mocks Have Different Onboarding Steps")
    func testMocksHaveDifferentOnboardingSteps() {
        let mocks = UserModel.mocks
        
        #expect(mocks[0].onboardingStep == .complete)
        #expect(mocks[1].onboardingStep == .subscription)
        #expect(mocks[2].onboardingStep == .completeAccountSetup)
        #expect(mocks[3].onboardingStep == .goalSetting)
        #expect(mocks[4].onboardingStep == .customiseProgram)
    }
    
    @Test("Test Mocks Have Different Is Anonymous Values")
    func testMocksHaveDifferentIsAnonymousValues() {
        let mocks = UserModel.mocks
        
        #expect(mocks[0].isAnonymous == false)
        #expect(mocks[1].isAnonymous == false)
        #expect(mocks[2].isAnonymous == false)
        #expect(mocks[3].isAnonymous == true)
        #expect(mocks[4].isAnonymous == true)
    }
    
    // MARK: - Enum Tests
    
    @Test("Test Gender Enum Raw Values")
    func testGenderEnumRawValues() {
        #expect(Gender.male.rawValue == "male")
        #expect(Gender.female.rawValue == "female")
    }
    
    @Test("Test Gender Enum Description")
    func testGenderEnumDescription() {
        #expect(Gender.male.description == "Male")
        #expect(Gender.female.description == "Female")
    }
    
    @Test("Test Profile Exercise Frequency Raw Values")
    func testProfileExerciseFrequencyRawValues() {
        #expect(ProfileExerciseFrequency.never.rawValue == "never")
        #expect(ProfileExerciseFrequency.oneToTwo.rawValue == "1-2")
        #expect(ProfileExerciseFrequency.threeToFour.rawValue == "3-4")
        #expect(ProfileExerciseFrequency.fiveToSix.rawValue == "5-6")
        #expect(ProfileExerciseFrequency.daily.rawValue == "daily")
    }
    
    @Test("Test Profile Daily Activity Level Raw Values")
    func testProfileDailyActivityLevelRawValues() {
        #expect(ProfileDailyActivityLevel.sedentary.rawValue == "sedentary")
        #expect(ProfileDailyActivityLevel.light.rawValue == "light")
        #expect(ProfileDailyActivityLevel.moderate.rawValue == "moderate")
        #expect(ProfileDailyActivityLevel.active.rawValue == "active")
        #expect(ProfileDailyActivityLevel.veryActive.rawValue == "very_active")
    }
    
    @Test("Test Profile Cardio Fitness Level Raw Values")
    func testProfileCardioFitnessLevelRawValues() {
        #expect(ProfileCardioFitnessLevel.beginner.rawValue == "beginner")
        #expect(ProfileCardioFitnessLevel.novice.rawValue == "novice")
        #expect(ProfileCardioFitnessLevel.intermediate.rawValue == "intermediate")
        #expect(ProfileCardioFitnessLevel.advanced.rawValue == "advanced")
        #expect(ProfileCardioFitnessLevel.elite.rawValue == "elite")
    }
    
    @Test("Test Length Unit Preference Raw Values")
    func testLengthUnitPreferenceRawValues() {
        #expect(LengthUnitPreference.centimeters.rawValue == "centimeters")
        #expect(LengthUnitPreference.inches.rawValue == "inches")
    }
    
    @Test("Test Weight Unit Preference Raw Values")
    func testWeightUnitPreferenceRawValues() {
        #expect(WeightUnitPreference.kilograms.rawValue == "kilograms")
        #expect(WeightUnitPreference.pounds.rawValue == "pounds")
    }
    
    @Test("Test Onboarding Step Raw Values")
    func testOnboardingStepRawValues() {
        #expect(OnboardingStep.auth.rawValue == "auth")
        #expect(OnboardingStep.subscription.rawValue == "subscription")
        #expect(OnboardingStep.completeAccountSetup.rawValue == "completeAccountSetup")
        #expect(OnboardingStep.healthDisclaimer.rawValue == "healthDisclaimer")
        #expect(OnboardingStep.goalSetting.rawValue == "goalSetting")
        #expect(OnboardingStep.customiseProgram.rawValue == "customiseProgram")
        #expect(OnboardingStep.diet.rawValue == "diet")
        #expect(OnboardingStep.complete.rawValue == "complete")
    }
    
    @Test("Test Onboarding Step Order Index")
    func testOnboardingStepOrderIndex() {
        #expect(OnboardingStep.auth.orderIndex == 0)
        #expect(OnboardingStep.subscription.orderIndex == 1)
        #expect(OnboardingStep.completeAccountSetup.orderIndex == 2)
        #expect(OnboardingStep.healthDisclaimer.orderIndex == 3)
        #expect(OnboardingStep.goalSetting.orderIndex == 4)
        #expect(OnboardingStep.customiseProgram.orderIndex == 5)
        #expect(OnboardingStep.diet.orderIndex == 6)
        #expect(OnboardingStep.complete.orderIndex == 7)
    }
}
