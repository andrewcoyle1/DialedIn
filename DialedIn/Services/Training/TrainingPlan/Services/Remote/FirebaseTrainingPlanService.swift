//
//  FirebaseTrainingPlanService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseTrainingPlanService: RemoteTrainingPlanService {
    var collection: CollectionReference {
        Firestore.firestore().collection("training_plans")
    }
    
    func fetchAllPlans() async throws -> [TrainingPlan] {
        let snapshot = try await collection.getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: TrainingPlan.self)
        }
    }
    
    func fetchPlan(id: String) async throws -> TrainingPlan {
        let document = try await collection.document(id).getDocument()
        guard let plan = try? document.data(as: TrainingPlan.self) else {
            throw TrainingPlanError.invalidData
        }
        return plan
    }
    
    func createPlan(_ plan: TrainingPlan) async throws {
        try collection.document(plan.planId).setData(from: plan)
    }
    
    func updatePlan(_ plan: TrainingPlan) async throws {
        try collection.document(plan.planId).setData(from: plan, merge: true)
    }
    
    func deletePlan(id: String) async throws {
        try await collection.document(id).delete()
    }
    
    // Legacy method
    func saveTrainingPlan(userId: String, plan: TrainingPlan) async throws {
        try await createPlan(plan)
    }
}
