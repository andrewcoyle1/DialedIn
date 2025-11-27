//
//  LogWeightInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

protocol LogWeightInteractor {
    var currentUser: UserModel? { get }
    var weightHistory: [WeightEntry] { get }
    func updateWeight(userId: String, weightKg: Double) async throws
    func getWeightHistory(userId: String, limit: Int?) async throws -> [WeightEntry]
    func logWeight(_ weightKg: Double, date: Date, notes: String?, userId: String) async throws
}

extension CoreInteractor: LogWeightInteractor { }
