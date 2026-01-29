//
//  SwiftTrainingPlanPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import SwiftUI
import SwiftData

@MainActor
struct SwiftTrainingPlanPersistence: LocalTrainingPlanPersistence {
    private let container: ModelContainer
    private let storeURL: URL
    private let activeKey = "active_training_plan_id"
    
    // Legacy keys for migration
    private let legacyPlansKey = "local_training_plans"
    private let migrationCompleteKey = "training_plans_migrated_to_swiftdata"
    
    @MainActor
    private var mainContext: ModelContext {
        container.mainContext
    }
    
    init() {
        // Create Application Support path and a fixed store URL
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let directory = appSupport.appendingPathComponent("DialedIn.TrainingPlansStore", isDirectory: true)
        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        self.storeURL = directory.appendingPathComponent("TrainingPlans.store")
        
        let configuration = ModelConfiguration(url: storeURL)
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(
            for: TrainingPlanEntity.self, TrainingWeekEntity.self, ScheduledWorkoutEntity.self, TrainingGoalEntity.self,
            configurations: configuration
        )
        
        // Perform one-time migration from UserDefaults to SwiftData
        migrateFromUserDefaultsIfNeeded()
    }
    
    private func migrateFromUserDefaultsIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: migrationCompleteKey) else {
            return
        }
        
        // Try to load plans from UserDefaults
        guard let data = UserDefaults.standard.data(forKey: legacyPlansKey),
              let plans = try? JSONDecoder().decode([TrainingPlan].self, from: data),
              !plans.isEmpty else {
            // No data to migrate or already migrated
            UserDefaults.standard.set(true, forKey: migrationCompleteKey)
            return
        }
        
        // Migrate each plan to SwiftData
        for plan in plans {
            let entity = TrainingPlanEntity(from: plan)
            mainContext.insert(entity)
        }
        
        do {
            try mainContext.save()
            UserDefaults.standard.set(true, forKey: migrationCompleteKey)
            print("✅ Successfully migrated \(plans.count) training plans from UserDefaults to SwiftData")
        } catch {
            print("❌ Failed to migrate training plans: \(error)")
        }
    }
    
    func getCurrentTrainingPlan() -> TrainingPlan? {
        guard let activePlanId = UserDefaults.standard.string(forKey: activeKey) else {
            return nil
        }
        return getPlan(id: activePlanId)
    }
    
    func getAllPlans() -> [TrainingPlan] {
        let descriptor = FetchDescriptor<TrainingPlanEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        guard let entities = try? mainContext.fetch(descriptor) else {
            return []
        }
        
        return entities.map { $0.toModel() }
    }
    
    func getPlan(id: String) -> TrainingPlan? {
        let planId = id // Capture as local variable for Sendable
        var descriptor = FetchDescriptor<TrainingPlanEntity>(
            predicate: #Predicate { $0.planId == planId }
        )
        descriptor.fetchLimit = 1
        
        guard let entity = try? mainContext.fetch(descriptor).first else {
            return nil
        }
        
        return entity.toModel()
    }
    
    func savePlan(_ plan: TrainingPlan) throws {
        // Try to find existing entity
        let planId = plan.planId // Capture as local variable for Sendable
        var descriptor = FetchDescriptor<TrainingPlanEntity>(
            predicate: #Predicate { $0.planId == planId }
        )
        descriptor.fetchLimit = 1
        
        if let existingEntity = try? mainContext.fetch(descriptor).first {
            // Update existing entity
            mainContext.delete(existingEntity)
        }
        
        // Insert new/updated entity
        let entity = TrainingPlanEntity(from: plan)
        mainContext.insert(entity)
        
        try mainContext.save()
        
        // If this is the active plan, update active ID
        if plan.isActive {
            UserDefaults.standard.set(plan.planId, forKey: activeKey)
        }
    }
    
    func deletePlan(id: String) throws {
        let planId = id // Capture as local variable for Sendable
        var descriptor = FetchDescriptor<TrainingPlanEntity>(
            predicate: #Predicate { $0.planId == planId }
        )
        descriptor.fetchLimit = 1
        
        guard let entity = try mainContext.fetch(descriptor).first else {
            return
        }
        
        mainContext.delete(entity)
        try mainContext.save()
        
        // If deleting active plan, clear active ID
        if UserDefaults.standard.string(forKey: activeKey) == id {
            UserDefaults.standard.removeObject(forKey: activeKey)
        }
    }
    
    // Legacy method for backwards compatibility
    func saveTrainingPlan(plan: TrainingPlan) throws {
        try savePlan(plan)
    }
}
