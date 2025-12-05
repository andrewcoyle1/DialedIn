//
//  ABTestManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import Foundation

@Observable
class ABTestManager {
    private let service: ABTestService
    private let logger: LogManager
    var activeTests: ActiveABTests
    
    init(service: ABTestService, logger: LogManager) {
        self.service = service
        self.activeTests = service.activeTests
        self.logger = logger
        self.configure()
    }
    
    private func configure() {
        activeTests = service.activeTests
        logger.addUserProperties(dict: activeTests.eventParameters, isHighPriority: false)
    }
    
    func override(updatedTests: ActiveABTests) throws {
        try service.saveUpdatedConfig(updatedTests: updatedTests)
        configure()
    }
}
