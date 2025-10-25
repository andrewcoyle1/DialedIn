//
//  WeightEntryTest.swift
//  DialedInTests
//
//  Created by Andrew Coyle on 25/10/2025.
//

import Testing
import Foundation

struct WeightEntryTest {

    // MARK: - Initialization Tests
    
    @Test("Test Basic Initialisation")
    func testBasicInitialization() {
        let randomUserId = String.random
        let randomWeight = Double.random(in: 50...150)
        let randomDate = Date.random
        
        let entry = WeightEntry(
            userId: randomUserId,
            weightKg: randomWeight,
            date: randomDate
        )
        
        #expect(entry.userId == randomUserId)
        #expect(entry.weightKg == randomWeight)
        #expect(entry.date == randomDate)
        #expect(entry.source == .manual)
        #expect(entry.notes == nil)
    }
    
    @Test("Test Initialization With All Properties")
    func testInitializationWithAllProperties() {
        let testData = createWeightEntryTestData()
        let entry = createWeightEntryWithAllProperties(data: testData)
        verifyWeightEntryProperties(entry: entry, data: testData)
    }
    
    private func createWeightEntryTestData() -> WeightEntryTestData {
        return WeightEntryTestData(
            id: String.random,
            userId: String.random,
            weightKg: Double.random(in: 50...150),
            date: Date.random,
            source: .manual,
            notes: String.random,
            createdAt: Date.random
        )
    }
    
    private struct WeightEntryTestData {
        let id: String
        let userId: String
        let weightKg: Double
        let date: Date
        let source: WeightEntry.WeightSource
        let notes: String?
        let createdAt: Date
    }
    
    private func createWeightEntryWithAllProperties(data: WeightEntryTestData) -> WeightEntry {
        return WeightEntry(
            id: data.id,
            userId: data.userId,
            weightKg: data.weightKg,
            date: data.date,
            source: data.source,
            notes: data.notes,
            createdAt: data.createdAt
        )
    }
    
    private func verifyWeightEntryProperties(entry: WeightEntry, data: WeightEntryTestData) {
        #expect(entry.id == data.id)
        #expect(entry.userId == data.userId)
        #expect(entry.weightKg == data.weightKg)
        #expect(entry.date == data.date)
        #expect(entry.source == data.source)
        #expect(entry.notes == data.notes)
        #expect(entry.createdAt == data.createdAt)
    }
    
    @Test("Test Initialization With Nil Notes")
    func testInitializationWithNilNotes() {
        let randomUserId = String.random
        let randomWeight = Double.random(in: 50...150)
        let randomDate = Date.random
        
        let entry = WeightEntry(
            userId: randomUserId,
            weightKg: randomWeight,
            date: randomDate,
            source: .healthkit,
            notes: nil
        )
        
        #expect(entry.userId == randomUserId)
        #expect(entry.weightKg == randomWeight)
        #expect(entry.date == randomDate)
        #expect(entry.source == .healthkit)
        #expect(entry.notes == nil)
    }
    
    @Test("Test Initialization With Different Sources")
    func testInitializationWithDifferentSources() {
        let randomUserId = String.random
        let randomWeight = Double.random(in: 50...150)
        let randomDate = Date.random
        
        let manualEntry = WeightEntry(
            userId: randomUserId,
            weightKg: randomWeight,
            date: randomDate,
            source: .manual
        )
        
        let healthKitEntry = WeightEntry(
            userId: randomUserId,
            weightKg: randomWeight,
            date: randomDate,
            source: .healthkit
        )
        
        let importedEntry = WeightEntry(
            userId: randomUserId,
            weightKg: randomWeight,
            date: randomDate,
            source: .imported
        )
        
        #expect(manualEntry.source == .manual)
        #expect(healthKitEntry.source == .healthkit)
        #expect(importedEntry.source == .imported)
    }
    
    // MARK: - Equatable Tests
    
    @Test("Test Equality With Same Properties")
    func testEqualityWithSameProperties() {
        let randomId = String.random
        let randomUserId = String.random
        let randomWeight = Double.random(in: 50...150)
        let randomDate = Date.random
        let randomCreatedAt = Date.random
        
        let entry1 = WeightEntry(
            id: randomId,
            userId: randomUserId,
            weightKg: randomWeight,
            date: randomDate,
            source: .manual,
            notes: "Test notes",
            createdAt: randomCreatedAt
        )
        
        let entry2 = WeightEntry(
            id: randomId,
            userId: randomUserId,
            weightKg: randomWeight,
            date: randomDate,
            source: .manual,
            notes: "Test notes",
            createdAt: randomCreatedAt
        )
        
        #expect(entry1 == entry2)
    }
    
    @Test("Test Inequality With Different ID")
    func testInequalityWithDifferentId() {
        let randomUserId = String.random
        let randomWeight = Double.random(in: 50...150)
        let randomDate = Date.random
        let randomCreatedAt = Date.random
        
        let entry1 = WeightEntry(
            id: String.random,
            userId: randomUserId,
            weightKg: randomWeight,
            date: randomDate,
            createdAt: randomCreatedAt
        )
        
        let entry2 = WeightEntry(
            id: String.random,
            userId: randomUserId,
            weightKg: randomWeight,
            date: randomDate,
            createdAt: randomCreatedAt
        )
        
        #expect(entry1 != entry2)
    }
    
