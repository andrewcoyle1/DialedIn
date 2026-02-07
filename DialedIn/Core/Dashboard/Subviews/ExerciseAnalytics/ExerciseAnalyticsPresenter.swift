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
            let aggregated = ExerciseOneRMAggregator.aggregate(
                sessions: completed,
                calendar: calendar
            )

            let systemExercises = (try? interactor.getSystemExerciseTemplates()) ?? []
            let userExercises = (try? await interactor.getExerciseTemplatesForAuthor(authorId: userId)) ?? []
            var seenIds = Set<String>()
            let allExercises = (userExercises + systemExercises)
                .filter { seenIds.insert($0.id).inserted }
                .sorted { $0.name.localizedCompare($1.name) == .orderedAscending }

            let emptyData = Array(repeating: 0.0, count: 7)
            exerciseCards = allExercises.map { exercise in
                let data = aggregated[exercise.id]
                return ExerciseCardItem(
                    templateId: exercise.id,
                    name: exercise.name,
                    last7DaysData: data?.last7Days ?? emptyData,
                    latest1RM: data?.latest1RM ?? 0
                )
            }
        } catch {
            exerciseCards = []
        }
    }

    func onExercisePressed(templateId: String, name: String) {
        router.showExerciseDetailView(templateId: templateId, name: name, delegate: ExerciseDetailDelegate())
    }

    func onDismissPressed() {
        router.dismissScreen()
    }
}
