//
//  ProfileGoalsDetailInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol ProfileGoalsDetailInteractor {
    var currentUser: UserModel? { get }
    var currentGoal: WeightGoal? { get }
    func getActiveGoal(userId: String) async throws -> WeightGoal?
    func getWeightHistory(userId: String, limit: Int?) async throws -> [WeightEntry]
}

extension CoreInteractor: ProfileGoalsDetailInteractor { }
