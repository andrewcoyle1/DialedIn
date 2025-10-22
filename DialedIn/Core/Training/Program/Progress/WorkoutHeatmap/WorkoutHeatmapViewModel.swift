//
//  WorkoutHeatmapViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

@Observable
@MainActor
class WorkoutHeatmapViewModel {
    let calendar = Calendar.current
    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    
    private(set) var progressAnalytics: ProgressAnalyticsService
    private(set) var performanceMetrics: PerformanceMetrics?
    private(set) var heatmapData: [Date: Int] = [:]
    private(set) var isLoading = false
    var selectedMonth: Date = Date()
    
    init(
        container: DependencyContainer,
        progressAnalytics: ProgressAnalyticsService
    ) {
        self.progressAnalytics = progressAnalytics
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
            let snapshot = try await progressAnalytics.getProgressSnapshot(for: monthInterval)
            performanceMetrics = snapshot.performanceMetrics
            
            // For now, create mock heatmap data
            // In production, this would come from actual workout sessions
            var data: [Date: Int] = [:]
            for day in 0..<30 {
                if let date = calendar.date(byAdding: .day, value: day, to: monthInterval.start) {
                    let workoutCount = Int.random(in: 0...2)
                    if workoutCount > 0 {
                        data[calendar.startOfDay(for: date)] = workoutCount
                    }
                }
            }
            heatmapData = data
        } catch {
            print("Error loading heatmap data: \(error)")
        }
    }
}