    @Test("Test Inequality With Different Weight")
    func testInequalityWithDifferentWeight() {
        let randomId = String.random
        let randomUserId = String.random
        let randomDate = Date.random
        let randomCreatedAt = Date.random
        
        let entry1 = WeightEntry(
            id: randomId,
            userId: randomUserId,
            weightKg: 70.0,
            date: randomDate,
            createdAt: randomCreatedAt
        )
        
        let entry2 = WeightEntry(
            id: randomId,
            userId: randomUserId,
            weightKg: 75.0,
            date: randomDate,
            createdAt: randomCreatedAt
        )
        
        #expect(entry1 != entry2)
    }
    
    @Test("Test Inequality With Different Date")
    func testInequalityWithDifferentDate() {
        let randomId = String.random
        let randomUserId = String.random
        let randomWeight = Double.random(in: 50...150)
        let randomCreatedAt = Date.random
        
        let entry1 = WeightEntry(
            id: randomId,
            userId: randomUserId,
            weightKg: randomWeight,
            date: Date.random,
            createdAt: randomCreatedAt
        )
        
        let entry2 = WeightEntry(
            id: randomId,
            userId: randomUserId,
            weightKg: randomWeight,
            date: Date.random,
            createdAt: randomCreatedAt
        )
        
        #expect(entry1 != entry2)
    }
    
    // MARK: - Codable Tests
    
