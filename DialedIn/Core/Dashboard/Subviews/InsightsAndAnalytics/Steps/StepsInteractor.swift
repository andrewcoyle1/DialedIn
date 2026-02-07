//
//  StepsInteractor.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import SwiftUI

@MainActor
protocol StepsInteractor {
    var userId: String? { get }
    func readAllLocalStepsEntries() throws -> [StepsModel]
    var stepsHistory: [StepsModel] { get }
    func backfillStepsFromHealthKit() async
    func canRequestHealthDataAuthorisation() -> Bool
    func requestHealthKitAuthorisation() async throws
}

extension CoreInteractor: StepsInteractor { }
