//
//  WorkoutHeatmapViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

protocol WorkoutHeatmapInteractor {
    func getProgressSnapshot(for period: DateInterval) async throws -> ProgressSnapshot
    func getCompletedSessions(in period: DateInterval) async -> [WorkoutSessionModel]
}

extension CoreInteractor: WorkoutHeatmapInteractor { }

@MainActor
protocol WorkoutHeatmapRouter {
    func showDevSettingsView()
    func dismissScreen()
}

extension CoreRouter: WorkoutHeatmapRouter { }

@Observable
@MainActor
class WorkoutHeatmapViewModel {
    private let interactor: WorkoutHeatmapInteractor
    private let router: WorkoutHeatmapRouter

    let calendar = Calendar.current
    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    
    private(set) var performanceMetrics: PerformanceMetrics?
    private(set) var heatmapData: [Date: Int] = [:]
    private(set) var isLoading = false
    var selectedMonth: Date = Date()
    
    init(
        interactor: WorkoutHeatmapInteractor,
        router: WorkoutHeatmapRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedMonth) else {
            return []
        }
        
        let monthStart = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 0
        
        var days: [Date?] = []
        
        // Add leading empty cells
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add actual days
        for day in 0..<daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day, to: monthStart) {
                days.append(date)
            }
        }
        
        return days
    }
    
    func intensityColor(for workoutCount: Int) -> Color {
        switch workoutCount {
        case 0:
            return Color.gray.opacity(0.1)
        case 1:
            return Color.green.opacity(0.3)
        case 2:
            return Color.green.opacity(0.6)
        case 3:
            return Color.green.opacity(0.8)
        default:
            return Color.green
        }
    }
    
    func loadHeatmapData() async {
        isLoading = true
        defer { isLoading = false }
        
        // Get month interval
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedMonth) else {
            return
        }
        
        do {
            let snapshot = try await interactor.getProgressSnapshot(for: monthInterval)
            performanceMetrics = snapshot.performanceMetrics
            
            let sessions = await interactor.getCompletedSessions(in: monthInterval)
            
            var data: [Date: Int] = [:]
            for session in sessions {
                let dayKey = calendar.startOfDay(for: session.dateCreated)
                data[dayKey, default: 0] += 1
            }
            
            heatmapData = data
        } catch {
            print("Error loading heatmap data: \(error)")
        }
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }
}
