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
    private(set) var workoutLast7Sessions: [WorkoutSessionModel] = []
    
    // Weigh-in data
    private(set) var weighInContributionData: [Double] = []
    private(set) var weighInCountThisWeek: Int = 0
    
    // Macros (last 7 days)
    private(set) var macrosLast7Days: [DailyMacroTarget] = []

    // Steps (from StepsManager - last 7 days for card)
    private(set) var stepsLast7: [StepsModel] = []

    // Muscle groups (last 7 days sets per muscle)
    private(set) var muscleGroupCards: [(muscle: Muscles, last7DaysData: [Double], totalSets: Double)] = []

    // Exercises (last 7 days 1-RM per exercise)
    private(set) var exerciseCards: [ExerciseCardItem] = []

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
        loadMacrosData()
        await loadMuscleGroupsData()
        await loadExerciseCardsData()
        await loadStepsData()
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
    
    func onSeeAllNutritionAnalyticsPressed() {
        router.showNutritionAnalyticsView(delegate: NutritionAnalyticsDelegate())
    }

    func onMacrosPressed() {
        router.showNutritionMetricDetailView(metric: .macros, delegate: NutritionMetricDetailDelegate())
    }

    func onProteinPressed() {
        router.showNutritionMetricDetailView(metric: .protein, delegate: NutritionMetricDetailDelegate())
    }
    
    func onSeeAllBodyMetricsPressed() {
        router.showBodyMetricsView(delegate: BodyMetricsDelegate())
    }
    
    func onSeeAllMuscleGroupsPressed() {
        router.showMuscleGroupsView(delegate: MuscleGroupsDelegate())
    }

    func onMuscleGroupPressed(muscle: Muscles) {
        router.showMuscleGroupDetailView(muscle: muscle, delegate: MuscleGroupDetailDelegate())
    }

    func onExercisePressed(templateId: String, name: String) {
        router.showExerciseDetailView(templateId: templateId, name: name, delegate: ExerciseDetailDelegate())
    }
    
    func onSeeAllExercisesPressed() {
        router.showExerciseAnalyticsView(delegate: ExerciseAnalyticsDelegate())
    }

    func onWeightTrendPressed() {
        router.showWeightTrendView(delegate: WeightTrendDelegate())
    }

    func onGoalProgressPressed() {
        router.showGoalProgressView(delegate: GoalProgressDelegate())
    }

    func onEnergyBalancePressed() {
        router.showEnergyBalanceView(delegate: EnergyBalanceDelegate())
    }

    func onWorkoutsPressed() {
        router.showWorkoutView(delegate: WorkoutDelegate())
    }

    func onExpenditurePressed() {
        router.showExpenditureView(delegate: ExpenditureDelegate())
    }

    func onStepsPressed() {
        router.showStepsView(delegate: StepsDelegate())
    }

    var stepsSparklineData: [(date: Date, value: Double)] {
        stepsLast7.map { (date: $0.date, value: Double($0.number)) }
    }

    var stepsSubtitle: String {
        stepsLast7.isEmpty ? "No Data" : "Last 7 Days"
    }

    var stepsLatestValueText: String {
        guard let latest = stepsLast7.last else { return "--" }
        return "\(latest.number)"
    }

    var stepsUnitText: String {
        "steps"
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

    var weightTrendSparklineData: [(date: Date, value: Double)] {
        let pairs = scaleWeightLastEntries.compactMap { entry -> (date: Date, value: Double)? in
            guard let weightKg = entry.weightKg else { return nil }
            return (date: entry.date, value: weightKg)
        }
        return WeightTrendCalculator.exponentialMovingAverage(data: pairs)
    }

    var weightTrendSubtitle: String {
        scaleWeightLastEntries.isEmpty ? "No Entries" : "Last 7 Days"
    }

    var weightTrendLatestValueText: String {
        let trend = weightTrendSparklineData
        guard let last = trend.last else { return "--" }
        return last.value.formatted(.number.precision(.fractionLength(1)))
    }

    var weightTrendUnitText: String {
        "kg"
    }

    var energyBalanceExpenditure: TimeSeriesData.TimeSeries {
        let tdee = interactor.estimateTDEE(user: interactor.currentUser)
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: startOfToday) else {
            return TimeSeriesData.TimeSeries(name: "Expenditure", data: [])
        }
        var data: [TimeSeriesDatapoint] = []
        for offset in -1..<7 {
            guard let date = calendar.date(byAdding: .day, value: offset, to: startDate) else { continue }
            data.append(TimeSeriesDatapoint(id: "exp-\(offset)", date: date, value: tdee))
        }
        return TimeSeriesData.TimeSeries(name: "Expenditure", data: data)
    }

    var energyBalanceIntake: TimeSeriesData.TimeSeries {
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: startOfToday) else {
            return TimeSeriesData.TimeSeries(name: "Intake", data: [])
        }
        var data: [TimeSeriesDatapoint] = []
        for (offset, totals) in macrosLast7Days.enumerated() {
            guard let date = calendar.date(byAdding: .day, value: offset, to: startDate) else { continue }
            data.append(TimeSeriesDatapoint(id: "intake-\(offset)", date: date, value: totals.calories))
        }
        return TimeSeriesData.TimeSeries(name: "Intake", data: data)
    }

    var energyBalanceSubtitle: String {
        "Last 7 Days"
    }

    var energyBalanceLatestValueText: String {
        guard macrosLast7Days.count == 7 else { return "--" }
        let tdee = interactor.estimateTDEE(user: interactor.currentUser)
        let avgIntake = macrosLast7Days.map(\.calories).reduce(0, +) / 7
        let deficit = tdee - avgIntake
        let value = Int(deficit.rounded())
        if value > 0 {
            return "\(value) deficit"
        } else if value < 0 {
            return "\(-value) surplus"
        }
        return "Balanced"
    }

    var energyBalanceUnitText: String {
        "kcal"
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

    var workoutSparklineData: [(date: Date, value: Double)] {
        workoutLast7Sessions.map { session in
            let date = session.endedAt ?? session.dateCreated
            let setCount = session.exercises.flatMap { $0.sets }.filter { !$0.isWarmup }.count
            return (date: date, value: Double(setCount))
        }
    }

    var workoutSubtitle: String {
        workoutLast7Sessions.isEmpty ? "No Workouts" : "Last 7 Workouts"
    }

    var workoutLatestValueText: String {
        let total = workoutLast7Sessions.reduce(0) { sum, session in
            sum + session.exercises.flatMap { $0.sets }.filter { !$0.isWarmup }.count
        }
        return total > 0 ? "\(total)" : "--"
    }

    var workoutUnitText: String {
        "sets"
    }

    var expenditureSparklineData: [(date: Date, value: Double)] {
        let tdee = interactor.estimateTDEE(user: interactor.currentUser)
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: startOfToday) else {
            return []
        }
        return (0..<7).compactMap { offset -> (date: Date, value: Double)? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: startDate) else { return nil }
            return (date: date, value: tdee)
        }
    }

    var expenditureSubtitle: String {
        "Last 7 Days"
    }

    var expenditureLatestValueText: String {
        let tdee = interactor.estimateTDEE(user: interactor.currentUser)
        return tdee > 0 ? "\(Int(tdee.rounded()))" : "--"
    }

    var expenditureUnitText: String {
        "kcal"
    }
    
    func onCustomiseDashboardPressed() {
        router.showCustomiseDashboardView(delegate: CustomiseDashboardDelegate())
    }

    func loadWorkoutData() {
        guard let userId = interactor.auth?.uid else {
            workoutContributionData = Array(repeating: 0.0, count: 30)
            workoutLast7Sessions = []
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

            // Cache last 7 completed sessions for Insights card
            let completed = allSessions
                .filter { $0.endedAt != nil }
                .sorted { ($0.endedAt ?? .distantPast) > ($1.endedAt ?? .distantPast) }
            self.workoutLast7Sessions = Array(completed.prefix(7))
                .sorted { ($0.endedAt ?? .distantPast) < ($1.endedAt ?? .distantPast) }
            
        } catch {
            // On error, set empty data
            self.workoutContributionData = Array(repeating: 0.0, count: 30)
            self.workoutCountThisWeek = 0
            self.workoutLast7Sessions = []
        }
    }

    func loadMuscleGroupsData() async {
        guard let userId = interactor.auth?.uid else {
            muscleGroupCards = []
            return
        }
        do {
            let sessions = try interactor.getLocalWorkoutSessionsForAuthor(
                authorId: userId,
                limitTo: 0
            )
            let completed = sessions.filter { $0.endedAt != nil }

            let templateIds = Set(completed.flatMap { $0.exercises.map(\.templateId) })
            let templates: [String: ExerciseModel]
            if templateIds.isEmpty {
                templates = [:]
            } else {
                let fetched = try await interactor.getExerciseTemplates(
                    ids: Array(templateIds),
                    limitTo: templateIds.count
                )
                templates = Dictionary(uniqueKeysWithValues: fetched.map { ($0.id, $0) })
            }

            let aggregated = MuscleGroupSetsAggregator.aggregate(
                sessions: completed,
                templates: templates,
                calendar: calendar
            )

            // Build cards for muscles with recent activity, or top 2 from upper body as default
            let musclesWithData = Muscles.allCases
                .filter { (aggregated[$0]?.total ?? 0) > 0 }
                .sorted { (aggregated[$0]?.total ?? 0) > (aggregated[$1]?.total ?? 0) }

            if musclesWithData.isEmpty {
                muscleGroupCards = [Muscles.upperBack, Muscles.rearDelts].map { muscle in
                    let data = aggregated[muscle] ?? (Array(repeating: 0.0, count: 7), 0.0)
                    return (muscle: muscle, last7DaysData: data.last7Days, totalSets: data.total)
                }
            } else {
                muscleGroupCards = Array(musclesWithData.prefix(2)).map { muscle in
                    let data = aggregated[muscle] ?? (Array(repeating: 0.0, count: 7), 0.0)
                    return (muscle: muscle, last7DaysData: data.last7Days, totalSets: data.total)
                }
            }
        } catch {
            muscleGroupCards = [Muscles.upperBack, Muscles.rearDelts].map { muscle in
                (muscle: muscle, last7DaysData: Array(repeating: 0.0, count: 7), totalSets: 0.0)
            }
        }
    }

    func loadExerciseCardsData() async {
        guard let userId = interactor.auth?.uid else {
            exerciseCards = []
            return
        }
        do {
            let sessions = try interactor.getLocalWorkoutSessionsForAuthor(
                authorId: userId,
                limitTo: 0
            )
            let completed = sessions.filter { $0.endedAt != nil }
            let aggregated = ExerciseOneRMAggregator.aggregate(sessions: completed)

            let systemExercises = (try? interactor.getSystemExerciseTemplates()) ?? []
            let userExercises = (try? await interactor.getExerciseTemplatesForAuthor(authorId: userId)) ?? []
            var seenIds = Set<String>()
            let allExercises = (userExercises + systemExercises)
                .filter { seenIds.insert($0.id).inserted }
                .sorted { $0.name.localizedCompare($1.name) == .orderedAscending }

            let emptySparkline: [(date: Date, value: Double)] = []
            let allCards = allExercises.map { exercise in
                let data = aggregated[exercise.id]
                return ExerciseCardItem(
                    templateId: exercise.id,
                    name: exercise.name,
                    sparklineData: data?.last7Workouts ?? emptySparkline,
                    latest1RM: data?.latest1RM ?? 0
                )
            }
            exerciseCards = Array(allCards.sorted { $0.latest1RM > $1.latest1RM }.prefix(2))
        } catch {
            exerciseCards = []
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
    
    func loadMacrosData() {
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: startOfToday) else { return }
        
        var totals: [DailyMacroTarget] = []
        totals.reserveCapacity(7)
        for offset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: offset, to: startDate) ?? startDate
            let key = date.dayKey
            do {
                let dayTotals = try interactor.getDailyTotals(dayKey: key)
                totals.append(dayTotals)
            } catch {
                totals.append(DailyMacroTarget(calories: 0, proteinGrams: 0, carbGrams: 0, fatGrams: 0))
            }
        }
        macrosLast7Days = totals
    }

    func loadStepsData() async {
        await interactor.backfillStepsFromHealthKit()
        _ = try? interactor.readAllLocalStepsEntries()
        let history = interactor.stepsHistory
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: startOfToday) else {
            stepsLast7 = []
            return
        }
        let userId = interactor.userId
        let last7 = history
            .filter { $0.deletedAt == nil && $0.date >= startDate && $0.date <= startOfToday && (userId == nil || $0.authorId == userId) }
            .sorted { $0.date < $1.date }
        stepsLast7 = Array(Self.consolidateStepsByDay(Array(last7)).suffix(7))
    }

    private static func consolidateStepsByDay(_ entries: [StepsModel]) -> [StepsModel] {
        let byDay = Dictionary(grouping: entries) { Calendar.current.startOfDay(for: $0.date) }
        return byDay.compactMap { (_, dayEntries) in
            dayEntries.max { $0.number < $1.number }
        }.sorted { $0.date < $1.date }
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
