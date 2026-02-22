//
//  RemoteNutritionService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

protocol RemoteNutritionService: Sendable {
    func saveDietPlan(userId: String, plan: DietPlan) async throws
}
