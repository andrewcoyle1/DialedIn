//
//  LogWeightInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

protocol LogWeightInteractor {
    var currentUser: UserModel? { get }
    var measurementHistory: [BodyMeasurementEntry] { get }
    func createWeightEntry(weightEntry: BodyMeasurementEntry) async throws
    func readAllLocalWeightEntries() throws -> [BodyMeasurementEntry]
    func readAllRemoteWeightEntries(userId: String) async throws -> [BodyMeasurementEntry]
    func updateWeight(userId: String, weightKg: Double) async throws
}

extension CoreInteractor: LogWeightInteractor { }
