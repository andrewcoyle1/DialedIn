import SwiftUI

@Observable
@MainActor
class ExerciseAnalyticsPresenter {

    private let interactor: ExerciseAnalyticsInteractor
    private let router: ExerciseAnalyticsRouter
    private let calendar = Calendar.current

    private(set) var exerciseCards: [ExerciseCardItem] = []

    init(interactor: ExerciseAnalyticsInteractor, router: ExerciseAnalyticsRouter) {
        self.interactor = interactor
        self.router = router
    }

    func loadData() async {
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

            let systemExercises: [ExerciseModel] = (try? interactor.getSystemExerciseTemplates()) ?? []
            let userExercises: [ExerciseModel] = (try? await interactor.getExerciseTemplatesForAuthor(authorId: userId)) ?? []
            var seenIds = Set<String>()
            let combined: [ExerciseModel] = userExercises + systemExercises
            let allExercises: [ExerciseModel] = combined
                .filter { (template: ExerciseModel) in
                    seenIds.insert(template.id).inserted
                }
                .sorted { (lhs: ExerciseModel, rhs: ExerciseModel) in
                    lhs.name.localizedCompare(rhs.name) == .orderedAscending
                }

            self.exerciseCards = allExercises.map { (exercise: ExerciseModel) -> ExerciseCardItem in
                let data = aggregated[exercise.id]
                let sparkline: [(date: Date, value: Double)] = (data?.last7Workouts ?? []).map { (date: $0.date, value: $0.value) }
                return ExerciseCardItem(
                    templateId: exercise.id,
                    name: exercise.name,
                    sparklineData: sparkline,
                    latest1RM: data?.latest1RM ?? 0
                )
            }
        } catch {
            exerciseCards = []
        }
    }

    func onExercisePressed(templateId: String, name: String, themeColor: Color?) {
        router.showExerciseDetailView(templateId: templateId, name: name, delegate: ExerciseDetailDelegate(), themeColor: themeColor)
    }

    func onDismissPressed() {
        router.dismissScreen()
    }
}
