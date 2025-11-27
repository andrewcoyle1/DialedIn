//
//  ProfilePhysicalStatsInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol ProfilePhysicalStatsInteractor {
    var currentUser: UserModel? { get }
    var weightHistory: [WeightEntry] { get }
    func getWeightHistory(userId: String, limit: Int?) async throws -> [WeightEntry]
}

extension CoreInteractor: ProfilePhysicalStatsInteractor { }
