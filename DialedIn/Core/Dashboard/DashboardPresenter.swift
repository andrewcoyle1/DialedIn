//
//  DashboardPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import SwiftUI

@Observable
@MainActor
class DashboardPresenter {
    private let interactor: DashboardInteractor
    private let router: DashboardRouter

    private(set) var selectedDate: Date = Date.now
    var showNotifications: Bool = false
    var isShowingInspector: Bool = false
    private(set) var contributionChartData: [Double] = []
    private(set) var chartEndDate: Date = Date()
    private(set) var scaleWeightEntries: [BodyMeasurementEntry] = []
    
    // Workout data
    private(set) var workoutContributionData: [Double] = []
    private(set) var workoutCountThisWeek: Int = 0
    
    // Weigh-in data
    private(set) var weighInContributionData: [Double] = []
    private(set) var weighInCountThisWeek: Int = 0
    
    private let calendar = Calendar.current

    var isInNotificationsABTest: Bool {
        interactor.activeTests.notificationsTest
    }

    var userImageUrl: String? {
        interactor.userImageUrl
    }

    init(
        interactor: DashboardInteractor,
        router: DashboardRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    func onFirstTask() async {
        loadLocalScaleWeightEntries()
        await loadRemoteScaleWeightEntriesIfNeeded()
        loadWorkoutData()
        loadWeighInData()
    }
    
    func handleDeepLink(url: URL) {
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            // no query items
            print("NO QUERY ITEMS!")
            return
        }
        
        for queryItem in queryItems {
            print(queryItem.name)
        }
        
    }
    
