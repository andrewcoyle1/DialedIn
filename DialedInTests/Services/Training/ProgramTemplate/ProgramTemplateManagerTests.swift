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
        let fixtures = Self.makeUserTemplatesFixtures()
        let local = MockProgramTemplatePersistence()
        try? local.save(fixtures.builtIn)
        try? local.save(fixtures.olderUserTemplate)
        try? local.save(fixtures.newerUserTemplate)
        try? local.save(fixtures.otherUserTemplate)
        let services = ProgramTemplateServices(local: local, remote: MockProgramTemplateService())
        let manager = ProgramTemplateManager(services: services)
        let results = manager.getUserTemplates(userId: fixtures.userId)
        #expect(results.count == 2)
        #expect(results.allSatisfy { $0.authorId == fixtures.userId })
        #expect(results.first?.id == fixtures.newerUserTemplate.id)
        #expect(results.last?.id == fixtures.olderUserTemplate.id)
        #expect(!results.contains(where: { $0.id == fixtures.builtIn.id }))
    }

    private static func makeUserTemplatesFixtures() -> UserTemplatesFixtures {
        let userId = "user-123"
        let otherUserId = "user-456"
        let builtIn = ProgramTemplateModel.pushPullLegs
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
        return UserTemplatesFixtures(
            builtIn: builtIn,
            olderUserTemplate: olderUserTemplate,
            newerUserTemplate: newerUserTemplate,
            otherUserTemplate: otherUserTemplate,
            userId: userId
        )
    }
}

private struct UserTemplatesFixtures {
    let builtIn: ProgramTemplateModel
    let olderUserTemplate: ProgramTemplateModel
    let newerUserTemplate: ProgramTemplateModel
    let otherUserTemplate: ProgramTemplateModel
    let userId: String
}
