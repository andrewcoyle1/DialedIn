//
//  LogLeftCalfMeasurementInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/02/2026.
//

import SwiftUI

@MainActor
protocol LogLeftCalfMeasurementInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    var bodyMeasurements: [BodyMeasurementEntry] { get }
    func saveBodyMeasurement(bodyMeasurement: BodyMeasurementEntry) async throws
}

extension CoreInteractor: LogLeftCalfMeasurementInteractor { }
