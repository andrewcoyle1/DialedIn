//
//  ProgressDashboardViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

protocol ProgressDashboardInteractor {
    func getProgressSnapshot(for period: DateInterval) async throws -> ProgressSnapshot
}

extension CoreInteractor: ProgressDashboardInteractor { }

@Observable
@MainActor
class ProgressDashboardViewModel {
    private let interactor: ProgressDashboardInteractor
    
    var selectedPeriod: TimePeriod = .lastMonth
    private(set) var progressSnapshot: ProgressSnapshot?
    private(set) var isLoading = false
    
    init(
        interactor: ProgressDashboardInteractor
    ) {
        self.interactor = interactor
    }
    
    func loadProgressData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let snapshot = try await interactor.getProgressSnapshot(for: selectedPeriod.dateInterval)
            progressSnapshot = snapshot
        } catch {
            print("Error loading progress: \(error)")
            progressSnapshot = .empty
        }
    }
}
