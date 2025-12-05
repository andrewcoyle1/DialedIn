//
//  LocalABTestService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/12/2025.
//

class LocalABTestService: ABTestService {
    @UserDefault(key: ActiveABTests.CodingKeys.notificationsTest.rawValue, startingValue: .random()) private var notificationsTest: Bool
    
    var activeTests: ActiveABTests {
        ActiveABTests(
            notificationsTest: notificationsTest
        )
    }
    
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        
        // Every new test need to be added here to ensure that it can be updated
        notificationsTest = updatedTests.notificationsTest
    }
    
    func fetchUpdatedConfig() async throws -> ActiveABTests {
        activeTests
    }
}
