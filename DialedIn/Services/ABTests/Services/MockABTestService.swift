//
//  MockABTestService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/12/2025.
//

import Foundation

class MockABTestService: ABTestService {
    var activeTests: ActiveABTests
    
    init(notificationsTest: Bool? = nil) {
        self.activeTests = ActiveABTests(
            notificationsTest: notificationsTest ?? nil
        )
    }
    
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        activeTests = updatedTests
    }

    func fetchUpdatedConfig() async throws -> ActiveABTests {
        activeTests
    }

}