    func onPushNotificationsPressed() {
        interactor.trackEvent(event: Event.onNotificationsPressed)
        router.showNotificationsView()
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
    
    func onSubscribePressed() {
        router.showCorePaywall()
    }

    func onProfilePressed() {
        router.showProfileView()
    }

    func onScaleWeightPressed() {
        router.showScaleWeightView(delegate: ScaleWeightDelegate())
    }

    func onVisualBodyFatPressed() {
        router.showVisualBodyFatView(delegate: VisualBodyFatDelegate())
    }
    
    func onSeeAllInsightsPressed() {
        router.showInsightsAndAnalyticsView(delegate: InsightsAndAnalyticsDelegate())
    }
    
    func onSeeAllHabitsPressed() {
        router.showHabitsView(delegate: HabitsDelegate())
    }
    
    func onSeeAllBodyMetricsPressed() {
        router.showBodyMetricsView(delegate: BodyMetricsDelegate())
    }
    
    func onSeeAllMuscleGroupsPressed() {
        router.showMuscleGroupsView(delegate: MuscleGroupsDelegate())
    }
    
    func onSeeAllExercisesPressed() {
        router.showExerciseAnalyticsView(delegate: ExerciseAnalyticsDelegate())
    }

    var scaleWeightSparklineData: [(date: Date, value: Double)] {
        scaleWeightLastEntries.compactMap { entry in
            guard let weightKg = entry.weightKg else { return nil }
            return (date: entry.date, value: weightKg)
        }
    }

    var scaleWeightSubtitle: String {
        scaleWeightLastEntries.isEmpty ? "No Entries" : "Last 7 Entries"
    }

    var scaleWeightLatestValueText: String {
        guard let latest = scaleWeightLastEntries.last,
              let weightKg = latest.weightKg else { return "--" }
        return weightKg.formatted(.number.precision(.fractionLength(1)))
    }

    var scaleWeightUnitText: String {
        "kg"
    }

    private var scaleWeightLastEntries: [BodyMeasurementEntry] {
        let filtered = scaleWeightEntries.filter { $0.deletedAt == nil && $0.weightKg != nil }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }

    private func loadLocalScaleWeightEntries() {
        do {
            scaleWeightEntries = try interactor.readAllLocalWeightEntries()
        } catch {
            scaleWeightEntries = interactor.measurementHistory
        }
    }

    private func loadRemoteScaleWeightEntriesIfNeeded() async {
        guard let userId = interactor.userId else { return }
        do {
            scaleWeightEntries = try await interactor.readAllRemoteWeightEntries(userId: userId)
        } catch {
            // Keep local data on failure.
        }
    }

    var bodyFatSparklineData: [(date: Date, value: Double)] {
        bodyFatLastEntries.compactMap { entry in
            guard let bodyFatPercentage = entry.bodyFatPercentage else { return nil }
            return (date: entry.date, value: bodyFatPercentage)
        }
    }

    var bodyFatSubtitle: String {
        bodyFatLastEntries.isEmpty ? "No Entries" : "Last 7 Entries"
    }

    var bodyFatLatestValueText: String {
        guard let latest = bodyFatLastEntries.last,
              let bodyFatPercentage = latest.bodyFatPercentage else {
            return "--"
        }
        return bodyFatPercentage.formatted(.number.precision(.fractionLength(1)))
    }

    var bodyFatUnitText: String {
        "%"
    }

    private var bodyFatLastEntries: [BodyMeasurementEntry] {
        let filtered = scaleWeightEntries.filter {
            $0.deletedAt == nil && $0.bodyFatPercentage != nil
        }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }

    func loadWorkoutData() {
        guard let userId = interactor.auth?.uid else {
            workoutContributionData = Array(repeating: 0.0, count: 30)
            return
        }
        
        do {
            // Fetch all workout sessions for the user
            let allSessions = try interactor.getLocalWorkoutSessionsForAuthor(
                authorId: userId,
                limitTo: 0
            )
            
            // Filter to completed sessions within last 30 days
            let now = Date()
            let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now) ?? now
            let startOfToday = calendar.startOfDay(for: now)
            let startOf30DaysAgo = calendar.startOfDay(for: thirtyDaysAgo)
            
            let completedSessions = allSessions.filter { session in
                guard let endedAt = session.endedAt else { return false }
                let sessionDate = calendar.startOfDay(for: endedAt)
                return sessionDate >= startOf30DaysAgo && sessionDate <= startOfToday
            }
            
            // Count workouts in current week
            if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) {
                let weekStart = calendar.startOfDay(for: weekInterval.start)
                let weekEnd = calendar.startOfDay(for: weekInterval.end)
                
                self.workoutCountThisWeek = completedSessions.filter { session in
                    guard let endedAt = session.endedAt else { return false }
                    let sessionDate = calendar.startOfDay(for: endedAt)
                    return sessionDate >= weekStart && sessionDate < weekEnd
                }.count
            } else {
                self.workoutCountThisWeek = 0
            }
            
            // Generate contribution chart data (30 days, 3 rows × 10 columns)
            // Days now flow continuously from left to right, with each column containing 'rows' consecutive days
            // The chart's dateForCell uses: dayOffset = columnIndex * rows + rowIndex
            
            var contributionData = Array(repeating: 0.0, count: 30)
            
            // Create a set of dates that have workouts
            let workoutDates = Set(completedSessions.compactMap { session -> Date? in
                guard let endedAt = session.endedAt else { return nil }
                return calendar.startOfDay(for: endedAt)
            })
            
            // Calculate the start date exactly as the chart does (matches ContributionChartView init)
            // Chart calculates: startDate = endDate - (totalDays - 1) where totalDays = rows * columns
            let endDate = calendar.startOfDay(for: now)
            let totalDays = 3 * 10 // rows * columns
            let chartStartDate = calendar.date(byAdding: .day, value: -(totalDays - 1), to: endDate) ?? endDate
            
            // Map workout dates to chart data array indices
            // For each cell in the chart (column 0-9, row 0-2):
            for column in 0..<10 {
                for row in 0..<3 {
                    // Calculate the actual date for this cell using the chart's date mapping
                    // This matches dateForCell: dayOffset = columnIndex * rows + rowIndex
                    let dayOffset = column * 3 + row
                    if let cellDate = calendar.date(byAdding: .day, value: dayOffset, to: chartStartDate) {
                        let normalizedCellDate = calendar.startOfDay(for: cellDate)
                        // Check if this date has a workout
                        if workoutDates.contains(normalizedCellDate) {
                            // Calculate the data array index: column * rows + row (where rows=3)
                            let dataIndex = column * 3 + row
                            if dataIndex < 30 {
                                contributionData[dataIndex] = 1.0
                            }
                        }
                    }
                }
            }
            
            self.workoutContributionData = contributionData
            
        } catch {
            // On error, set empty data
            self.workoutContributionData = Array(repeating: 0.0, count: 30)
            self.workoutCountThisWeek = 0
        }
    }
    
    func loadWeighInData() {
        do {
            // Fetch all weight entries
            let allEntries = try interactor.readAllLocalWeightEntries()
            
            // Filter to entries with weight data within last 30 days
            let now = Date()
            let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now) ?? now
            let startOfToday = calendar.startOfDay(for: now)
            let startOf30DaysAgo = calendar.startOfDay(for: thirtyDaysAgo)
            
            let weightEntries = allEntries.filter { entry in
                guard entry.deletedAt == nil,
                      entry.weightKg != nil else { return false }
                let entryDate = calendar.startOfDay(for: entry.date)
                return entryDate >= startOf30DaysAgo && entryDate <= startOfToday
            }
            
            // Count weigh-ins in current week
            if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) {
                let weekStart = calendar.startOfDay(for: weekInterval.start)
                let weekEnd = calendar.startOfDay(for: weekInterval.end)
                
                self.weighInCountThisWeek = weightEntries.filter { entry in
                    let entryDate = calendar.startOfDay(for: entry.date)
                    return entryDate >= weekStart && entryDate < weekEnd
                }.count
            } else {
                self.weighInCountThisWeek = 0
            }
            
            // Generate contribution chart data (30 days, 3 rows × 10 columns)
            // Days now flow continuously from left to right, with each column containing 'rows' consecutive days
            var contributionData = Array(repeating: 0.0, count: 30)
            
            // Create a set of dates that have weigh-ins
            let weighInDates = Set(weightEntries.map { entry in
                calendar.startOfDay(for: entry.date)
            })
            
            // Calculate the start date exactly as the chart does (matches ContributionChartView init)
            let endDate = calendar.startOfDay(for: now)
            let totalDays = 3 * 10 // rows * columns
            let chartStartDate = calendar.date(byAdding: .day, value: -(totalDays - 1), to: endDate) ?? endDate
            
            // Map weigh-in dates to chart data array indices
            for column in 0..<10 {
                for row in 0..<3 {
                    // Calculate the actual date for this cell using the chart's date mapping
                    let dayOffset = column * 3 + row
                    if let cellDate = calendar.date(byAdding: .day, value: dayOffset, to: chartStartDate) {
                        let normalizedCellDate = calendar.startOfDay(for: cellDate)
                        // Check if this date has a weigh-in
                        if weighInDates.contains(normalizedCellDate) {
                            // Calculate the data array index: column * rows + row (where rows=3)
                            let dataIndex = column * 3 + row
                            if dataIndex < 30 {
                                contributionData[dataIndex] = 1.0
                            }
                        }
                    }
                }
            }
            
            self.weighInContributionData = contributionData
            
        } catch {
            // On error, set empty data
            self.weighInContributionData = Array(repeating: 0.0, count: 30)
            self.weighInCountThisWeek = 0
        }
    }

    enum Event: LoggableEvent {
        case onNotificationsPressed

        var eventName: String {
            switch self {
            case .onNotificationsPressed:   return "Dashboard_NotificationsPressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            default:
                return .analytic

            }
        }
    }
}
