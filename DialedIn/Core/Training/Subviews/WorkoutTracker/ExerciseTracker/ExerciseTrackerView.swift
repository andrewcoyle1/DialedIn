//
//  ExerciseTrackerView.swift
//  DialedIn
//
//
//

import SwiftUI

struct ExerciseTrackerDelegate {
    let exercise: Binding<WorkoutExerciseModel>
    let lastExercise: WorkoutExerciseModel?
    var isExpanded: Binding<Bool> = .constant(false)
    var allWorkoutExercises: [WorkoutExerciseModel] = []
    var supersetLabel: String?
    /// The one line smart progression has to say about this exercise, if anything.
    var progressionHint: String?
    /// What the engine suggests for this exercise's working sets, shown by the Auto column.
    var progressionSuggestion: ProgressionSuggestion?
    var onSetSupersetGroup: @MainActor (String, String?) -> Void = { _, _ in }
    var onDeleteExercise: @MainActor () -> Void = { }
    /// Called with the set that was just logged, so the screen can re-suggest what is left.
    var onSetCompleted: @MainActor (WorkoutSetModel, WorkoutExerciseModel) -> Void = { _, _ in }
}

struct ExerciseTrackerView<SetTracker: View>: View {

    @State var presenter: ExerciseTrackerPresenter
    let delegate: ExerciseTrackerDelegate

    @ViewBuilder var setTracker: (SetTrackerDelegate) -> SetTracker

    var body: some View {
        DisclosureGroup(isExpanded: delegate.isExpanded) {
            let setDelegate = SetTrackerDelegate(
                exercise: delegate.exercise,
                lastExercise: delegate.lastExercise,
                progressionSuggestion: delegate.progressionSuggestion,
                allWorkoutExercises: delegate.allWorkoutExercises,
                onSetSupersetGroup: delegate.onSetSupersetGroup,
                onDeleteExercise: delegate.onDeleteExercise,
                onSetCompleted: delegate.onSetCompleted
            )
            setTracker(setDelegate)
        } label: {
            exerciseHeader(delegate.exercise.wrappedValue)
        }
    }

    @ViewBuilder
    func exerciseHeader(_ exercise: WorkoutExerciseModel) -> some View {
        HStack(alignment: .center) {
            ImageLoaderView(urlString: exercise.imageName ?? Constants.randomImage, resizingMode: .fit)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading) {
                HStack(spacing: 6) {
                    Text(exercise.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)

                    if let label = delegate.supersetLabel {
                        Text(label)
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .clipShape(Capsule())
                    }
                }

                // Counted in sets, not rows: three sets a side reads "Set 2/3", not "Set 4/6".
                Text("Set \(min(exercise.loggedSetCount + 1, exercise.workingSetCount))/\(exercise.workingSetCount)")
                    .font(.caption)
                    .foregroundColor(exercise.loggedSetCount == exercise.workingSetCount ? .green : .secondary)

                if let progressionHint = delegate.progressionHint {
                    Text(progressionHint)
                        .font(.caption)
                        .foregroundStyle(.blue)
                        .lineLimit(1)
                }

                if let note = presenter.note(for: exercise) {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
            }
        }
        .tappableBackground()
        .listRowInsets(.vertical, .zero)
    }
}

#Preview {
    @Previewable @State var exercise: WorkoutExerciseModel = WorkoutExerciseModel.mock
    @Previewable @State var session: WorkoutSessionModel = WorkoutSessionModel.mock
    let lastExercise: WorkoutExerciseModel = .mock
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = ExerciseTrackerDelegate(exercise: $exercise, lastExercise: lastExercise)

    RouterView { router in
        builder.exerciseTrackerView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    func exerciseTrackerView(
        router: AnyRouter,
        delegate: ExerciseTrackerDelegate,
        onStartRest: ((Int) -> Void)? = nil
    ) -> some View {
        ExerciseTrackerView(
            presenter: ExerciseTrackerPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate,
            setTracker: { delegate in
                self.setTrackerView(
                    router: router,
                    delegate: delegate,
                    onStartRest: onStartRest
                )
            }
        )
    }
}
