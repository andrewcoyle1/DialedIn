//
//  SwiftTrainingPlanPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import SwiftUI

@MainActor
struct SwiftTrainingPlanPersistence: LocalTrainingPlanPersistence {
    private let plansKey = "local_training_plans"
    private let activeKey = "active_training_plan_id"
    
    func getCurrentTrainingPlan() -> TrainingPlan? {
        guard let activePlanId = UserDefaults.standard.string(forKey: activeKey) else {
            return nil
        }
        return getPlan(id: activePlanId)
    }
    
    func getAllPlans() -> [TrainingPlan] {
        guard let data = UserDefaults.standard.data(forKey: plansKey),
              let plans = try? JSONDecoder().decode([TrainingPlan].self, from: data) else {
            return []
        }
        return plans.sorted { $0.createdAt > $1.createdAt }
    }
    
    func getPlan(id: String) -> TrainingPlan? {
        getAllPlans().first { $0.planId == id }
    }
    
    func savePlan(_ plan: TrainingPlan) throws {
        var allPlans = getAllPlans()
        
        // Update or insert
        if let index = allPlans.firstIndex(where: { $0.planId == plan.planId }) {
            allPlans[index] = plan
        } else {
            allPlans.append(plan)
        }
        
        // Save all plans
        let data = try JSONEncoder().encode(allPlans)
        UserDefaults.standard.set(data, forKey: plansKey)
        
        // If this is the active plan, update active ID
        if plan.isActive {
            UserDefaults.standard.set(plan.planId, forKey: activeKey)
        }
    }
    
    func deletePlan(id: String) throws {
        var allPlans = getAllPlans()
        allPlans.removeAll { $0.planId == id }
        
        let data = try JSONEncoder().encode(allPlans)
        UserDefaults.standard.set(data, forKey: plansKey)
        
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
