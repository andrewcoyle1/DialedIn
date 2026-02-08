import SwiftUI

@Observable
@MainActor
class HabitsPresenter {
    
    private let interactor: HabitsInteractor
    private let router: HabitsRouter
    
    private(set) var workoutSessions: [WorkoutSessionModel] = []
    private(set) var workoutContributionData: [Double] = []
    private(set) var workoutCountLast30Days: Int = 0
    private(set) var workoutCountThisWeek: Int = 0
    
    private(set) var weighInContributionData: [Double] = []
    private(set) var weighInCountThisWeek: Int = 0
    
    private(set) var foodLoggingContributionData: [Double] = []
    private(set) var foodLoggingCountThisWeek: Int = 0
    
    private let calendar = Calendar.current
    
    init(interactor: HabitsInteractor, router: HabitsRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }

    func onWeighInPressed() {
        router.showScaleWeightView(delegate: ScaleWeightDelegate())
    }

    func onWorkoutsPressed() {
        router.showWorkoutView(delegate: WorkoutDelegate())
    }

    func onFoodLoggingPressed() {
        router.showNutritionMetricDetailView(metric: .calories, delegate: NutritionMetricDetailDelegate())
    }
    
    func onFirstTask() async {
        loadWorkoutData()
        loadWeighInData()
        loadFoodLoggingData()
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
            
            self.workoutSessions = completedSessions
            
            // Count workouts in last 30 days
            self.workoutCountLast30Days = completedSessions.count
            
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
            self.workoutSessions = []
            self.workoutContributionData = Array(repeating: 0.0, count: 30)
            self.workoutCountLast30Days = 0
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

    func loadFoodLoggingData() {
        do {
            let now = Date()
            let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now) ?? now
            let startOfToday = calendar.startOfDay(for: now)
            let startOf30DaysAgo = calendar.startOfDay(for: thirtyDaysAgo)
            let startDayKey = startOf30DaysAgo.dayKey
            let endDayKey = startOfToday.dayKey

            let totalsData = try interactor.getDailyTotals(startDayKey: startDayKey, endDayKey: endDayKey)

            // Days with logged food: calories > 0 (or any macro > 0)
            let foodLoggedDates = Set(totalsData.compactMap { item -> Date? in
                let total = item.totals.proteinGrams + item.totals.carbGrams + item.totals.fatGrams
                guard total > 0, let date = Date(dayKey: item.dayKey) else { return nil }
                return calendar.startOfDay(for: date)
            })

            // Count food logging days in current week
            if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) {
                let weekStart = calendar.startOfDay(for: weekInterval.start)
                let weekEnd = calendar.startOfDay(for: weekInterval.end)

                self.foodLoggingCountThisWeek = foodLoggedDates.filter { date in
                    date >= weekStart && date < weekEnd
                }.count
            } else {
                self.foodLoggingCountThisWeek = 0
            }

            // Generate contribution chart data (30 days, 3 rows × 10 columns)
            var contributionData = Array(repeating: 0.0, count: 30)
            let endDate = calendar.startOfDay(for: now)
            let totalDays = 3 * 10
            let chartStartDate = calendar.date(byAdding: .day, value: -(totalDays - 1), to: endDate) ?? endDate

            for column in 0..<10 {
                for row in 0..<3 {
                    let dayOffset = column * 3 + row
                    if let cellDate = calendar.date(byAdding: .day, value: dayOffset, to: chartStartDate) {
                        let normalizedCellDate = calendar.startOfDay(for: cellDate)
                        if foodLoggedDates.contains(normalizedCellDate) {
                            let dataIndex = column * 3 + row
                            if dataIndex < 30 {
                                contributionData[dataIndex] = 1.0
                            }
                        }
                    }
                }
            }

            self.foodLoggingContributionData = contributionData

        } catch {
            self.foodLoggingContributionData = Array(repeating: 0.0, count: 30)
            self.foodLoggingCountThisWeek = 0
        }
    }
}
