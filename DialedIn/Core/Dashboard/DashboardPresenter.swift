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
    let interactor: DashboardInteractor
    let router: DashboardRouter

    private(set) var selectedDate: Date = Date.now
    var showNotifications: Bool = false
    var isShowingInspector: Bool = false
    private(set) var contributionChartData: [Double] = []
    private(set) var chartEndDate: Date = Date()
    var scaleWeightEntries: [BodyMeasurementEntry] = []

    // Workout data (set from DashboardPresenter+DataLoading)
    var workoutContributionData: [Double] = []
    var workoutCountThisWeek: Int = 0
    var workoutLast7Sessions: [WorkoutSessionModel] = []

    // Weigh-in data (set from DashboardPresenter+DataLoading)
    var weighInContributionData: [Double] = []
    var weighInCountThisWeek: Int = 0

    // Macros (last 7 days) (set from DashboardPresenter+DataLoading)
    var macrosLast7Days: [DailyMacroTarget] = []
    var dailyTarget: DailyMacroTarget?

    // Steps (set from DashboardPresenter+DataLoading)
    var stepsLast7: [StepsModel] = []

    // Muscle groups (set from DashboardPresenter+DataLoading)
    var muscleGroupCards: [MuscleGroupCardItem] = []

    // Exercises (set from DashboardPresenter+DataLoading)
    var exerciseCards: [ExerciseCardItem] = []

    let calendar = Calendar.current

    var isInNotificationsABTest: Bool {
        interactor.activeTests.notificationsTest
    }

    var userImageUrl: String? {
        interactor.userImageUrl
    }

    // MARK: - Nutrition (today's totals from macrosLast7Days.last)
    private var dailyTotals: DailyMacroTarget? { macrosLast7Days.last }

    var macrosAverageCalories: Double {
        guard !macrosLast7Days.isEmpty else { return 0 }
        return macrosLast7Days.map(\.calories).reduce(0, +) / Double(macrosLast7Days.count)
    }

    var proteinCurrent: Double { dailyTotals?.proteinGrams ?? 0 }
    var proteinTarget: Double? { dailyTarget?.proteinGrams }
    var proteinMax: Double {
        let target = dailyTarget?.proteinGrams ?? 150
        return max(proteinCurrent, target * 1.2)
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
        await loadDailyTarget()
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

    func onScaleWeightPressed(themeColor: Color?) {
        router.showScaleWeightView(delegate: ScaleWeightDelegate(), themeColor: themeColor)
    }

    func onWeighInConsistencyPressed(themeColor: Color?) {
        router.showWeighInConsistencyView(delegate: WeighInConsistencyDelegate(), themeColor: themeColor)
    }

    func onVisualBodyFatPressed(themeColor: Color?) {
        router.showVisualBodyFatView(delegate: VisualBodyFatDelegate(), themeColor: themeColor)
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

    func onMacrosPressed(themeColor: Color?) {
        router.showNutritionMetricDetailView(metric: .macros, delegate: NutritionMetricDetailDelegate(), themeColor: themeColor)
    }

    func onProteinPressed(themeColor: Color?) {
        router.showNutritionMetricDetailView(metric: .protein, delegate: NutritionMetricDetailDelegate(), themeColor: themeColor)
    }
    
    func onSeeAllBodyMetricsPressed() {
        router.showBodyMetricsView(delegate: BodyMetricsDelegate())
    }
    
    func onSeeAllMuscleGroupsPressed() {
        router.showMuscleGroupsView(delegate: MuscleGroupsDelegate())
    }

    func onMuscleGroupPressed(muscle: Muscles, themeColor: Color?) {
        router.showMuscleGroupDetailView(muscle: muscle, delegate: MuscleGroupDetailDelegate(), themeColor: themeColor)
    }

    func onExercisePressed(templateId: String, name: String, themeColor: Color?) {
        router.showExerciseDetailView(templateId: templateId, name: name, delegate: ExerciseDetailDelegate(), themeColor: themeColor)
    }
    
    func onSeeAllExercisesPressed() {
        router.showExerciseAnalyticsView(delegate: ExerciseAnalyticsDelegate())
    }

    func onWeightTrendPressed(themeColor: Color?) {
        router.showWeightTrendView(delegate: WeightTrendDelegate(), themeColor: themeColor)
    }

    func onGoalProgressPressed(themeColor: Color?) {
        router.showGoalProgressView(delegate: GoalProgressDelegate(), themeColor: themeColor)
    }

    func onEnergyBalancePressed(themeColor: Color?) {
        router.showEnergyBalanceView(delegate: EnergyBalanceDelegate(), themeColor: themeColor)
    }

    func onWorkoutsPressed(themeColor: Color?) {
        router.showWorkoutView(delegate: WorkoutDelegate(), themeColor: themeColor)
    }

    func onWorkoutConsistencyPressed(themeColor: Color?) {
        router.showWorkoutConsistencyView(delegate: WorkoutConsistencyDelegate(), themeColor: themeColor)
    }

    func onExpenditurePressed(themeColor: Color?) {
        router.showExpenditureView(delegate: ExpenditureDelegate(), themeColor: themeColor)
    }

    func onStepsPressed(themeColor: Color?) {
        router.showStepsView(delegate: StepsDelegate(), themeColor: themeColor)
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
