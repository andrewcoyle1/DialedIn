//
//  FirebaseNutritionService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import FirebaseFirestore

struct FirebaseNutritionService: RemoteNutritionService {
    var collection: CollectionReference {
        Firestore.firestore().collection("diet_plans")
    }
    
    func saveDietPlan(userId: String, plan: DietPlan) async throws {
        try collection.document(userId).setData(from: plan, merge: true)
    }
}
