//
//  SwiftExercisePersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 30/01/2026.
//

import SwiftData

@MainActor
struct SwiftExercisePersistence: LocalExercisePersistence {
    private let container: ModelContainer

    @MainActor
    private var mainContext: ModelContext {
        container.mainContext
    }

    @MainActor
    var modelContext: ModelContext {
        mainContext
    }

    init() {
        let storeURL: URL = {
            if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier) {
                let libraryURL = groupURL.appendingPathComponent("Library", isDirectory: true)
                let appSupportURL = libraryURL.appendingPathComponent("Application Support", isDirectory: true)
                let directory = appSupportURL.appendingPathComponent("DialedIn.ExercisesStore", isDirectory: true)
                try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                return directory.appendingPathComponent("Exercises.store")
            } else {
                let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                let directory = appSupport.appendingPathComponent("DialedIn.ExercisesStore", isDirectory: true)
                try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                return directory.appendingPathComponent("Exercises.store")
            }
        }()
        let configuration = ModelConfiguration(url: storeURL)
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(for: ExerciseEntity.self, configurations: configuration)
    }

    @MainActor
    func addLocalExercise(exercise: ExerciseModel) throws {
        let entity = ExerciseEntity(from: exercise)
        mainContext.insert(entity)
        try mainContext.save()
    }

    @MainActor
    func getLocalExercise(id: String) throws -> ExerciseModel {
        let predicate = #Predicate<ExerciseEntity> { $0.exerciseId == id }
        let descriptor = FetchDescriptor<ExerciseEntity>(predicate: predicate)
        let entities = try mainContext.fetch(descriptor)
        guard let entity = entities.first else {
            throw NSError(domain: "SwiftExercisePersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "Exercise with id \(id) not found"])
        }
        return entity.toModel()
    }

    @MainActor
    func getLocalExercises(ids: [String]) throws -> [ExerciseModel] {
        let predicate = #Predicate<ExerciseEntity> { ids.contains($0.exerciseId) }
        let descriptor = FetchDescriptor<ExerciseEntity>(predicate: predicate, sortBy: [SortDescriptor(\.dateCreated, order: .reverse)])
        let entities = try mainContext.fetch(descriptor)
        return entities.map { $0.toModel() }
    }

    @MainActor
    func getAllLocalExercises() throws -> [ExerciseModel] {
        let descriptor = FetchDescriptor<ExerciseEntity>(sortBy: [SortDescriptor(\.name, order: .forward)])
        let entities = try mainContext.fetch(descriptor)
        return entities.map { $0.toModel() }
    }

    @MainActor
    func getSystemExercises() throws -> [ExerciseModel] {
        let predicate = #Predicate<ExerciseEntity> { $0.isSystemExercise == true }
        let descriptor = FetchDescriptor<ExerciseEntity>(predicate: predicate, sortBy: [SortDescriptor(\.name, order: .forward)])
        let entities = try mainContext.fetch(descriptor)
        return entities.map { $0.toModel() }
    }

    @MainActor
    func bookmarkExercise(id: String, isBookmarked: Bool) throws {
        let predicate = #Predicate<ExerciseEntity> { $0.exerciseId == id }
        let descriptor = FetchDescriptor<ExerciseEntity>(predicate: predicate)
        let entities = try mainContext.fetch(descriptor)
        guard let entity = entities.first else {
            throw NSError(domain: "SwiftExercisePersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "Exercise with id \(id) not found"])
        }
        entity.bookmarkCount = isBookmarked ? (entity.bookmarkCount ?? 0) + 1 : (entity.bookmarkCount ?? 0) - 1
        try mainContext.save()
    }

    @MainActor
    func favouriteExercise(id: String, isFavourited: Bool) throws {
        let predicate = #Predicate<ExerciseEntity> { $0.exerciseId == id }
        let descriptor = FetchDescriptor<ExerciseEntity>(predicate: predicate)
        let entities = try mainContext.fetch(descriptor)
        guard let entity = entities.first else {
            throw NSError(domain: "SwiftExercisePersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "Exercise with id \(id) not found"])
        }
        entity.favouriteCount = isFavourited ? (entity.favouriteCount ?? 0) + 1 : (entity.favouriteCount ?? 0) - 1
        try mainContext.save()
    }
}
