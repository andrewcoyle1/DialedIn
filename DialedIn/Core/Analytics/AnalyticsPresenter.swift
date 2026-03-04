//
//  AnalyticsPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import SwiftUI

@Observable
@MainActor
class AnalyticsPresenter {
    let interactor: AnalyticsInteractor
    let router: AnalyticsRouter

    var showNotifications: Bool = false
    var isShowingInspector: Bool = false
    private(set) var contributionChartData: [Double] = []
    private(set) var chartEndDate: Date = Date()

    // Workout data (set from AnalyticsPresenter+DataLoading)
    var workoutContributionData: [Double] = []
    var workoutCountThisWeek: Int = 0
    var workoutLast7Sessions: [WorkoutSessionModel] = []

    // Weigh-in data (set from AnalyticsPresenter+DataLoading)
    var weighInContributionData: [Double] = []
    var weighInCountThisWeek: Int = 0

    // Macros (last 7 days) (set from AnalyticsPresenter+DataLoading)
    var macrosLast7Days: [DailyMacroTarget] = []
    var dailyTarget: DailyMacroTarget?

    // Steps (set from AnalyticsPresenter+DataLoading)
    var stepsLast7: [StepsModel] = []

    // Muscle groups (set from AnalyticsPresenter+DataLoading)
    var muscleGroupCards: [MuscleGroupCardItem] = []

    // Exercises (set from AnalyticsPresenter+DataLoading)
    var exerciseCards: [ExerciseCardItem] = []

    let calendar = Calendar.current

    var isInNotificationsABTest: Bool {
        interactor.activeTests.notificationsTest
    }

    var userImageUrl: String? {
        interactor.userImageUrl
    }

    var workoutSessions: [WorkoutSessionModel] {
        interactor.workoutSessions
    }
    
    var systemExercises: [ExerciseModel] {
        interactor.systemExercises
    }
    
    var userExercises: [ExerciseModel] {
        interactor.userExercises
    }
    
    var allExercises: [ExerciseModel] {
        interactor.allExercises
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
        interactor: AnalyticsInteractor,
        router: AnalyticsRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: AnalyticsDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: AnalyticsDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }

    func onFirstTask() async {
        loadWorkoutData()
        loadWeighInData()
        loadMacrosData()
        await loadDailyTarget()
        loadMuscleGroupsData()
        await loadExerciseCardsData()
        await loadStepsData()
    }
    
    func handleDeepLink(url: URL) {
        interactor.trackEvent(event: Event.deepLinkStart)

        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems,
            !queryItems.isEmpty else {
            interactor.trackEvent(event: Event.deepLinkNoQueryItems)
            return
        }
        
        interactor.trackEvent(event: Event.deepLinkSuccess)
        
        for queryItem in queryItems {
            if let value = queryItem.value, !value.isEmpty {
                // Do something with value
            }
        }
    }

    func handlePushNotificationRecieved(notification: Notification) {
        interactor.trackEvent(event: Event.pushNotifStart)
        
        guard
            let userInfo = notification.userInfo,
            !userInfo.isEmpty else {
            interactor.trackEvent(event: Event.pushNotifNoData)
            return
        }
        
        interactor.trackEvent(event: Event.pushNotifSuccess)
        
        for (_, _) in userInfo {
            // Do something with (key, value)
        }
    }

    func onDevSettingsPressed() {
        #if MOCK || DEV
        interactor.trackEvent(event: Event.onDevSettings)
        router.showDevSettingsView()
        #else
        interactor.trackEvent(event: Event.onDevSettingsFail)
        #endif
    }

    func onSubscribePressed() {
        router.showPaywall()
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
        router.showExpenditureDetailView(delegate: ExpenditureDetailDelegate(), themeColor: themeColor)
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
        let filtered = interactor.bodyMeasurements.filter { $0.deletedAt == nil && $0.weightKg != nil }
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
        let filtered = interactor.bodyMeasurements.filter {
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
    
    func onCustomiseAnalyticsPressed() {
        router.showCustomiseAnalyticsView(delegate: CustomiseAnalyticsDelegate())
    }

    enum Event: LoggableEvent {
        case onAppear(delegate: AnalyticsDelegate)
        case onDisappear(delegate: AnalyticsDelegate)
        case onNotificationsPressed
        case deepLinkStart
        case deepLinkNoQueryItems
        case deepLinkSuccess
        case pushNotifStart
        case pushNotifNoData
        case pushNotifSuccess
        case onDevSettings
        case onDevSettingsFail

        var eventName: String {
            switch self {
            case .onAppear:                 return "AnalyticsView_Appear"
            case .onDisappear:              return "AnalyticsView_Disappear"
            case .onNotificationsPressed:   return "AnalyticsView_NotificationsPressed"
            case .deepLinkStart:            return "AnalyticsView_DeepLink_Start"
            case .deepLinkNoQueryItems:     return "AnalyticsView_DeepLink_NoItems"
            case .deepLinkSuccess:          return "AnalyticsView_DeepLink_Success"
            case .pushNotifStart:           return "AnalyticsView_PushNotif_Start"
            case .pushNotifNoData:          return "AnalyticsView_PushNotif_NoItems"
            case .pushNotifSuccess:         return "AnalyticsView_PushNotif_Success"
            case .onDevSettings:            return "AnalyticsView_DevSettings"
            case .onDevSettingsFail:        return "AnalyticsView_DevSettings_Fail"

            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .onDevSettingsFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
