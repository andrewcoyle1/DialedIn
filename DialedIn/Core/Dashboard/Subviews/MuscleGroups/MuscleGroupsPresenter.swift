import SwiftUI

@Observable
@MainActor
class MuscleGroupsPresenter {

    private let interactor: MuscleGroupsInteractor
    private let router: MuscleGroupsRouter
    private let calendar = Calendar.current

    private(set) var muscleSetsData: [Muscles: (last7Days: [Double], total: Double)] = [:]

    var upperMuscles: [Muscles] {
        Muscles.allCases.filter { $0.bodyRegion == .upperBody }
    }

    var lowerMuscles: [Muscles] {
        Muscles.allCases.filter { $0.bodyRegion == .lowerBody }
    }

    init(interactor: MuscleGroupsInteractor, router: MuscleGroupsRouter) {
        self.interactor = interactor
        self.router = router
    }

    func loadData() async {
        guard let userId = interactor.auth?.uid else {
            muscleSetsData = [:]
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

            muscleSetsData = MuscleGroupSetsAggregator.aggregate(
                sessions: completed,
                templates: templates,
                calendar: calendar
            )
        } catch {
            muscleSetsData = [:]
        }
    }

    func setsData(for muscle: Muscles) -> (last7Days: [Double], total: Double) {
        muscleSetsData[muscle] ?? (Array(repeating: 0, count: 7).map(Double.init), 0.0)
    }

    func onMusclePressed(muscle: Muscles) {
        router.showMuscleGroupDetailView(muscle: muscle, delegate: MuscleGroupDetailDelegate())
    }

    func onDismissPressed() {
        router.dismissScreen()
    }
}
