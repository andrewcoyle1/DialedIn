//
//  SwiftTrainingProgramPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

import SwiftUI
import SwiftData

@MainActor
struct SwiftTrainingProgramPersistence: LocalTrainingProgramPersistence {
    
    private let container: ModelContainer
    
    private var mainContext: ModelContext {
        container.mainContext
    }
    
    init() {
        let storeURL: URL = {
            if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier) {
                let libraryURL = groupURL.appendingPathComponent("Library", isDirectory: true)
                let appSupportURL = libraryURL.appendingPathComponent("Application Support", isDirectory: true)
                let directory = appSupportURL.appendingPathComponent("DialedIn.TrainingProgramsStore", isDirectory: true)
                try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                return directory.appendingPathComponent("TrainingPrograms.store")
            } else {
                let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                let directory = appSupport.appendingPathComponent("DialedIn.TrainingProgramsStore", isDirectory: true)
                try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                return directory.appendingPathComponent("TrainingPrograms.store")
            }
        }()
        let configuration = ModelConfiguration(url: storeURL)

        do {
            self.container = try ModelContainer(
                for: TrainingProgramEntity.self,
                DayPlanEntity.self,
                ExercisePlanEntity.self,
                ExerciseTemplateEntity.self,
                configurations: configuration
            )
        } catch {
            // If the on-disk store schema is incompatible (common during active dev),
            // wipe the local store and recreate it to avoid a hard crash.
            try? FileManager.default.removeItem(at: storeURL.deletingLastPathComponent())
            // swiftlint:disable:next force_try
            self.container = try! ModelContainer(
                for: TrainingProgramEntity.self,
                DayPlanEntity.self,
                ExercisePlanEntity.self,
                ExerciseTemplateEntity.self,
                configurations: configuration
            )
        }
    }
        
    // MARK: CREATE
    func createTrainingProgram(program: TrainingProgram) throws {
        let entity = TrainingProgramEntity(from: program)
        mainContext.insert(entity)
        try mainContext.save()
    }
    
    // MARK: READ
    func readTrainingProgram(programId: String) throws -> TrainingProgram {
        
        let descriptor = FetchDescriptor<TrainingProgramEntity>(
            predicate: #Predicate<TrainingProgramEntity> { $0.id == programId }
        )
        
        guard let entity = try mainContext.fetch(descriptor).first else {
            throw URLError(.fileDoesNotExist)
        }
        return entity.toModel()
    }
    
    func readAllLocalTrainingPrograms() throws -> [TrainingProgram] {
        let descriptor = FetchDescriptor<TrainingProgramEntity>(
            sortBy: [SortDescriptor(\TrainingProgramEntity.dateCreated, order: .reverse)]
        )
        let entities = try mainContext.fetch(descriptor)
        return entities.map { $0.toModel() }
    }
    
    // MARK: UPDATE
    func updateTrainingProgram(program: TrainingProgram) throws {
        let programId = program.id
        let descriptor = FetchDescriptor<TrainingProgramEntity>(predicate: #Predicate<TrainingProgramEntity> { $0.id == programId })
        guard let entity = try mainContext.fetch(descriptor).first else {
            throw URLError(.fileDoesNotExist)
        }
        
        entity.authorId = program.authorId
        entity.name = program.name
        entity.icon = program.icon
        entity.colour = program.colour
        entity.numMicrocycles = program.numMicrocycles
        entity.deload = program.deload
        entity.periodisation = program.periodisation

        for existingDayPlan in entity.dayPlans {
            mainContext.delete(existingDayPlan)
        }
        entity.dayPlans = program.dayPlans.map { DayPlanEntity(from: $0) }
        entity.dateCreated = program.dateCreated
        entity.dateModified = program.dateModified
        
        try mainContext.save()
    }
    
    // MARK: DELETE
    func deleteTrainingProgram(program: TrainingProgram) throws {
        let programId = program.id
        let descriptor = FetchDescriptor<TrainingProgramEntity>(predicate: #Predicate<TrainingProgramEntity> { $0.id == programId })
        let entities = try mainContext.fetch(descriptor)
        for entity in entities {
            mainContext.delete(entity)
        }
        try mainContext.save()
    }
}
