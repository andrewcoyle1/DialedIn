//
//  FirebaseMealLogService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import Foundation
import FirebaseFirestore

struct FirebaseMealLogService: RemoteMealLogService {
    
    private var database: Firestore { Firestore.firestore() }
    
    private func dayCollection(authorId: String, dayKey: String) -> CollectionReference {
        database.collection("users").document(authorId).collection("meal_logs").document(dayKey).collection("meals")
    }
    
    func createMeal(_ meal: MealLogModel) async throws {
        try dayCollection(authorId: meal.authorId, dayKey: meal.dayKey)
            .document(meal.mealId)
            .setData(from: meal, merge: false)
    }
    
    func updateMeal(_ meal: MealLogModel) async throws {
        try dayCollection(authorId: meal.authorId, dayKey: meal.dayKey)
            .document(meal.mealId)
            .setData(from: meal, merge: true)
    }
    
    func deleteMeal(id: String, dayKey: String, authorId: String) async throws {
        try await dayCollection(authorId: authorId, dayKey: dayKey).document(id).delete()
    }
    
    func getMeals(dayKey: String, authorId: String, limitTo: Int) async throws -> [MealLogModel] {
        let snapshot = try await dayCollection(authorId: authorId, dayKey: dayKey)
            .order(by: "date", descending: false)
            .limit(to: limitTo)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: MealLogModel.self) }
    }
    
    func getMeals(startDayKey: String, endDayKey: String, authorId: String, limitTo: Int) async throws -> [MealLogModel] {
        // For range queries across days, iterate days. In v2, consider a top-level collection for index.
        // Here we do a simple loop; callers should keep ranges small.
        var results: [MealLogModel] = []
        var day = startDayKey
        while day <= endDayKey && results.count < limitTo {
            let chunk = try await getMeals(dayKey: day, authorId: authorId, limitTo: max(1, limitTo - results.count))
            results.append(contentsOf: chunk)
            if let next = nextDayKey(day) { day = next } else { break }
        }
        return results
    }
    
    private func nextDayKey(_ dayKey: String) -> String? {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dayKey) else { return nil }
        guard let next = Calendar.current.date(byAdding: .day, value: 1, to: date) else { return nil }
        return formatter.string(from: next)
    }
}
