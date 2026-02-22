//
//  WorkoutTrackerView+SetUI.swift
//  DialedIn
//
//  Extracted for function_body_length.
//

import SwiftUI

// MARK: - Set UI Helpers
extension WorkoutTrackerView {
    
    @ViewBuilder
    func setsContent(_ exercise: WorkoutExerciseModel) -> some View {
        Group {
            equipmentButton(exercise)
            setsList(exercise)
            addSetButton(exercise)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(.vertical, 0)
        .listRowInsets(.leading, 0)
        .listSectionMargins(.top, 0)
    }
    
    @ViewBuilder
    private func equipmentButton(_ exercise: WorkoutExerciseModel) -> some View {
        ScrollView(.horizontal) {
            HStack {
                Button {
                    presenter.onExerciseEquipmentPressed(exercise)
                } label: {
                    Label("Equipment", systemImage: "scalemass")
                        .padding(4)
                        .padding(.horizontal, 4)
                        .background(Color.secondary.opacity(0.3), in: .capsule)
                }
            }
        }
    }
    
    @ViewBuilder
    private func setsList(_ exercise: WorkoutExerciseModel) -> some View {
        ForEach(exercise.sets) { set in
            setRow(exercise: exercise, set: set)
        }
    }
    
    @ViewBuilder
    private func setRow(exercise: WorkoutExerciseModel, set: WorkoutSetModel) -> some View {
        VStack {
            HStack {
                setNumber(exercise: exercise, set: set)
                Spacer()
                previousValues(exercise: exercise, set: set)
                Spacer()
                inputFields(exercise: exercise, set: set)
                Spacer()
                completeButton(exercise: exercise, set: set)
            }
            .frame(maxWidth: .infinity)
            
            restSelector(exercise: exercise, set: set)
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                presenter.deleteSet(setId: set.id, exerciseId: exercise.id)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                
            } label: {
                Label("Rest Timer", systemImage: "timer")
            }
        }
        .moveDisabled(true)
    }
    
    @ViewBuilder
    private func addSetButton(_ exercise: WorkoutExerciseModel) -> some View {
        Button {
            presenter.addSet(exerciseId: exercise.id)
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add Set")
            }
            .font(.footnote.bold())
            .foregroundColor(.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.accent.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .listRowSeparator(.hidden)
        .listRowInsets(.vertical, 0)
        .listRowInsets(.leading, 0)
    }
}
