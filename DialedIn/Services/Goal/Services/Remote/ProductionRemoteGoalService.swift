//
//  ProductionRemoteGoalService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import Foundation
import FirebaseFirestore

struct ProductionRemoteGoalService: RemoteGoalService {
    
    private var database: Firestore { Firestore.firestore() }
    
    private func goalsCollection(userId: String) -> CollectionReference {
        database.collection("users").document(userId).collection("goals")
    }
    
    func createGoal(_ goal: WeightGoal) async throws {
        try goalsCollection(userId: goal.userId)
            .document(goal.goalId)
            .setData(from: goal, merge: false)
    }
    
    func getGoal(id: String, userId: String) async throws -> WeightGoal {
        let document = try await goalsCollection(userId: userId).document(id).getDocument()
        guard let goal = try? document.data(as: WeightGoal.self) else {
            throw NSError(domain: "GoalError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Goal not found"])
        }
        return goal
    }
    
    func getActiveGoal(userId: String) async throws -> WeightGoal? {
        let snapshot = try await goalsCollection(userId: userId)
            .whereField("status", isEqualTo: WeightGoal.GoalStatus.active.rawValue)
            .order(by: "created_at", descending: true)
            .limit(to: 1)
            .getDocuments()
        
        return try snapshot.documents.first?.data(as: WeightGoal.self)
    }
    
    func getAllGoals(userId: String) async throws -> [WeightGoal] {
        let snapshot = try await goalsCollection(userId: userId)
            .order(by: "created_at", descending: true)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: WeightGoal.self) }
    }
    
    func updateGoalStatus(goalId: String, userId: String, status: WeightGoal.GoalStatus) async throws {
        var data: [String: Any] = [
            WeightGoal.CodingKeys.status.rawValue: status.rawValue
        ]
        
        // Set completedAt if completing
        if status == .completed {
            data[WeightGoal.CodingKeys.completedAt.rawValue] = Date()
        }
        
        try await goalsCollection(userId: userId)
            .document(goalId)
            .updateData(data)
    }
    
    func deleteGoal(goalId: String, userId: String) async throws {
        try await goalsCollection(userId: userId).document(goalId).delete()
    }
}
