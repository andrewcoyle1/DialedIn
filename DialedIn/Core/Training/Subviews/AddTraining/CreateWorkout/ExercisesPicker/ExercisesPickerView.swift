//
//  ExercisesPickerView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
import SwiftfulRouting

struct ExercisesPickerDelegate {
    var addedExercises: Binding<[WorkoutTemplateExercise]>
}

struct ExercisesPickerView<ExerciseList: View>: View {

    @State var presenter: ExercisesPickerPresenter
    
    @ViewBuilder var exerciseListViewBuilder: (ExerciseListBuilderDelegate) -> ExerciseList
    
    var body: some View {
        
        let listDelegate = ExerciseListBuilderDelegate(
            onExerciseSelectionChanged: presenter.onExercisePressed,
            selectedExercises: presenter.workingExercises.map(\.exercise)
        )
        exerciseListViewBuilder(listDelegate)
            .navigationTitle(presenter.workingExercises.isEmpty ? "Select at least one exercise" : "\(presenter.workingExercises.count) exercises selected")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarVisibility(.visible)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .close) {
                        presenter.onDismissPressed()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .confirm) {
                        presenter.onSavePressed()
                    }
                }

            }
            .onDisappear {
                
            }
    }
}

extension CoreBuilder {
    func exercisesPickerView(router: AnyRouter, delegate: ExercisesPickerDelegate) -> some View {
        ExercisesPickerView(
            presenter: ExercisesPickerPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                delegate: delegate
            ),
            exerciseListViewBuilder: { delegate in
                exerciseListBuilderView(router: router, delegate: delegate)
            }
        )
    }
}

extension CoreRouter {
    func showExercisesPickerView(delegate: ExercisesPickerDelegate) {
        router.showScreen(.sheet) { router in
            builder.exercisesPickerView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    @Previewable @State var pickedExercises: [WorkoutTemplateExercise] = []
    let builder = CoreBuilder(container: DevPreview.shared.container())
    let delegate = ExercisesPickerDelegate(addedExercises: $pickedExercises)
    
    RouterView { router in
        builder.exercisesPickerView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
