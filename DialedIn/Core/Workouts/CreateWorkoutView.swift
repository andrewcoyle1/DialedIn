//
//  CreateWorkoutView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

struct CreateWorkoutView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var workoutName: String = ""
    @State private var workoutTemplateNotes: String = ""
    @State var exercises: [ExerciseTemplateModel] = ExerciseTemplateModel.mocks

    @State private var showAddExerciseModal: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                nameSection
                notesSection
                exerciseTemplatesSection
            }
            .navigationTitle("Create Workout")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        cancel()
                    } label: {
                    Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        createWorkout()
                    } label: {
                    Image(systemName: "checkmark")
                    }
                    .buttonStyle(.glassProminent)
                }
            }
            .sheet(isPresented: $showAddExerciseModal) {
                AddExerciseModal(selectedExercises: $exercises)
            }
        }
    }
    
    private var nameSection: some View {
        Section {
            TextField("Enter workout name", text: $workoutName)
        } header: {
            Text("Workout name")
        }
    }
    
    private var notesSection: some View {
        Section {
            TextField("Enter workout template notes.", text: $workoutTemplateNotes)
        } header: {
            Text("Notes")
        }
    }
    
    private var exerciseTemplatesSection: some View {
        Section {
            if !exercises.isEmpty {
                ForEach(exercises) {exercise in
                    CustomListCellView(imageName: exercise.imageURL, title: exercise.name, subtitle: exercise.description)
                        .removeListRowFormatting()
                }
            } else {
                Text("No exercise templates added yet.")
                    .foregroundStyle(.secondary)
            }
            Button {
                
            } label: {
                Text("Add exercise template")
            }
        } header: {
            HStack {
                Text("Exercise templates")
                Spacer()
                Button {
                    onAddExercisePressed()
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
    }
    
    private func cancel() {
        dismiss()
    }
    
    private func createWorkout() {
        _ = WorkoutTemplateModel(
            id: UUID().uuidString,
            authorId: UUID().uuidString,
            name: workoutName,
            notes: workoutTemplateNotes != "" ? workoutTemplateNotes : nil,
            dateCreated: Date(),
            dateModified: nil,
            exercises: []
        )
        // TODO: Add save workout logic here
        dismiss()
    }
    
    private func onAddExercisePressed() {
        showAddExerciseModal = true
    }
}

#Preview("With Exercises") {
    @Previewable @State var showingSheet: Bool = true
    Button("Show Sheet") {
        showingSheet = true
    }
        .sheet(isPresented: $showingSheet) {
            CreateWorkoutView()
        }
}

#Preview("Without Exercises") {
    @Previewable @State var showingSheet: Bool = true
    Button("Show Sheet") {
        showingSheet = true
    }
        .sheet(isPresented: $showingSheet) {
            CreateWorkoutView(exercises: [])
        }
}
