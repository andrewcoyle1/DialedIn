//
//  ExerciseView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI

struct ExerciseView: View {
    
    @Environment(ExerciseTemplateManager.self) private var exerciseTemplateManager
    @Environment(UserManager.self) private var userManager
    
    @State private var myExercises: [ExerciseTemplateModel] = []
    @State private var localExercises: [ExerciseTemplateModel] = []
    @State private var exercises: [ExerciseTemplateModel] = []
    
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var searchTask: Task<Void, Never>?
    
    @State private var showAddExerciseModal: Bool = false
    
    @State private var showAlert: AnyAppAlert?
    
    @State private var path: [NavigationPathOption] = []
    @State private var searchText: String = ""
    
    private var shouldUseSplitView: Bool {
            #if os(macOS)
            return true
            #elseif targetEnvironment(macCatalyst)
            return true
            #else
            return UIDevice.current.userInterfaceIdiom == .pad
            #endif
    }
    
    @State private var isPresented: Bool = false
    
    // MARK: - De-duplication helpers
    private var myExerciseIds: Set<String> {
        Set(myExercises.map { $0.id })
    }
    private var savedExercisesDeduped: [ExerciseTemplateModel] {
        localExercises.filter { !myExerciseIds.contains($0.id) }
    }
    private var savedExerciseIds: Set<String> {
        Set(savedExercisesDeduped.map { $0.id })
    }
    private var trendingExercisesDeduped: [ExerciseTemplateModel] {
        exercises.filter { !myExerciseIds.contains($0.id) && !savedExerciseIds.contains($0.id) }
    }
    private var visibleExerciseTemplates: [ExerciseTemplateModel] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? trendingExercisesDeduped : exercises
    }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    if !myExercises.isEmpty {
                        myExerciseSection
                    }
                    if !savedExercisesDeduped.isEmpty {
                        savedExerciseTemplatesSection
                    }
                    
                    if !trendingExercisesDeduped.isEmpty {
                        exerciseTemplateSection
                    }
                } else {
                    // Show search results when there is a query
                    exerciseTemplateSection
                }
            }
            .scrollIndicators(.hidden)
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onAddExercisePressed()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.glassProminent)
                }
            }
            .showCustomAlert(alert: $showAlert)
            .navigationDestinationForCoreModule(path: $path)
            .onChange(of: searchText) { _, newValue in
                performSearch(for: newValue)
            }
            .task {
                await loadMyExercisesIfNeeded()
                await loadTopExercisesIfNeeded()
            }
            .onAppear {
                loadLocalExerciseTemplates()
            }
        }
        .sheet(isPresented: $showAddExerciseModal) {
            CreateExerciseView()
        }
        
        
    }
    
    private var savedExerciseTemplatesSection: some View {
        Section {
            ForEach(savedExercisesDeduped) { exercise in
                CustomListCellView(
                    imageName: exercise.imageURL,
                    title: exercise.name,
                    subtitle: exercise.description
                )
                .anyButton(.highlight) {
                    onExercisePressed(exercise: exercise)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Saved Exercises")
        }
    }
    
    private var exerciseTemplateSection: some View {
        Section {
            if isLoading {
                HStack {
                    ProgressView()
                    Text("Loading...")
                }
                .foregroundStyle(Color.secondary)
                .removeListRowFormatting()
            }
            ForEach(visibleExerciseTemplates) { exercise in
                CustomListCellView(
                    imageName: exercise.imageURL,
                    title: exercise.name,
                    subtitle: exercise.description
                )
                .anyButton(.highlight) {
                    onExercisePressed(exercise: exercise)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Trending Templates" : "Search Results")
        }
    }
    
    private var myExerciseSection: some View {
        Section {
            ForEach(myExercises) { exercise in
                CustomListCellView(
                    imageName: exercise.imageURL,
                    title: exercise.name,
                    subtitle: exercise.description
                )
                .anyButton(.highlight) {
                    onExercisePressed(exercise: exercise)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("My Templates")
        }
    }
    private func onExercisePressed(exercise: ExerciseTemplateModel) {
        Task {
            try? await exerciseTemplateManager.incrementExerciseTemplateInteraction(id: exercise.id)
        }
        path.append(.exerciseTemplate(exerciseTemplate: exercise))
    }
    
    private func onAddExercisePressed() {
        showAddExerciseModal = true
    }

    private func loadLocalExerciseTemplates() {
        do {
            localExercises = try exerciseTemplateManager.getAllLocalExerciseTemplates()
        } catch {
            showAlert = AnyAppAlert(
                title: "Unable to Load Local Exercises",
                subtitle: "There was a problem accessing your locally saved exercise templates. Please try again or check your device storage settings."
            )
        }
    }
    
    private func performSearch(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        searchTask?.cancel()
        guard !trimmed.isEmpty else {
            // When clearing search, show top templates
            Task { await loadTopExercisesIfNeeded() }
            isLoading = false
            errorMessage = nil
            return
        }
        isLoading = true
        errorMessage = nil
        let currentQuery = trimmed
        searchTask = Task { [exerciseTemplateManager] in
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            do {
                let results = try await exerciseTemplateManager.getExerciseTemplatesByName(name: currentQuery)
                await MainActor.run {
                    exercises = results
                    isLoading = false
                }
            } catch {
                showAlert = AnyAppAlert(
                    title: "No Exercises Found",
                    subtitle: "We couldn't find any exercise templates matching your search. Please try a different name or check your connection."
                )
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    exercises = []
                }
            }
        }
    }
    
    private func loadMyExercisesIfNeeded() async {
        guard let userId = userManager.currentUser?.userId else { return }
        do {
            let mine = try await exerciseTemplateManager.getExerciseTemplatesForAuthor(authorId: userId)
            myExercises = mine
        } catch {
            // TODO: Route to log manager once available here
            showAlert = AnyAppAlert(
                title: "Unable to Load Your Exercises",
                subtitle: "We couldn't retrieve your custom exercise templates. Please check your connection or try again later."
            )
        }
    }
    
    private func loadTopExercisesIfNeeded() async {
        guard searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isLoading = true
        do {
            let top = try await exerciseTemplateManager.getTopExerciseTemplatesByClicks(limitTo: 10)
            exercises = top
            isLoading = false
        } catch {
            isLoading = false
            // TODO: Route to log manager once available here
            showAlert = AnyAppAlert(
                title: "Unable to Load Trending Templates",
                subtitle: "We couldn't load top exercise templates. Please try again later."
            )
        }
    }
}

#Preview("With local templates") {
    ExerciseView()
        .environment(
            ExerciseTemplateManager(
                services: MockExerciseTemplateServices()
            )
        )
        .previewEnvironment()
}

#Preview("Without local templates") {
    ExerciseView()
        .environment(
            ExerciseTemplateManager(services: MockExerciseTemplateServices(exercises: [])
            )
        )
        .previewEnvironment()
}

#Preview("Slow Loading State") {
    ExerciseView()
        .environment(
            ExerciseTemplateManager(
                services: MockExerciseTemplateServices(delay: 3)
            )
        )
        .previewEnvironment()
}

#Preview("Error State") {
    ExerciseView()
        .environment(
            ExerciseTemplateManager(
                services: MockExerciseTemplateServices(showError: true)
            )
        )
        .previewEnvironment()
}
