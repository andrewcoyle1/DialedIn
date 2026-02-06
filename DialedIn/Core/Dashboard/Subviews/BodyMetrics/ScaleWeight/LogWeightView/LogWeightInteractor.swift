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
    func createWeightEntry(weightEntry: WeightEntry) async throws
    func readAllLocalWeightEntries() throws -> [WeightEntry]
    func readAllRemoteWeightEntries(userId: String) async throws -> [WeightEntry]
    func updateWeight(userId: String, weightKg: Double) async throws
}

extension CoreInteractor: LogWeightInteractor { }
