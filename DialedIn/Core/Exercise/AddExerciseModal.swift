//
//  AddExerciseModal.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

struct AddExerciseModal: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var exercises: [ExerciseTemplateModel] = ExerciseTemplateModel.mocks
    @State private var searchText: String = ""
    
    @Binding var selectedExercises: [ExerciseTemplateModel]
    
    private var filteredExercises: [ExerciseTemplateModel] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return exercises }
        return exercises.filter { exercise in
            var fields: [String] = [
                exercise.name,
                exercise.type.description
            ]
            if let description = exercise.description { fields.append(description) }
            fields.append(contentsOf: exercise.muscleGroups.map { $0.description })
            return fields.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredExercises) { exercise in
                    CustomListCellView(imageName: exercise.imageURL, title: exercise.name, subtitle: exercise.description, isSelected: selectedExercises.contains(where: { $0.id == exercise.id }))
                        .anyButton {
                            onExercisePressed(exercise: exercise)
                        }
                        .removeListRowFormatting()

                }
            }
            .scrollIndicators(.hidden)
            .searchable(text: $searchText)
            .navigationTitle("Add Exercises")
            .navigationSubtitle("Select one or more exercises to add")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onDismissPressed()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                
            }
        }
    }
    
    private func onExercisePressed(exercise: ExerciseTemplateModel) {
        if let index = selectedExercises.firstIndex(where: { $0.id == exercise.id }) {
            selectedExercises.remove(at: index)
        } else {
            selectedExercises.append(exercise)
        }
    }
    private func onDismissPressed() {
        dismiss()
    }
}

#Preview {
    @Previewable @State var showModal: Bool = true
    @Previewable @State var selectedExercises: [ExerciseTemplateModel] = [ExerciseTemplateModel.mock]
    Button("Show Modal") {
        showModal = true
    }
    .sheet(isPresented: $showModal) {
        AddExerciseModal(selectedExercises: $selectedExercises)
    }
}
