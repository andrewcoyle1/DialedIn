//
//  EditableExerciseCardWrapper.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

struct EditableExerciseCardWrapperDelegate {
    var exercise: WorkoutExerciseModel
    var index: Int
    var weightUnit: ExerciseWeightUnit
    var distanceUnit: ExerciseDistanceUnit
    var onExerciseUpdate: (WorkoutExerciseModel) -> Void
    var onAddSet: () -> Void
    var onDeleteSet: (String) -> Void
    var onWeightUnitChange: (ExerciseWeightUnit) -> Void
    var onDistanceUnitChange: (ExerciseDistanceUnit) -> Void
}

struct EditableExerciseCardWrapper: View {
    
    @State var viewModel: EditableExerciseCardWrapperViewModel

    var delegate: EditableExerciseCardWrapperDelegate

    init(
        delegate: EditableExerciseCardWrapperDelegate,
        interactor: EditableExerciseCardWrapperInteractor
    ) {
        self.delegate = delegate
        _viewModel = State(
            wrappedValue: EditableExerciseCardWrapperViewModel(
                interactor: interactor,
                exercise: delegate.exercise,
                index: delegate.index,
                weightUnit: delegate.weightUnit,
                distanceUnit: delegate.distanceUnit
            )
        )
    }
    
    var body: some View {
        EditableExerciseCardView(
            exercise: $viewModel.localExercise,
            index: viewModel.index,
            weightUnit: viewModel.weightUnit,
            distanceUnit: viewModel.distanceUnit,
            onAddSet: {
                delegate.onAddSet()
            },
            onDeleteSet: { setId in
                delegate.onDeleteSet(setId)
            },
            onWeightUnitChange: { unit in
                delegate.onWeightUnitChange(unit)
                viewModel.weightUnit = unit
            },
            onDistanceUnitChange: { unit in
                delegate.onDistanceUnitChange(unit)
                viewModel.distanceUnit = unit
            }
        )
        .onChange(of: viewModel.localExercise) { _, newValue in
            delegate.onExerciseUpdate(newValue)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    List {
        builder.editableExerciseCardWrapper(
            delegate: EditableExerciseCardWrapperDelegate(
                exercise: WorkoutExerciseModel.mock,
                index: 1,
                weightUnit: ExerciseWeightUnit.kilograms,
                distanceUnit: ExerciseDistanceUnit.meters,
                onExerciseUpdate: { _ in },
                onAddSet: { },
                onDeleteSet: { _ in },
                onWeightUnitChange: { _ in },
                onDistanceUnitChange: { _ in }
            )
        )
    }
}
