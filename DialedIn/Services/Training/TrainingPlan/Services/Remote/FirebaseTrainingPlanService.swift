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
    
    func saveTrainingPlan(userId: String, plan: TrainingPlan) async throws {
        try collection.document(userId).setData(from: plan, merge: true)
    }
}
