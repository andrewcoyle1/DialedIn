import SwiftUI

@Observable
@MainActor
class InsightsAndAnalyticsPresenter {

    private let interactor: InsightsAndAnalyticsInteractor
    private let router: InsightsAndAnalyticsRouter
    private let calendar = Calendar.current

    private(set) var scaleWeightEntries: [BodyMeasurementEntry] = []
    private(set) var macrosLast7Days: [DailyMacroTarget] = []
    private(set) var workoutLast7Sessions: [WorkoutSessionModel] = []

    init(interactor: InsightsAndAnalyticsInteractor, router: InsightsAndAnalyticsRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onFirstTask() async {
        loadLocalScaleWeightEntries()
        loadMacrosData()
        loadWorkoutData()
    }

    private func loadMacrosData() {
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

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onWeightTrendPressed() {
        router.showWeightTrendView(delegate: WeightTrendDelegate())
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

    var weightTrendSparklineData: [(date: Date, value: Double)] {
        let pairs = weightTrendLastEntries.compactMap { entry -> (date: Date, value: Double)? in
            guard let weightKg = entry.weightKg else { return nil }
            return (date: entry.date, value: weightKg)
        }
        return WeightTrendCalculator.exponentialMovingAverage(data: pairs)
    }

    var weightTrendSubtitle: String {
        weightTrendLastEntries.isEmpty ? "No Entries" : "Last 7 Days"
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

    private func loadWorkoutData() {
        guard let userId = interactor.auth?.uid else {
            workoutLast7Sessions = []
            return
        }
        do {
            let allSessions = try interactor.getLocalWorkoutSessionsForAuthor(
                authorId: userId,
                limitTo: 0
            )
            let completed = allSessions
                .filter { $0.endedAt != nil }
                .sorted { ($0.endedAt ?? .distantPast) > ($1.endedAt ?? .distantPast) }
            workoutLast7Sessions = Array(completed.prefix(7))
                .sorted { ($0.endedAt ?? .distantPast) < ($1.endedAt ?? .distantPast) }
        } catch {
            workoutLast7Sessions = []
        }
    }

    private var weightTrendLastEntries: [BodyMeasurementEntry] {
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
}
