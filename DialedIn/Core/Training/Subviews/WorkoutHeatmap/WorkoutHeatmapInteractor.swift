//
//  WorkoutHeatmapInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

protocol WorkoutHeatmapInteractor {
    func getProgressSnapshot(for period: DateInterval) async throws -> ProgressSnapshot
    func getCompletedSessions(in period: DateInterval) async -> [WorkoutSessionModel]
}

extension CoreInteractor: WorkoutHeatmapInteractor { }
