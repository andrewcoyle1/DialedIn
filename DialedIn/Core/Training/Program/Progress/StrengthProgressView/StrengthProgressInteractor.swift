//
//  StrengthProgressInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol StrengthProgressInteractor {
    func getProgressSnapshot(for period: DateInterval) async throws -> ProgressSnapshot
    func getStrengthProgression(for exerciseId: String, in period: DateInterval) async throws -> StrengthProgression?
}

extension CoreInteractor: StrengthProgressInteractor { }