    @Test("Test Encoding And Decoding")
    func testEncodingAndDecoding() throws {
        let randomId = String.random
        let randomUserId = String.random
        let randomWeight = Double.random(in: 50...150)
        let randomDate = Date.random
        let createdAt = Date.random
        
        let originalEntry = WeightEntry(
            id: randomId,
            userId: randomUserId,
            weightKg: randomWeight,
            date: randomDate,
            source: .healthkit,
            notes: "Test notes",
            createdAt: createdAt
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let encodedData = try encoder.encode(originalEntry)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let decodedEntry = try decoder.decode(WeightEntry.self, from: encodedData)
        
        // With millisecondsSince1970, dates preserve sub-second precision
        #expect(decodedEntry.id == originalEntry.id)
        #expect(decodedEntry.userId == originalEntry.userId)
        #expect(decodedEntry.weightKg == originalEntry.weightKg)
        #expect(abs(decodedEntry.date.timeIntervalSince1970 - originalEntry.date.timeIntervalSince1970) < 0.001)
        #expect(decodedEntry.source == originalEntry.source)
        #expect(decodedEntry.notes == originalEntry.notes)
        #expect(abs(decodedEntry.createdAt.timeIntervalSince1970 - originalEntry.createdAt.timeIntervalSince1970) < 0.001)
    }
    
    @Test("Test Encoding Nil Notes")
    func testEncodingNilNotes() throws {
        let randomId = String.random
        let randomUserId = String.random
        let randomWeight = Double.random(in: 50...150)
        let randomDate = Date.random
        
        let entry = WeightEntry(
            id: randomId,
            userId: randomUserId,
            weightKg: randomWeight,
            date: randomDate,
            source: .manual,
            notes: nil
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let encodedData = try encoder.encode(entry)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let decodedEntry = try decoder.decode(WeightEntry.self, from: encodedData)
        
        #expect(decodedEntry.id == randomId)
        #expect(decodedEntry.userId == randomUserId)
        #expect(decodedEntry.weightKg == randomWeight)
        #expect(decodedEntry.notes == nil)
    }
    
    @Test("Test Coding Keys Mapping")
    func testCodingKeysMapping() throws {
        let randomId = String.random
        let randomUserId = String.random
        let randomWeight = Double.random(in: 50...150)
        let randomDate = Date.random
        
        let entry = WeightEntry(
            id: randomId,
            userId: randomUserId,
            weightKg: randomWeight,
            date: randomDate,
            source: .manual,
            notes: "Test notes"
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let encodedData = try encoder.encode(entry)
        
        let json = try JSONSerialization.jsonObject(with: encodedData) as? [String: Any]
        
        #expect(json?["id"] as? String == randomId)
        #expect(json?["user_id"] as? String == randomUserId)
        #expect(json?["weight_kg"] as? Double == randomWeight)
        #expect(json?["source"] as? String == "manual")
        #expect(json?["notes"] as? String == "Test notes")
        #expect(json?["created_at"] != nil)
    }
    
    // MARK: - WeightSource Enum Tests
    
    @Test("Test WeightSource Raw Values")
    func testWeightSourceRawValues() {
        #expect(WeightEntry.WeightSource.manual.rawValue == "manual")
        #expect(WeightEntry.WeightSource.healthkit.rawValue == "healthkit")
        #expect(WeightEntry.WeightSource.imported.rawValue == "imported")
    }
    
    @Test("Test WeightSource Display Names")
    func testWeightSourceDisplayNames() {
        #expect(WeightEntry.WeightSource.manual.displayName == "Manual Entry")
        #expect(WeightEntry.WeightSource.healthkit.displayName == "HealthKit")
        #expect(WeightEntry.WeightSource.imported.displayName == "Imported")
    }
    
    // MARK: - Mock Tests
    
    @Test("Test Mock Property")
    func testMockProperty() {
        let mock = WeightEntry.mock(weightKg: 75.0, daysAgo: 0)
        
        #expect(mock.userId == "mockUser")
        #expect(mock.weightKg == 75.0)
        #expect(mock.source == .manual)
    }
    
    @Test("Test Mock With Different Days Ago")
    func testMockWithDifferentDaysAgo() {
        let mock = WeightEntry.mock(weightKg: 70.0, daysAgo: 7)
        
        #expect(mock.weightKg == 70.0)
        // Verify the date is approximately 7 days ago
        let dateDifference = Calendar.current.dateComponents([.day], from: mock.date, to: Date()).day ?? 0
        #expect(dateDifference == 7)
    }
    
    @Test("Test Mocks Property")
    func testMocksProperty() {
        let mocks = WeightEntry.mocks
        
        #expect(mocks.count == 5)
        #expect(mocks[0].weightKg == 72.0)
        #expect(mocks[1].weightKg == 72.3)
        #expect(mocks[2].weightKg == 72.8)
        #expect(mocks[3].weightKg == 73.2)
        #expect(mocks[4].weightKg == 73.5)
    }
    
    @Test("Test Mocks Have Correct Day Offsets")
    func testMocksHaveCorrectDayOffsets() {
        let mocks = WeightEntry.mocks
        
        #expect(mocks[0].weightKg == 72.0) // daysAgo: 0
        #expect(mocks[1].weightKg == 72.3) // daysAgo: 7
        #expect(mocks[2].weightKg == 72.8) // daysAgo: 14
        #expect(mocks[3].weightKg == 73.2) // daysAgo: 21
        #expect(mocks[4].weightKg == 73.5) // daysAgo: 28
    }
    
    @Test("Test Mocks Are All From Same User")
    func testMocksAreAllFromSameUser() {
        let mocks = WeightEntry.mocks
        
        for mock in mocks {
            #expect(mock.userId == "mockUser")
        }
    }
    
    @Test("Test Mocks All Have Manual Source")
    func testMocksAllHaveManualSource() {
        let mocks = WeightEntry.mocks
        
        for mock in mocks {
            #expect(mock.source == .manual)
        }
    }
    
    // MARK: - Identifiable Tests
    
    @Test("Test WeightEntry Is Identifiable")
    func testWeightEntryIsIdentifiable() {
        let randomId = String.random
        let randomUserId = String.random
        let randomWeight = Double.random(in: 50...150)
        let randomDate = Date.random
        
        let entry = WeightEntry(
            id: randomId,
            userId: randomUserId,
            weightKg: randomWeight,
            date: randomDate
        )
        
        #expect(entry.id == randomId)
    }
    
    @Test("Test Default ID Generation")
    func testDefaultIdGeneration() {
        let randomUserId = String.random
        let randomWeight = Double.random(in: 50...150)
        let randomDate = Date.random
        
        let entry1 = WeightEntry(
            userId: randomUserId,
            weightKg: randomWeight,
            date: randomDate
        )
        
        let entry2 = WeightEntry(
            userId: randomUserId,
            weightKg: randomWeight,
            date: randomDate
        )
        
        // Both should have valid UUIDs, but different ones
        #expect(entry1.id != entry2.id)
        #expect(!entry1.id.isEmpty)
        #expect(!entry2.id.isEmpty)
    }
    
    // MARK: - Default Parameter Tests
    
    @Test("Test Default Source Is Manual")
    func testDefaultSourceIsManual() {
        let randomUserId = String.random
        let randomWeight = Double.random(in: 50...150)
        let randomDate = Date.random
        
        let entry = WeightEntry(
            userId: randomUserId,
            weightKg: randomWeight,
            date: randomDate
        )
        
        #expect(entry.source == .manual)
    }
    
    @Test("Test Default Notes Is Nil")
    func testDefaultNotesIsNil() {
        let randomUserId = String.random
        let randomWeight = Double.random(in: 50...150)
        let randomDate = Date.random
        
        let entry = WeightEntry(
            userId: randomUserId,
            weightKg: randomWeight,
            date: randomDate
        )
        
        #expect(entry.notes == nil)
    }
    
    @Test("Test Default CreatedAt Is Current Date")
    func testDefaultCreatedAtIsCurrentDate() {
        let randomUserId = String.random
        let randomWeight = Double.random(in: 50...150)
        let beforeCreation = Date()
        
        let entry = WeightEntry(
            userId: randomUserId,
            weightKg: randomWeight,
            date: Date.random
        )
        
        let afterCreation = Date()
        
        // createdAt should be between beforeCreation and afterCreation
        #expect(entry.createdAt >= beforeCreation.addingTimeInterval(-1))
        #expect(entry.createdAt <= afterCreation.addingTimeInterval(1))
    }
}
