//
//  ExerciseTrackerView.swift
//  DialedIn
//
//
//

import SwiftUI

struct ExerciseTrackerDelegate {
    let exercise: Binding<WorkoutExerciseModel>
//    let workoutSession: Binding<WorkoutSessionModel>
//    let previousLookup: [Int: WorkoutSetModel]
//    let onUpdateSet: (WorkoutSetModel, String) -> Void
//    let restBeforeSetIdToSec: [String: Int]
//    let defaultRestDurationSeconds: Int
//    let onUpdateRestBefore: (String, Int?) -> Void
}

struct ExerciseTrackerView<SetTracker:View>: View {

    @State var presenter: ExerciseTrackerPresenter
    let delegate: ExerciseTrackerDelegate

    @ViewBuilder var setTracker: (Binding<WorkoutExerciseModel>) -> SetTracker

    var body: some View {
        DisclosureGroup {
            setTracker(delegate.exercise)
                .listRowSpacing(0)
        } label: {
            exerciseHeader(delegate.exercise.wrappedValue)
        }
    }

    @ViewBuilder
    func exerciseHeader(_ exercise: WorkoutExerciseModel) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                Text("Set \(exercise.completedSetsCount)/\(exercise.sets.count)")
                    .font(.caption)
                    .foregroundColor(exercise.completedSetsCount == exercise.sets.count ? .green : .secondary)
            }
        }
        .tappableBackground()
        .listRowInsets(.vertical, .zero)
    }
}

#Preview {
    @Previewable @State var exercise: WorkoutExerciseModel = WorkoutExerciseModel.mock
    @Previewable @State var session: WorkoutSessionModel = WorkoutSessionModel.mock
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = ExerciseTrackerDelegate(
        exercise: $exercise,
//        workoutSession: $session,
//        previousLookup: [:],
//        onUpdateSet: { _, _ in },
//        restBeforeSetIdToSec: [:],
//        defaultRestDurationSeconds: 90,
//        onUpdateRestBefore: { _, _ in }
    )

    RouterView { router in
        builder.exerciseTrackerView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    func exerciseTrackerView(router: AnyRouter, delegate: ExerciseTrackerDelegate) -> some View {
        ExerciseTrackerView(
            presenter: ExerciseTrackerPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate,
            setTracker: { exercise in
                self.setTrackerView(router: router, delegate: SetTrackerDelegate(
                    exercise: exercise,
//                    workoutSession: delegate.workoutSession,
//                    previousLookup: delegate.previousLookup,
//                    onUpdateSet: delegate.onUpdateSet,
//                    restBeforeSetIdToSec: delegate.restBeforeSetIdToSec,
//                    defaultRestDurationSeconds: delegate.defaultRestDurationSeconds,
//                    onUpdateRestBefore: delegate.onUpdateRestBefore
                ))
            }
        )
    }
}
