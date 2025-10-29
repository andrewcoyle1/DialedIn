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

enum TimePeriod: String, CaseIterable {
    case lastMonth = "Month"
    case lastThreeMonths = "3 Months"
    case lastSixMonths = "6 Months"
    case allTime = "All Time"
    
    var dateInterval: DateInterval {
        let now = Date()
        let calendar = Calendar.current
        
        switch self {
        case .lastMonth:
            let start = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return DateInterval(start: start, end: now)
        case .lastThreeMonths:
            let start = calendar.date(byAdding: .month, value: -3, to: now) ?? now
            return DateInterval(start: start, end: now)
        case .lastSixMonths:
            let start = calendar.date(byAdding: .month, value: -6, to: now) ?? now
            return DateInterval(start: start, end: now)
        case .allTime:
            let start = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return DateInterval(start: start, end: now)
        }
    }
}
