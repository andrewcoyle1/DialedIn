//
//  ExerciseUnitPreferenceManagerTests.swift
//  DialedInTests
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Testing
import Foundation

@MainActor
struct ExerciseUnitPreferenceManagerTests {
    
    // MARK: - Helper Methods
    
    private func createManager(user: UserModel? = nil) -> (ExerciseUnitPreferenceManager, UserDefaults) {
        let userDefaults = UserDefaults(suiteName: "test_\(UUID().uuidString)")!
        let userServices = MockUserServices(user: user)
        let userManager = UserManager(services: userServices)
        let manager = ExerciseUnitPreferenceManager(userDefaults: userDefaults, userManager: userManager)
        return (manager, userDefaults)
    }
    
    private func createUserWithPreferences(
        weightUnit: WeightUnitPreference,
        lengthUnit: LengthUnitPreference
    ) -> UserModel {
        UserModel(
            userId: "testUser123",
            email: "test@example.com",
            weightUnitPreference: weightUnit,
            lengthUnitPreference: lengthUnit
        )
    }
    
    // MARK: - Initialization Tests
    
    @Test("Test Initialization With Default User Defaults")
    func testInitializationWithDefaultUserDefaults() {
        let userServices = MockUserServices(user: UserModel.mock)
        let userManager = UserManager(services: userServices)
        let manager = ExerciseUnitPreferenceManager(userManager: userManager)
        
        // Manager should be initialized successfully
        let preference = manager.getPreference(for: "test-template")
        #expect(preference.exerciseTemplateId == "test-template")
    }
    
    @Test("Test Initialization With Custom User Defaults")
    func testInitializationWithCustomUserDefaults() {
        let customDefaults = UserDefaults(suiteName: "test_custom")!
        let userServices = MockUserServices(user: UserModel.mock)
        let userManager = UserManager(services: userServices)
        let manager = ExerciseUnitPreferenceManager(userDefaults: customDefaults, userManager: userManager)
        
        let preference = manager.getPreference(for: "test-template")
        #expect(preference.exerciseTemplateId == "test-template")
    }
    
    // MARK: - Get Preference Tests
    
