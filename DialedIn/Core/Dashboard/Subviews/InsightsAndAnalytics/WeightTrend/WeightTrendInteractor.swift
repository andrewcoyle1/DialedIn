//
//  WeightTrendInteractor.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import SwiftUI

@MainActor
protocol WeightTrendInteractor {
    var currentUser: UserModel? { get }
    var measurementHistory: [BodyMeasurementEntry] { get }
    func readAllLocalWeightEntries() throws -> [BodyMeasurementEntry]
    func readAllRemoteWeightEntries(userId: String) async throws -> [BodyMeasurementEntry]
    func updateWeightEntry(entry: BodyMeasurementEntry) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: WeightTrendInteractor { }
