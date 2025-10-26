//
//  EditableExerciseCardWrapper.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

struct EditableExerciseCardWrapper: View {
    
    @State var viewModel: EditableExerciseCardWrapperViewModel
    
    init(
        viewModel: EditableExerciseCardWrapperViewModel
    ) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        EditableExerciseCardView(
            exercise: $viewModel.localExercise,
            index: viewModel.index,
            weightUnit: viewModel.weightUnit,
            distanceUnit: viewModel.distanceUnit,
            onAddSet: viewModel.onAddSet,
            onDeleteSet: viewModel.onDeleteSet,
            onWeightUnitChange: viewModel.onWeightUnitChange,
            onDistanceUnitChange: viewModel.onDistanceUnitChange
        )
        .onChange(of: viewModel.localExercise) { _, newValue in
            viewModel.onExerciseUpdate(newValue)
        }
        .onAppear {
            viewModel.localExercise = viewModel.exercise
        }
    }
}

#Preview {
    List {
        EditableExerciseCardWrapper(
            viewModel: EditableExerciseCardWrapperViewModel(
                interactor: CoreInteractor(container: DevPreview.shared.container),
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