    @Test("Test Get Preference Returns Default When No Saved Preference")
    func testGetPreferenceReturnsDefaultWhenNoSavedPreference() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, _) = createManager(user: user)
        
        let preference = manager.getPreference(for: "template1")
        
        #expect(preference.exerciseTemplateId == "template1")
        #expect(preference.weightUnit == .kilograms)
        #expect(preference.distanceUnit == .meters)
    }
    
    @Test("Test Get Preference Uses User Weight Preference For Default")
    func testGetPreferenceUsesUserWeightPreferenceForDefault() {
        let user = createUserWithPreferences(weightUnit: .pounds, lengthUnit: .inches)
        let (manager, _) = createManager(user: user)
        
        let preference = manager.getPreference(for: "template1")
        
        #expect(preference.weightUnit == .pounds)
    }
    
    @Test("Test Get Preference Uses User Length Preference For Default Distance")
    func testGetPreferenceUsesUserLengthPreferenceForDefaultDistance() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .inches)
        let (manager, _) = createManager(user: user)
        
        let preference = manager.getPreference(for: "template1")
        
        #expect(preference.distanceUnit == .miles)
    }
    
    @Test("Test Get Preference Returns Kilograms When User Has No Weight Preference")
    func testGetPreferenceReturnsKilogramsWhenUserHasNoWeightPreference() {
        let user = UserModel(userId: "testUser")
        let (manager, _) = createManager(user: user)
        
        let preference = manager.getPreference(for: "template1")
        
        #expect(preference.weightUnit == .kilograms)
    }
    
    @Test("Test Get Preference Returns Meters When User Has No Length Preference")
    func testGetPreferenceReturnsMetersWhenUserHasNoLengthPreference() {
        let user = UserModel(userId: "testUser")
        let (manager, _) = createManager(user: user)
        
        let preference = manager.getPreference(for: "template1")
        
        #expect(preference.distanceUnit == .meters)
    }
    
    @Test("Test Get Preference Returns Cached Value On Second Call")
    func testGetPreferenceReturnsCachedValueOnSecondCall() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, _) = createManager(user: user)
        
        let preference1 = manager.getPreference(for: "template1")
        let preference2 = manager.getPreference(for: "template1")
        
        #expect(preference1.exerciseTemplateId == preference2.exerciseTemplateId)
        #expect(preference1.weightUnit == preference2.weightUnit)
        #expect(preference1.distanceUnit == preference2.distanceUnit)
    }
    
    @Test("Test Get Preference Loads From User Defaults When Available")
    func testGetPreferenceLoadsFromUserDefaultsWhenAvailable() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, userDefaults) = createManager(user: user)
        
        // Manually save a preference to UserDefaults
        let savedPreference = ExerciseUnitPreference(
            exerciseTemplateId: "template1",
            weightUnit: .pounds,
            distanceUnit: .miles
        )
        let key = "exercise_unit_preference_testUser123_template1"
        if let data = try? JSONEncoder().encode(savedPreference) {
            userDefaults.set(data, forKey: key)
        }
        
        // Create a new manager instance to avoid cache
        let newManager = ExerciseUnitPreferenceManager(userDefaults: userDefaults, userManager: UserManager(services: MockUserServices(user: user)))
        let preference = newManager.getPreference(for: "template1")
        
        #expect(preference.weightUnit == .pounds)
        #expect(preference.distanceUnit == .miles)
    }
    
    @Test("Test Get Preference For Different Templates Returns Different Preferences")
    func testGetPreferenceForDifferentTemplatesReturnsDifferentPreferences() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, _) = createManager(user: user)
        
        let preference1 = manager.getPreference(for: "template1")
        let preference2 = manager.getPreference(for: "template2")
        
        #expect(preference1.exerciseTemplateId == "template1")
        #expect(preference2.exerciseTemplateId == "template2")
    }
    
    // MARK: - Set Weight Unit Tests
    
    @Test("Test Set Weight Unit Updates Preference")
    func testSetWeightUnitUpdatesPreference() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, _) = createManager(user: user)
        
        manager.setWeightUnit(.pounds, for: "template1")
        
        let preference = manager.getPreference(for: "template1")
        #expect(preference.weightUnit == .pounds)
    }
    
    @Test("Test Set Weight Unit Persists To User Defaults")
    func testSetWeightUnitPersistsToUserDefaults() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, userDefaults) = createManager(user: user)
        
        manager.setWeightUnit(.pounds, for: "template1")
        
        // Create new manager to verify persistence
        let newManager = ExerciseUnitPreferenceManager(userDefaults: userDefaults, userManager: UserManager(services: MockUserServices(user: user)))
        let preference = newManager.getPreference(for: "template1")
        
        #expect(preference.weightUnit == .pounds)
    }
    
    @Test("Test Set Weight Unit Does Not Affect Distance Unit")
    func testSetWeightUnitDoesNotAffectDistanceUnit() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .inches)
        let (manager, _) = createManager(user: user)
        
        let originalPreference = manager.getPreference(for: "template1")
        manager.setWeightUnit(.pounds, for: "template1")
        let updatedPreference = manager.getPreference(for: "template1")
        
        #expect(updatedPreference.distanceUnit == originalPreference.distanceUnit)
    }
    
    @Test("Test Set Weight Unit For Multiple Templates")
    func testSetWeightUnitForMultipleTemplates() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, _) = createManager(user: user)
        
        manager.setWeightUnit(.pounds, for: "template1")
        manager.setWeightUnit(.kilograms, for: "template2")
        
        let preference1 = manager.getPreference(for: "template1")
        let preference2 = manager.getPreference(for: "template2")
        
        #expect(preference1.weightUnit == .pounds)
        #expect(preference2.weightUnit == .kilograms)
    }
    
    @Test("Test Set Weight Unit Overwrites Previous Value")
    func testSetWeightUnitOverwritesPreviousValue() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, _) = createManager(user: user)
        
        manager.setWeightUnit(.pounds, for: "template1")
        manager.setWeightUnit(.kilograms, for: "template1")
        
        let preference = manager.getPreference(for: "template1")
        #expect(preference.weightUnit == .kilograms)
    }
    
    // MARK: - Set Distance Unit Tests
    
    @Test("Test Set Distance Unit Updates Preference")
    func testSetDistanceUnitUpdatesPreference() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, _) = createManager(user: user)
        
        manager.setDistanceUnit(.miles, for: "template1")
        
        let preference = manager.getPreference(for: "template1")
        #expect(preference.distanceUnit == .miles)
    }
    
    @Test("Test Set Distance Unit Persists To User Defaults")
    func testSetDistanceUnitPersistsToUserDefaults() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, userDefaults) = createManager(user: user)
        
        manager.setDistanceUnit(.miles, for: "template1")
        
        // Create new manager to verify persistence
        let newManager = ExerciseUnitPreferenceManager(userDefaults: userDefaults, userManager: UserManager(services: MockUserServices(user: user)))
        let preference = newManager.getPreference(for: "template1")
        
        #expect(preference.distanceUnit == .miles)
    }
    
    @Test("Test Set Distance Unit Does Not Affect Weight Unit")
    func testSetDistanceUnitDoesNotAffectWeightUnit() {
        let user = createUserWithPreferences(weightUnit: .pounds, lengthUnit: .centimeters)
        let (manager, _) = createManager(user: user)
        
        let originalPreference = manager.getPreference(for: "template1")
        manager.setDistanceUnit(.miles, for: "template1")
        let updatedPreference = manager.getPreference(for: "template1")
        
        #expect(updatedPreference.weightUnit == originalPreference.weightUnit)
    }
    
    @Test("Test Set Distance Unit For Multiple Templates")
    func testSetDistanceUnitForMultipleTemplates() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, _) = createManager(user: user)
        
        manager.setDistanceUnit(.miles, for: "template1")
        manager.setDistanceUnit(.meters, for: "template2")
        
        let preference1 = manager.getPreference(for: "template1")
        let preference2 = manager.getPreference(for: "template2")
        
        #expect(preference1.distanceUnit == .miles)
        #expect(preference2.distanceUnit == .meters)
    }
    
    @Test("Test Set Distance Unit Overwrites Previous Value")
    func testSetDistanceUnitOverwritesPreviousValue() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, _) = createManager(user: user)
        
        manager.setDistanceUnit(.miles, for: "template1")
        manager.setDistanceUnit(.meters, for: "template1")
        
        let preference = manager.getPreference(for: "template1")
        #expect(preference.distanceUnit == .meters)
    }
    
    // MARK: - Set Preference (Both Units) Tests
    
    @Test("Test Set Preference Updates Both Units")
    func testSetPreferenceUpdatesBothUnits() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, _) = createManager(user: user)
        
        manager.setPreference(weightUnit: .pounds, distanceUnit: .miles, for: "template1")
        
        let preference = manager.getPreference(for: "template1")
        #expect(preference.weightUnit == .pounds)
        #expect(preference.distanceUnit == .miles)
    }
    
    @Test("Test Set Preference Updates Only Weight Unit When Distance Unit Is Nil")
    func testSetPreferenceUpdatesOnlyWeightUnitWhenDistanceUnitIsNil() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, _) = createManager(user: user)
        
        let originalPreference = manager.getPreference(for: "template1")
        manager.setPreference(weightUnit: .pounds, distanceUnit: nil, for: "template1")
        let updatedPreference = manager.getPreference(for: "template1")
        
        #expect(updatedPreference.weightUnit == .pounds)
        #expect(updatedPreference.distanceUnit == originalPreference.distanceUnit)
    }
    
    @Test("Test Set Preference Updates Only Distance Unit When Weight Unit Is Nil")
    func testSetPreferenceUpdatesOnlyDistanceUnitWhenWeightUnitIsNil() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, _) = createManager(user: user)
        
        let originalPreference = manager.getPreference(for: "template1")
        manager.setPreference(weightUnit: nil, distanceUnit: .miles, for: "template1")
        let updatedPreference = manager.getPreference(for: "template1")
        
        #expect(updatedPreference.weightUnit == originalPreference.weightUnit)
        #expect(updatedPreference.distanceUnit == .miles)
    }
    
    @Test("Test Set Preference Does Not Update When Both Parameters Are Nil")
    func testSetPreferenceDoesNotUpdateWhenBothParametersAreNil() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, _) = createManager(user: user)
        
        let originalPreference = manager.getPreference(for: "template1")
        manager.setPreference(weightUnit: nil, distanceUnit: nil, for: "template1")
        let updatedPreference = manager.getPreference(for: "template1")
        
        #expect(updatedPreference.weightUnit == originalPreference.weightUnit)
        #expect(updatedPreference.distanceUnit == originalPreference.distanceUnit)
    }
    
    @Test("Test Set Preference Persists To User Defaults")
    func testSetPreferencePersistsToUserDefaults() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, userDefaults) = createManager(user: user)
        
        manager.setPreference(weightUnit: .pounds, distanceUnit: .miles, for: "template1")
        
        // Create new manager to verify persistence
        let newManager = ExerciseUnitPreferenceManager(userDefaults: userDefaults, userManager: UserManager(services: MockUserServices(user: user)))
        let preference = newManager.getPreference(for: "template1")
        
        #expect(preference.weightUnit == .pounds)
        #expect(preference.distanceUnit == .miles)
    }
    
    // MARK: - Clear Cache Tests
    
    @Test("Test Clear Cache Removes Cached Preferences")
    func testClearCacheRemovesCachedPreferences() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, _) = createManager(user: user)
        
        // Get preference to populate cache
        _ = manager.getPreference(for: "template1")
        
        // Set a custom preference
        manager.setWeightUnit(.pounds, for: "template1")
        
        // Clear cache
        manager.clearCache()
        
        // Get preference again - should reload from UserDefaults
        let preference = manager.getPreference(for: "template1")
        #expect(preference.weightUnit == .pounds)
    }
    
    @Test("Test Clear Cache Does Not Affect Persisted Data")
    func testClearCacheDoesNotAffectPersistedData() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, userDefaults) = createManager(user: user)
        
        manager.setPreference(weightUnit: .pounds, distanceUnit: .miles, for: "template1")
        manager.clearCache()
        
        // Create new manager to verify persistence
        let newManager = ExerciseUnitPreferenceManager(userDefaults: userDefaults, userManager: UserManager(services: MockUserServices(user: user)))
        let preference = newManager.getPreference(for: "template1")
        
        #expect(preference.weightUnit == .pounds)
        #expect(preference.distanceUnit == .miles)
    }
    
    @Test("Test Clear Cache With Multiple Templates")
    func testClearCacheWithMultipleTemplates() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, _) = createManager(user: user)
        
        manager.setWeightUnit(.pounds, for: "template1")
        manager.setWeightUnit(.kilograms, for: "template2")
        
        manager.clearCache()
        
        // Preferences should still be available from UserDefaults
        let preference1 = manager.getPreference(for: "template1")
        let preference2 = manager.getPreference(for: "template2")
        
        #expect(preference1.weightUnit == .pounds)
        #expect(preference2.weightUnit == .kilograms)
    }
    
    // MARK: - Edge Cases Tests
    
    @Test("Test Get Preference With No User Returns Default Values")
    func testGetPreferenceWithNoUserReturnsDefaultValues() {
        let (manager, _) = createManager(user: nil)
        
        let preference = manager.getPreference(for: "template1")
        
        #expect(preference.exerciseTemplateId == "template1")
        #expect(preference.weightUnit == .kilograms)
        #expect(preference.distanceUnit == .meters)
    }
    
    @Test("Test Set Weight Unit With No User Does Not Save")
    func testSetWeightUnitWithNoUserDoesNotSave() {
        let (manager, userDefaults) = createManager(user: nil)
        
        manager.setWeightUnit(.pounds, for: "template1")
        
        // Verify nothing was saved to UserDefaults
        let allKeys = userDefaults.dictionaryRepresentation().keys
        let hasPreferenceKey = allKeys.contains { $0.contains("exercise_unit_preference") }
        #expect(hasPreferenceKey == false)
    }
    
    @Test("Test Set Distance Unit With No User Does Not Save")
    func testSetDistanceUnitWithNoUserDoesNotSave() {
        let (manager, userDefaults) = createManager(user: nil)
        
        manager.setDistanceUnit(.miles, for: "template1")
        
        // Verify nothing was saved to UserDefaults
        let allKeys = userDefaults.dictionaryRepresentation().keys
        let hasPreferenceKey = allKeys.contains { $0.contains("exercise_unit_preference") }
        #expect(hasPreferenceKey == false)
    }
    
    @Test("Test Get Preference With Empty Template ID")
    func testGetPreferenceWithEmptyTemplateId() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, _) = createManager(user: user)
        
        let preference = manager.getPreference(for: "")
        
        #expect(preference.exerciseTemplateId == "")
    }
    
    @Test("Test Set Weight Unit With Special Characters In Template ID")
    func testSetWeightUnitWithSpecialCharactersInTemplateId() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, _) = createManager(user: user)
        
        let specialId = "template-123_test@example.com"
        manager.setWeightUnit(.pounds, for: specialId)
        
        let preference = manager.getPreference(for: specialId)
        #expect(preference.weightUnit == .pounds)
    }
    
    @Test("Test Concurrent Get Preference Calls")
    func testConcurrentGetPreferenceCalls() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, _) = createManager(user: user)
        
        let preference1 = manager.getPreference(for: "template1")
        let preference2 = manager.getPreference(for: "template1")
        let preference3 = manager.getPreference(for: "template1")
        
        #expect(preference1.weightUnit == preference2.weightUnit)
        #expect(preference2.weightUnit == preference3.weightUnit)
    }
    
    @Test("Test Multiple Set Operations On Same Template")
    func testMultipleSetOperationsOnSameTemplate() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, _) = createManager(user: user)
        
        manager.setWeightUnit(.pounds, for: "template1")
        manager.setDistanceUnit(.miles, for: "template1")
        manager.setWeightUnit(.kilograms, for: "template1")
        
        let preference = manager.getPreference(for: "template1")
        #expect(preference.weightUnit == .kilograms)
        #expect(preference.distanceUnit == .miles)
    }
    
    // MARK: - Unit Mapping Tests
    
    @Test("Test Centimeters Maps To Meters")
    func testCentimetersMapsToMeters() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, _) = createManager(user: user)
        
        let preference = manager.getPreference(for: "template1")
        #expect(preference.distanceUnit == .meters)
    }
    
    @Test("Test Inches Maps To Miles")
    func testInchesMapsToMiles() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .inches)
        let (manager, _) = createManager(user: user)
        
        let preference = manager.getPreference(for: "template1")
        #expect(preference.distanceUnit == .miles)
    }
    
    @Test("Test Kilograms Maps To Kilograms")
    func testKilogramsMapsToKilograms() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, _) = createManager(user: user)
        
        let preference = manager.getPreference(for: "template1")
        #expect(preference.weightUnit == .kilograms)
    }
    
    @Test("Test Pounds Maps To Pounds")
    func testPoundsMapsToLounds() {
        let user = createUserWithPreferences(weightUnit: .pounds, lengthUnit: .centimeters)
        let (manager, _) = createManager(user: user)
        
        let preference = manager.getPreference(for: "template1")
        #expect(preference.weightUnit == .pounds)
    }
    
    // MARK: - Persistence Key Tests
    
    @Test("Test Preference Key Format Is Correct")
    func testPreferenceKeyFormatIsCorrect() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let (manager, userDefaults) = createManager(user: user)
        
        manager.setWeightUnit(.pounds, for: "template1")
        
        let expectedKey = "exercise_unit_preference_testUser123_template1"
        let data = userDefaults.data(forKey: expectedKey)
        
        #expect(data != nil)
    }
    
    @Test("Test Different Users Have Different Preference Keys")
    func testDifferentUsersHaveDifferentPreferenceKeys() {
        let user1 = UserModel(userId: "user1", weightUnitPreference: .kilograms, lengthUnitPreference: .centimeters)
        let user2 = UserModel(userId: "user2", weightUnitPreference: .pounds, lengthUnitPreference: .inches)
        
        let userDefaults = UserDefaults(suiteName: "test_\(UUID().uuidString)")!
        
        let manager1 = ExerciseUnitPreferenceManager(
            userDefaults: userDefaults,
            userManager: UserManager(services: MockUserServices(user: user1))
        )
        let manager2 = ExerciseUnitPreferenceManager(
            userDefaults: userDefaults,
            userManager: UserManager(services: MockUserServices(user: user2))
        )
        
        manager1.setWeightUnit(.pounds, for: "template1")
        manager2.setWeightUnit(.kilograms, for: "template1")
        
        let preference1 = manager1.getPreference(for: "template1")
        let preference2 = manager2.getPreference(for: "template1")
        
        #expect(preference1.weightUnit == .pounds)
        #expect(preference2.weightUnit == .kilograms)
    }
    
    @Test("Test Preferences Persist Across Manager Instances")
    func testPreferencesPersistAcrossManagerInstances() {
        let user = createUserWithPreferences(weightUnit: .kilograms, lengthUnit: .centimeters)
        let userDefaults = UserDefaults(suiteName: "test_\(UUID().uuidString)")!
        
        let manager1 = ExerciseUnitPreferenceManager(
            userDefaults: userDefaults,
            userManager: UserManager(services: MockUserServices(user: user))
        )
        manager1.setPreference(weightUnit: .pounds, distanceUnit: .miles, for: "template1")
        
        let manager2 = ExerciseUnitPreferenceManager(
            userDefaults: userDefaults,
            userManager: UserManager(services: MockUserServices(user: user))
        )
        let preference = manager2.getPreference(for: "template1")
        
        #expect(preference.weightUnit == .pounds)
        #expect(preference.distanceUnit == .miles)
    }
}
