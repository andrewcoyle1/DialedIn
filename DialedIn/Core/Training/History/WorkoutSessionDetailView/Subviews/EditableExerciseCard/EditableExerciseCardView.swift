//
//  EditableExerciseCardView.swift
//  DialedIn
//
//  Created by AI Assistant
//

import SwiftUI

struct EditableExerciseCardView: View {
    @Binding var exercise: WorkoutExerciseModel
    let index: Int
    let weightUnit: ExerciseWeightUnit
    let distanceUnit: ExerciseDistanceUnit
    let onAddSet: () -> Void
    let onDeleteSet: (String) -> Void
    let onWeightUnitChange: (ExerciseWeightUnit) -> Void
    let onDistanceUnitChange: (ExerciseDistanceUnit) -> Void
    
    @State private var notesDraft: String
    
    init(
        exercise: Binding<WorkoutExerciseModel>,
        index: Int,
        weightUnit: ExerciseWeightUnit,
        distanceUnit: ExerciseDistanceUnit,
        onAddSet: @escaping () -> Void,
        onDeleteSet: @escaping (String) -> Void,
        onWeightUnitChange: @escaping (ExerciseWeightUnit) -> Void,
        onDistanceUnitChange: @escaping (ExerciseDistanceUnit) -> Void
    ) {
        self._exercise = exercise
        self.index = index
        self.weightUnit = weightUnit
        self.distanceUnit = distanceUnit
        self.onAddSet = onAddSet
        self.onDeleteSet = onDeleteSet
        self.onWeightUnitChange = onWeightUnitChange
        self.onDistanceUnitChange = onDistanceUnitChange
        self._notesDraft = State(initialValue: exercise.wrappedValue.notes ?? "")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise header
            HStack {
                Text("\(index). \(exercise.name)")
                    .font(.headline)
                
                Spacer()
                
                // Unit preference menu
                unitPreferenceMenu
                
                Text("\(exercise.sets.count) sets")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Notes editor
            ZStack(alignment: .topLeading) {
                if notesDraft.isEmpty {
                    Text("Add notes here...")
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                        .padding(.leading, 6)
                }
                TextEditor(text: $notesDraft)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 60)
                    .textInputAutocapitalization(.sentences)
                    .onChange(of: notesDraft) { _, newValue in
                        exercise.notes = newValue.isEmpty ? nil : newValue
                    }
            }
            .padding(8)
            .background(.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            // Sets
            VStack(spacing: 8) {
                ForEach($exercise.sets) { $set in
                    EditableSetDetailRow(
                        set: $set,
                        trackingMode: exercise.trackingMode,
                        weightUnit: weightUnit,
                        distanceUnit: distanceUnit
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            onDeleteSet(set.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            
            // Add set button
            Button {
                onAddSet()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Set")
                }
                .font(.subheadline)
                .foregroundStyle(.blue)
            }
        }
    }
    
    @ViewBuilder
    private var unitPreferenceMenu: some View {
        Menu {
            if exercise.trackingMode == .weightReps {
                Menu {
                    ForEach(ExerciseWeightUnit.allCases, id: \.self) { unit in
                        Button {
                            onWeightUnitChange(unit)
                        } label: {
                            HStack {
                                Text(unit.displayName)
                                if unit == weightUnit {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Label("Weight Unit", systemImage: "scalemass")
                }
            }
            
            if exercise.trackingMode == .distanceTime {
                Menu {
                    ForEach(ExerciseDistanceUnit.allCases, id: \.self) { unit in
                        Button {
                            onDistanceUnitChange(unit)
                        } label: {
                            HStack {
                                Text(unit.displayName)
                                if unit == distanceUnit {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Label("Distance Unit", systemImage: "ruler")
                }
            }
        } label: {
            Image(systemName: "gearshape")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    List {
        EditableExerciseCardView(
            exercise: .constant(WorkoutExerciseModel.mock),
            index: 1,
            weightUnit: .kilograms,
            distanceUnit: .meters,
            onAddSet: {},
            onDeleteSet: { _ in },
            onWeightUnitChange: { _ in },
            onDistanceUnitChange: { _ in }
        )
    }
}
