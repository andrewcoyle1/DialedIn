//
//  AddExerciseModal.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

struct AddExerciseModal: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ExerciseTemplateManager.self) private var exerciseTemplateManager
    @Environment(LogManager.self) private var logManager
    
    @State private var exercises: [ExerciseTemplateModel] = []
    @State private var searchText: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
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
            Group {
                if isLoading {
                    VStack {
                        ProgressView()
                        Text("Loading exercises...")
                            .foregroundStyle(.secondary)
                    }
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.orange)
                        Text("Error Loading Exercises")
                            .font(.headline)
                        Text(errorMessage)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            Task {
                                await loadExercises()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
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
                }
            }
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
            .task {
                await loadExercises()
            }
            .onChange(of: searchText) {
                Task {
                    await searchExercises()
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
    
    private func loadExercises() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            // Load top exercises when not searching
            let loadedExercises = try await exerciseTemplateManager.getTopExerciseTemplatesByClicks(limitTo: 50)
            await MainActor.run {
                exercises = loadedExercises
                isLoading = false
            }
        } catch {
            // Fallback to local exercises if remote fails
            do {
                let localExercises = try exerciseTemplateManager.getAllLocalExerciseTemplates()
                await MainActor.run {
                    exercises = localExercises
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to load exercises. Please check your connection and try again."
                }
            }
        }
    }
    
    private func searchExercises() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If search is empty, reload top exercises
        guard !query.isEmpty else {
            await loadExercises()
            return
        }
        
        // Don't search for very short queries to avoid too many API calls
        guard query.count >= 2 else { return }
        
        do {
            let searchResults = try await exerciseTemplateManager.getExerciseTemplatesByName(name: query)
            await MainActor.run {
                exercises = searchResults
            }
        } catch {
            // Don't show error for search failures, just keep current results
        }
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
    .previewEnvironment()
}
