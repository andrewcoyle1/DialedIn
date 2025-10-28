//
//  UserWeightManagerTests.swift
//  DialedInTests
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Testing
import Foundation

struct UserWeightManagerTests {
    
    // MARK: - Initialization Tests
    
    @Test("Test Initialization With Mock Services")
    func testInitializationWithMockServices() {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        #expect(manager.weightHistory.isEmpty)
        #expect(manager.isLoading == false)
    }
    
    // MARK: - Log Weight Tests
    
    @Test("Test Log Weight Succeeds")
    func testLogWeightSucceeds() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        let userId = "testUser"
        let weightKg = 75.5
        let date = Date()
        let notes = "Morning weight"
        
        try await manager.logWeight(weightKg, date: date, notes: notes, userId: userId)
        
        #expect(manager.weightHistory.count == 1)
        #expect(manager.weightHistory[0].weightKg == weightKg)
        #expect(manager.weightHistory[0].userId == userId)
        #expect(manager.weightHistory[0].notes == notes)
        #expect(manager.weightHistory[0].source == .manual)
    }
    
    @Test("Test Log Weight Updates Loading State")
    func testLogWeightUpdatesLoadingState() async throws {
        let services = MockUserWeightServices(delay: 0.1)
        let manager = UserWeightManager(services: services)
        
        let task = Task {
            try await manager.logWeight(75.5, userId: "testUser")
        }
        
        // Wait for the operation to finish, then isLoading should be false (defer)
        try await task.value
        #expect(manager.isLoading == false)
    }
    
    @Test("Test Log Weight Multiple Entries Sorts By Date")
    func testLogWeightMultipleEntriesSortsByDate() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        let userId = "testUser"
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        
        // Log in non-chronological order
        try await manager.logWeight(75.0, date: yesterday, userId: userId)
        try await manager.logWeight(76.0, date: today, userId: userId)
        try await manager.logWeight(74.0, date: twoDaysAgo, userId: userId)
        
        #expect(manager.weightHistory.count == 3)
        // Should be sorted by date descending (most recent first)
        #expect(manager.weightHistory[0].date >= manager.weightHistory[1].date)
        #expect(manager.weightHistory[1].date >= manager.weightHistory[2].date)
        #expect(manager.weightHistory[0].weightKg == 76.0)
        #expect(manager.weightHistory[2].weightKg == 74.0)
    }
    
    @Test("Test Log Weight With Default Date")
    func testLogWeightWithDefaultDate() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        try await manager.logWeight(75.5, userId: "testUser")
        
        #expect(manager.weightHistory.count == 1)
        // Date should be approximately now
        let timeDiff = abs(manager.weightHistory[0].date.timeIntervalSinceNow)
        #expect(timeDiff < 2) // Within 2 seconds
    }
    
    @Test("Test Log Weight Without Notes")
    func testLogWeightWithoutNotes() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        try await manager.logWeight(75.5, userId: "testUser")
        
        #expect(manager.weightHistory[0].notes == nil)
    }
    
    @Test("Test Log Weight Throws Error When Service Fails")
    func testLogWeightThrowsErrorWhenServiceFails() async {
        let services = MockUserWeightServices(showError: true)
        let manager = UserWeightManager(services: services)
        
        await #expect(throws: URLError.self) {
            try await manager.logWeight(75.5, userId: "testUser")
        }
        
        // History should remain empty on error
        #expect(manager.weightHistory.isEmpty)
    }
    
    // MARK: - Get Weight History Tests
    
    @Test("Test Get Weight History From Remote When Cache Empty")
    func testGetWeightHistoryFromRemoteWhenCacheEmpty() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        // First log some weights
        try await manager.logWeight(75.0, userId: "testUser")
        try await manager.logWeight(76.0, userId: "testUser")
        
        // Create new manager with fresh state
        let newManager = UserWeightManager(services: services)
        
        let history = try await newManager.getWeightHistory(userId: "testUser")
        
        #expect(history.count == 2)
        #expect(newManager.weightHistory.count == 2)
    }
    
    @Test("Test Get Weight History With Limit")
    func testGetWeightHistoryWithLimit() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        // Log multiple weights
        for iteration in 1...5 {
            try await manager.logWeight(Double(70 + iteration), userId: "testUser")
        }
        
        let newManager = UserWeightManager(services: services)
        let history = try await newManager.getWeightHistory(userId: "testUser", limit: 3)
        
        #expect(history.count == 3)
    }
    
    @Test("Test Get Weight History Without Limit")
    func testGetWeightHistoryWithoutLimit() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        // Log multiple weights
        for iteration in 1...5 {
            try await manager.logWeight(Double(70 + iteration), userId: "testUser")
        }
        
        let newManager = UserWeightManager(services: services)
        let history = try await newManager.getWeightHistory(userId: "testUser", limit: nil)
        
        #expect(history.count == 5)
    }
    
    @Test("Test Get Weight History Updates Manager State")
    func testGetWeightHistoryUpdatesManagerState() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        try await manager.logWeight(75.0, userId: "testUser")
        
        let newManager = UserWeightManager(services: services)
        _ = try await newManager.getWeightHistory(userId: "testUser")
        
        #expect(!newManager.weightHistory.isEmpty)
    }
    
    @Test("Test Get Weight History Returns Empty When No Entries")
    func testGetWeightHistoryReturnsEmptyWhenNoEntries() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        let history = try await manager.getWeightHistory(userId: "testUser")
        
        #expect(history.isEmpty)
    }
    
    @Test("Test Get Weight History Updates Loading State")
    func testGetWeightHistoryUpdatesLoadingState() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        _ = try await manager.getWeightHistory(userId: "testUser")
        
        #expect(manager.isLoading == false)
    }
    
    @Test("Test Get Weight History Throws Error When Service Fails")
    func testGetWeightHistoryThrowsErrorWhenServiceFails() async {
        let services = MockUserWeightServices(showError: true)
        let manager = UserWeightManager(services: services)
        
        await #expect(throws: URLError.self) {
            try await manager.getWeightHistory(userId: "testUser")
        }
    }
    
    // MARK: - Get Latest Weight Tests
    
    @Test("Test Get Latest Weight Returns First Entry From History")
    func testGetLatestWeightReturnsFirstEntryFromHistory() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        try await manager.logWeight(75.0, date: yesterday, userId: "testUser")
        try await manager.logWeight(76.0, date: today, userId: "testUser")
        
        let latest = try await manager.getLatestWeight(userId: "testUser")
        
        #expect(latest != nil)
        #expect(latest?.weightKg == 76.0)
    }
    
    @Test("Test Get Latest Weight Fetches From Remote When History Empty")
    func testGetLatestWeightFetchesFromRemoteWhenHistoryEmpty() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        try await manager.logWeight(75.0, userId: "testUser")
        
        let newManager = UserWeightManager(services: services)
        let latest = try await newManager.getLatestWeight(userId: "testUser")
        
        #expect(latest != nil)
        #expect(latest?.weightKg == 75.0)
    }
    
    @Test("Test Get Latest Weight Returns Nil When No Entries")
    func testGetLatestWeightReturnsNilWhenNoEntries() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        let latest = try await manager.getLatestWeight(userId: "testUser")
        
        #expect(latest == nil)
    }
    
    @Test("Test Get Latest Weight With Multiple Entries")
    func testGetLatestWeightWithMultipleEntries() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        for iteration in 1...5 {
            let date = Calendar.current.date(byAdding: .day, value: -iteration, to: Date())!
            try await manager.logWeight(Double(70 + iteration), date: date, userId: "testUser")
        }
        
        let latest = try await manager.getLatestWeight(userId: "testUser")
        
        #expect(latest != nil)
        // Most recent should be the one with highest date (least days ago)
        #expect(latest?.weightKg == 71.0)
    }
    
    // MARK: - Delete Weight Entry Tests
    
    @Test("Test Delete Weight Entry Removes From History")
    func testDeleteWeightEntryRemovesFromHistory() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        try await manager.logWeight(75.0, userId: "testUser")
        try await manager.logWeight(76.0, userId: "testUser")
        
        #expect(manager.weightHistory.count == 2)
        
        let idToDelete = manager.weightHistory[0].id
        try await manager.deleteWeightEntry(id: idToDelete, userId: "testUser")
        
        #expect(manager.weightHistory.count == 1)
        #expect(manager.weightHistory.first { $0.id == idToDelete } == nil)
    }
    
    @Test("Test Delete Weight Entry Updates Loading State")
    func testDeleteWeightEntryUpdatesLoadingState() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        try await manager.logWeight(75.0, userId: "testUser")
        let idToDelete = manager.weightHistory[0].id
        
        try await manager.deleteWeightEntry(id: idToDelete, userId: "testUser")
        
        #expect(manager.isLoading == false)
    }
    
    @Test("Test Delete Weight Entry Throws Error When Service Fails")
    func testDeleteWeightEntryThrowsErrorWhenServiceFails() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        try await manager.logWeight(75.0, userId: "testUser")
        let idToDelete = manager.weightHistory[0].id
        
        // Create a new manager with error-throwing services
        let errorServices = MockUserWeightServices(showError: true)
        let errorManager = UserWeightManager(services: errorServices)
        
        await #expect(throws: URLError.self) {
            try await errorManager.deleteWeightEntry(id: idToDelete, userId: "testUser")
        }
    }
    
    @Test("Test Delete Non Existent Entry Does Not Affect History")
    func testDeleteNonExistentEntryDoesNotAffectHistory() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        try await manager.logWeight(75.0, userId: "testUser")
        try await manager.logWeight(76.0, userId: "testUser")
        
        #expect(manager.weightHistory.count == 2)
        
        try await manager.deleteWeightEntry(id: "non-existent-id", userId: "testUser")
        
        #expect(manager.weightHistory.count == 2)
    }
    
    @Test("Test Delete All Entries Leaves History Empty")
    func testDeleteAllEntriesLeavesHistoryEmpty() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        try await manager.logWeight(75.0, userId: "testUser")
        try await manager.logWeight(76.0, userId: "testUser")
        
        let ids = manager.weightHistory.map { $0.id }
        
        for id in ids {
            try await manager.deleteWeightEntry(id: id, userId: "testUser")
        }
        
        #expect(manager.weightHistory.isEmpty)
    }
    
    // MARK: - Refresh Tests
    
    @Test("Test Refresh Updates Weight History From Remote")
    func testRefreshUpdatesWeightHistoryFromRemote() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        try await manager.logWeight(75.0, userId: "testUser")
        try await manager.logWeight(76.0, userId: "testUser")
        
        let newManager = UserWeightManager(services: services)
        #expect(newManager.weightHistory.isEmpty)
        
        try await newManager.refresh(userId: "testUser")
        
        #expect(newManager.weightHistory.count == 2)
    }
    
    @Test("Test Refresh Overwrites Local History")
    func testRefreshOverwritesLocalHistory() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        try await manager.logWeight(75.0, userId: "testUser")
        
        // Manually add an entry to local cache without saving to remote
        let unsynced = WeightEntry(userId: "testUser", weightKg: 99.0, date: Date())
        try await services.local.saveWeightEntry(unsynced)
        _ = try await manager.getWeightHistory(userId: "testUser")
        #expect(manager.weightHistory.count == 2)
        
        try await manager.refresh(userId: "testUser")
        
        // After refresh, should only have the one saved entry
        #expect(manager.weightHistory.count == 1)
        #expect(manager.weightHistory[0].weightKg == 75.0)
    }
    
    @Test("Test Refresh With No Remote Entries Clears History")
    func testRefreshWithNoRemoteEntriesClearsHistory() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        // Manually add an entry to local cache
        let localOnly = WeightEntry(userId: "testUser", weightKg: 75.0, date: Date())
        try await services.local.saveWeightEntry(localOnly)
        _ = try await manager.getWeightHistory(userId: "testUser")
        #expect(manager.weightHistory.count == 1)
        
        try await manager.refresh(userId: "testUser")
        
        #expect(manager.weightHistory.isEmpty)
    }
    
    @Test("Test Refresh Throws Error When Service Fails")
    func testRefreshThrowsErrorWhenServiceFails() async {
        let services = MockUserWeightServices(showError: true)
        let manager = UserWeightManager(services: services)
        
        await #expect(throws: URLError.self) {
            try await manager.refresh(userId: "testUser")
        }
    }
    
    @Test("Test Refresh Updates Local Cache")
    func testRefreshUpdatesLocalCache() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        try await manager.logWeight(75.0, userId: "testUser")
        try await manager.logWeight(76.0, userId: "testUser")
        
        let newManager = UserWeightManager(services: services)
        try await newManager.refresh(userId: "testUser")
        
        // Verify cache was updated by checking if new manager can retrieve from local
        let thirdManager = UserWeightManager(services: services)
        let history = try await thirdManager.getWeightHistory(userId: "testUser")
        
        #expect(history.count == 2)
    }
    
    // MARK: - Multiple Users Tests
    
    @Test("Test Weight History Isolated By User ID")
    func testWeightHistoryIsolatedByUserId() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        try await manager.logWeight(75.0, userId: "user1")
        try await manager.logWeight(80.0, userId: "user2")
        
        let user1History = try await manager.getWeightHistory(userId: "user1")
        let user2History = try await manager.getWeightHistory(userId: "user2")
        
        #expect(user1History.count == 1)
        #expect(user2History.count == 1)
        #expect(user1History[0].weightKg == 75.0)
        #expect(user2History[0].weightKg == 80.0)
    }
    
    @Test("Test Delete Does Not Affect Other Users")
    func testDeleteDoesNotAffectOtherUsers() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        try await manager.logWeight(75.0, userId: "user1")
        try await manager.logWeight(80.0, userId: "user2")
        
        let user1History = try await manager.getWeightHistory(userId: "user1")
        let idToDelete = user1History[0].id
        
        try await manager.deleteWeightEntry(id: idToDelete, userId: "user1")
        
        let user1HistoryAfter = try await manager.getWeightHistory(userId: "user1")
        let user2HistoryAfter = try await manager.getWeightHistory(userId: "user2")
        
        #expect(user1HistoryAfter.isEmpty)
        #expect(user2HistoryAfter.count == 1)
    }
    
    // MARK: - Edge Cases Tests
    
    @Test("Test Log Weight With Very Small Weight")
    func testLogWeightWithVerySmallWeight() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        try await manager.logWeight(0.1, userId: "testUser")
        
        #expect(manager.weightHistory[0].weightKg == 0.1)
    }
    
    @Test("Test Log Weight With Very Large Weight")
    func testLogWeightWithVeryLargeWeight() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        try await manager.logWeight(500.0, userId: "testUser")
        
        #expect(manager.weightHistory[0].weightKg == 500.0)
    }
    
    @Test("Test Log Weight With Same Date Multiple Times")
    func testLogWeightWithSameDateMultipleTimes() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        let date = Date()
        try await manager.logWeight(75.0, date: date, userId: "testUser")
        try await manager.logWeight(76.0, date: date, userId: "testUser")
        try await manager.logWeight(77.0, date: date, userId: "testUser")
        
        #expect(manager.weightHistory.count == 3)
    }
    
    @Test("Test Get Latest Weight After Deletion")
    func testGetLatestWeightAfterDeletion() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        try await manager.logWeight(75.0, date: yesterday, userId: "testUser")
        try await manager.logWeight(76.0, date: Date(), userId: "testUser")
        
        let latestBefore = try await manager.getLatestWeight(userId: "testUser")
        #expect(latestBefore?.weightKg == 76.0)
        
        // Delete the latest entry
        let idToDelete = manager.weightHistory[0].id
        try await manager.deleteWeightEntry(id: idToDelete, userId: "testUser")
        
        let latestAfter = try await manager.getLatestWeight(userId: "testUser")
        #expect(latestAfter?.weightKg == 75.0)
    }
    
    @Test("Test Weight History Maintains Sort After Multiple Operations")
    func testWeightHistoryMaintainsSortAfterMultipleOperations() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        let today = Date()
        let dates = (0...4).map { Calendar.current.date(byAdding: .day, value: -$0, to: today)! }
        
        // Log in mixed order
        try await manager.logWeight(75.0, date: dates[2], userId: "testUser")
        try await manager.logWeight(76.0, date: dates[0], userId: "testUser")
        try await manager.logWeight(74.0, date: dates[4], userId: "testUser")
        try await manager.logWeight(75.5, date: dates[1], userId: "testUser")
        try await manager.logWeight(74.5, date: dates[3], userId: "testUser")
        
        // Verify sorted by date descending
        for iteration in 0..<(manager.weightHistory.count - 1) {
            #expect(manager.weightHistory[iteration].date >= manager.weightHistory[iteration + 1].date)
        }
    }
    
    // MARK: - Concurrent Operations Tests
    
    @Test("Test Multiple Log Weight Operations In Sequence")
    func testMultipleLogWeightOperationsInSequence() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        for iteration in 1...10 {
            try await manager.logWeight(Double(70 + iteration), userId: "testUser")
        }
        
        #expect(manager.weightHistory.count == 10)
    }
    
    @Test("Test Get History After Multiple Logs")
    func testGetHistoryAfterMultipleLogs() async throws {
        let services = MockUserWeightServices()
        let manager = UserWeightManager(services: services)
        
        try await manager.logWeight(75.0, userId: "testUser")
        try await manager.logWeight(76.0, userId: "testUser")
        try await manager.logWeight(77.0, userId: "testUser")
        
        let history = try await manager.getWeightHistory(userId: "testUser")
        
        #expect(history.count == 3)
    }
}
