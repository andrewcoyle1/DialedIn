//
//  FirebaseTrainingPlanService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import FirebaseFirestore

struct FirebaseTrainingPlanService: RemoteTrainingPlanService {
    var collection: CollectionReference {
        Firestore.firestore().collection("training_plans")
    }
    
    func fetchAllPlans(userId: String) async throws -> [TrainingPlan] {
        let snapshot = try await collection
            .whereField("user_id", isEqualTo: userId)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: TrainingPlan.self)
        }
    }
    
    func fetchPlan(id: String, userId: String) async throws -> TrainingPlan {
        let document = try await collection.document(id).getDocument()
        guard let plan = try? document.data(as: TrainingPlan.self) else {
            throw TrainingPlanError.invalidData
        }
        
        // Verify the plan belongs to the user
        guard plan.userId == userId else {
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
    
    func addPlansListener(userId: String, onChange: @escaping ([TrainingPlan]) -> Void) -> (() -> Void) {
        let listener = collection
            .whereField("user_id", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    print("Error listening to training plans: \(error?.localizedDescription ?? "unknown")")
                    return
                }
                
                let plans = snapshot.documents.compactMap { doc in
                    try? doc.data(as: TrainingPlan.self)
                }
                
                onChange(plans)
            }
        
        return {
            listener.remove()
        }
    }
    
    // Legacy method
    func saveTrainingPlan(userId: String, plan: TrainingPlan) async throws {
        try await createPlan(plan)
    }
}
