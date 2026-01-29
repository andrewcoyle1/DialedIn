//
//  ABTestService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/12/2025.
//

protocol ABTestService {
    var activeTests: ActiveABTests { get }
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws
    func fetchUpdatedConfig() async throws -> ActiveABTests
}
