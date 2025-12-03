//
//  ProgramTemplateManagerTests.swift
//  DialedInTests
//
//  Created by AI on 03/12/2025.
//

import Testing
import Foundation

struct ProgramTemplateManagerTests {
    
    @Test("getUserTemplates returns only non-built-in templates for given user, sorted by modifiedAt descending")
    func testGetUserTemplatesFiltersAndSortsCorrectly() {
        let userId = "user-123"
        let otherUserId = "user-456"
        
        // Built-in template (should always be excluded)
        let builtIn = ProgramTemplateModel.pushPullLegs
        
        // User templates for target user
        let olderUserTemplate = ProgramTemplateModel(
            id: "user-template-1",
            name: "Older Template",
            description: "Old",
            duration: 4,
            difficulty: .beginner,
            focusAreas: [.strength],
            weekTemplates: [],
            isPublic: false,
            authorId: userId,
            createdAt: Date(timeIntervalSince1970: 1_000),
            modifiedAt: Date(timeIntervalSince1970: 2_000)
        )
        
        let newerUserTemplate = ProgramTemplateModel(
            id: "user-template-2",
            name: "Newer Template",
            description: "New",
            duration: 8,
            difficulty: .intermediate,
            focusAreas: [.hypertrophy],
            weekTemplates: [],
            isPublic: false,
            authorId: userId,
            createdAt: Date(timeIntervalSince1970: 3_000),
            modifiedAt: Date(timeIntervalSince1970: 4_000)
        )
        
        // Template for a different user (should be excluded)
        let otherUserTemplate = ProgramTemplateModel(
            id: "other-user-template",
            name: "Other User Template",
            description: "Other",
            duration: 6,
            difficulty: .advanced,
            focusAreas: [.endurance],
            weekTemplates: [],
            isPublic: false,
            authorId: otherUserId,
            createdAt: Date(timeIntervalSince1970: 5_000),
            modifiedAt: Date(timeIntervalSince1970: 6_000)
        )
        
        // Local persistence seeded with all templates
        let local = MockProgramTemplatePersistence()
        // Overwrite its storage to ensure we control the dataset
        try? local.save(builtIn)
        try? local.save(olderUserTemplate)
        try? local.save(newerUserTemplate)
        try? local.save(otherUserTemplate)
        
        let services = ProgramTemplateServices(local: local, remote: MockProgramTemplateService())
        let manager = ProgramTemplateManager(services: services)
        
        let results = manager.getUserTemplates(userId: userId)
        
        #expect(results.count == 2)
        #expect(results.allSatisfy { $0.authorId == userId })
        // Should be sorted by modifiedAt descending (newest first)
        #expect(results.first?.id == newerUserTemplate.id)
        #expect(results.last?.id == olderUserTemplate.id)
        // Ensure built-in template is excluded
        #expect(!results.contains(where: { $0.id == builtIn.id }))
    }
}
