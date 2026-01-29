//
//  RemoteUserWeightService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

protocol RemoteUserWeightService {
    func saveWeightEntry(_ entry: WeightEntry) async throws
    func getWeightHistory(userId: String, limit: Int?) async throws -> [WeightEntry]
    func deleteWeightEntry(id: String, userId: String) async throws
}
