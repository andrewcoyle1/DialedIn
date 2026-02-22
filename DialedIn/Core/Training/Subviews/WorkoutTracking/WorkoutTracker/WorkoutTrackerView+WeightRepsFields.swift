//
//  WorkoutTrackerView+WeightRepsFields.swift
//  DialedIn
//
//  Extracted for function_body_length.
//

import SwiftUI

// MARK: - Weight/Reps Input Fields
extension WorkoutTrackerView {
    
    func weightRepsFields(exercise: WorkoutExerciseModel, set: WorkoutSetModel) -> some View {
        let unitPreference = presenter.getUnitPreference(for: exercise.templateId)
        return HStack(spacing: 8) {
            weightField(exercise: exercise, set: set, unitPreference: unitPreference)
            repsField(exercise: exercise, set: set)
        }
    }
    
    @ViewBuilder
    private func weightField(
        exercise: WorkoutExerciseModel,
        set: WorkoutSetModel,
        unitPreference: (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit)
    ) -> some View {
        VStack(alignment: .center) {
            if set.index == 1 {
                unitMenu(exercise: exercise, unitPreference: unitPreference)
            }
            weightTextField(exercise: exercise, set: set, unitPreference: unitPreference)
        }
        .frame(width: 70)
    }
    
    @ViewBuilder
    private func unitMenu(
        exercise: WorkoutExerciseModel,
        unitPreference: (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit)
    ) -> some View {
        Menu {
            ForEach(ExerciseWeightUnit.allCases, id: \.self) { unit in
                Button {
                    presenter.promptWeightUnitChange(unit, for: exercise)
                } label: {
                    HStack {
                        Text(unit.displayName)
                        if unit == unitPreference.weightUnit {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Text(unitPreference.weightUnit.abbreviation)
                .autocapitalization(.words)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func weightTextField(
        exercise: WorkoutExerciseModel,
        set: WorkoutSetModel,
        unitPreference: (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit)
    ) -> some View {
        TextField("0", value: Binding(
            get: {
                guard let kilograms = set.weightKg else { return nil }
                return UnitConversion.convertWeight(kilograms, to: unitPreference.weightUnit)
            },
            set: { newValue in
                updateSetValue(set, in: exercise.id) { updated in
                    guard let value = newValue else {
                        updated.weightKg = nil
                        return
                    }
                    let kilos = UnitConversion.convertWeightToKg(value, from: unitPreference.weightUnit)
                    updated.weightKg = kilos
                }
            }
        ), format: .number)
        .textFieldStyle(.roundedBorder)
        .keyboardType(.decimalPad)
        .frame(height: 35)
    }
    
    @ViewBuilder
    private func repsField(exercise: WorkoutExerciseModel, set: WorkoutSetModel) -> some View {
        VStack(alignment: .leading) {
            if set.index == 1 {
                Text("Reps")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            TextField("0", value: Binding(
                get: { set.reps },
                set: { newValue in
                    updateSetValue(set, in: exercise.id) { $0.reps = newValue }
                }
            ), format: .number)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.numberPad)
            .frame(height: 35)
        }
        .frame(width: 50)
    }
}
