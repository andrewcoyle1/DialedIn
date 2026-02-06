//
//  LogWaistMeasurementInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/02/2026.
//

import SwiftUI

protocol LogWaistMeasurementInteractor {
    var currentUser: UserModel? { get }
    var measurementHistory: [BodyMeasurementEntry] { get }
    func createWeightEntry(weightEntry: BodyMeasurementEntry) async throws
    func updateWeightEntry(entry: BodyMeasurementEntry) async throws
    func readAllLocalWeightEntries() throws -> [BodyMeasurementEntry]
    func readAllRemoteWeightEntries(userId: String) async throws -> [BodyMeasurementEntry]
}

extension CoreInteractor: LogWaistMeasurementInteractor { }
