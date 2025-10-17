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
        
        // Always load system exercises from local storage
        let systemExercises = (try? exerciseTemplateManager.getSystemExerciseTemplates()) ?? []
        
        do {
            // Load top exercises from remote
            let trendingExercises = try await exerciseTemplateManager.getTopExerciseTemplatesByClicks(limitTo: 50)
            
            // Combine system exercises and trending exercises
            // System exercises first, then trending (deduplicated)
            let systemIds = Set(systemExercises.map { $0.id })
            let uniqueTrending = trendingExercises.filter { !systemIds.contains($0.id) }
            
            await MainActor.run {
                exercises = systemExercises + uniqueTrending
                isLoading = false
            }
        } catch {
            // Fallback to all local exercises if remote fails
            do {
                let localExercises = try exerciseTemplateManager.getAllLocalExerciseTemplates()
                await MainActor.run {
                    exercises = localExercises
                    isLoading = false
                }
            } catch {
                // At minimum, show system exercises even if everything else fails
                await MainActor.run {
                    exercises = systemExercises
                    isLoading = false
                    if systemExercises.isEmpty {
                        errorMessage = "Failed to load exercises. Please check your connection and try again."
                    }
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
        
        // Always include system exercises in search
        let systemExercises = (try? exerciseTemplateManager.getSystemExerciseTemplates()) ?? []
        
        do {
            // Search remote exercises
            let remoteResults = try await exerciseTemplateManager.getExerciseTemplatesByName(name: query)
            
            // Combine system exercises and remote results (deduplicated)
            let systemIds = Set(systemExercises.map { $0.id })
            let uniqueRemote = remoteResults.filter { !systemIds.contains($0.id) }
            
            await MainActor.run {
                exercises = systemExercises + uniqueRemote
            }
        } catch {
            // If remote search fails, just show system exercises
            await MainActor.run {
                exercises = systemExercises
            }
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
