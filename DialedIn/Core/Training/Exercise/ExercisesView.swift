//
//  ExercisesView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI

struct ExercisesView: View {

    @Environment(UserManager.self) private var userManager
    @Environment(ExerciseTemplateManager.self) private var exerciseTemplateManager
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager

    @State private var searchExerciseTask: Task<Void, Never>?
    @State private var isLoading: Bool = false
    @State private var searchText: String = ""
    @State private var showAlert: AnyAppAlert?

    @State private var myExercises: [ExerciseTemplateModel] = []
    @State private var favouriteExercises: [ExerciseTemplateModel] = []
    @State private var bookmarkedExercises: [ExerciseTemplateModel] = []
    @State private var exercises: [ExerciseTemplateModel] = []
    @State private var showAddExerciseModal: Bool = false

    @Binding var isShowingInspector: Bool
    @Binding var selectedWorkoutTemplate: WorkoutTemplateModel?
    @Binding var selectedExerciseTemplate: ExerciseTemplateModel?

    var body: some View {
        Group {
            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

                if !favouriteExercises.isEmpty {
                    favouriteExerciseTemplatesSection
                }

                myExercisesSection

                if !bookmarkedOnlyExercises.isEmpty {
                    bookmarkedExerciseTemplatesSection
                }

                if !trendingExercisesDeduped.isEmpty {
                    exerciseTemplateSection
                }
            } else {
                // Show search results when there is a query
                exerciseTemplateSection
            }
        }
        .sheet(isPresented: $showAddExerciseModal) {
            CreateExerciseView()
        }
        .task {
            await loadMyExercisesIfNeeded()
            await loadTopExercisesIfNeeded()
            await syncSavedExercisesFromUser()
        }
        .onChange(of: userManager.currentUser) {
            Task {
                await syncSavedExercisesFromUser()
            }
        }
    }

    private var myExerciseIds: Set<String> {
        Set(myExercises.map { $0.id })
    }

    private var favouriteExerciseIds: Set<String> {
        Set(favouriteExercises.map { $0.id })
    }

    private var myExercisesVisible: [ExerciseTemplateModel] {
        myExercises.filter { !favouriteExerciseIds.contains($0.id) }
    }

    private var bookmarkedOnlyExercises: [ExerciseTemplateModel] {
        bookmarkedExercises.filter { !favouriteExerciseIds.contains($0.id) && !myExerciseIds.contains($0.id) }
    }

    private var savedExerciseIds: Set<String> {
        favouriteExerciseIds.union(Set(bookmarkedOnlyExercises.map { $0.id }))
    }

    private var trendingExercisesDeduped: [ExerciseTemplateModel] {
        exercises.filter { !myExerciseIds.contains($0.id) && !savedExerciseIds.contains($0.id) }
    }

    private var visibleExerciseTemplates: [ExerciseTemplateModel] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? trendingExercisesDeduped : exercises
    }

    private var favouriteExerciseTemplatesSection: some View {
        Section {
            ForEach(favouriteExercises) { exercise in
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
            Text("Favourites")
        }
    }

    private var bookmarkedExerciseTemplatesSection: some View {
        Section {
            ForEach(bookmarkedOnlyExercises) { exercise in
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
            Text("Bookmarked")
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

    private var myExercisesSection: some View {
        Section {
            if myExercisesVisible.isEmpty {
                HStack {
                    Image(systemName: "tray")
                        .foregroundColor(.secondary)
                    Text("No exercise templates yet. Tap + to create your first one!")
                        .foregroundColor(.secondary)
                        .font(.callout)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 12)
                .removeListRowFormatting()
            } else {
                ForEach(myExercisesVisible) { exercise in
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
            }
        } header: {
            HStack {
                Text("My Templates")
                Spacer()
                Button {
                    showAddExerciseModal = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                }
            }
        }
    }

    private func onExercisePressed(exercise: ExerciseTemplateModel) {
        Task {
            try? await exerciseTemplateManager.incrementExerciseTemplateInteraction(id: exercise.id)
        }
        selectedWorkoutTemplate = nil
        selectedExerciseTemplate = exercise
        isShowingInspector = true
    }

    private func performExerciseSearch(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        searchExerciseTask?.cancel()
        guard !trimmed.isEmpty else {
            // When clearing search, show top templates
            Task { await loadTopExercisesIfNeeded() }
            isLoading = false
            return
        }
        isLoading = true
        let currentQuery = trimmed
        searchExerciseTask = Task { [exerciseTemplateManager] in
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
                    exercises = []
                }
            }
        }
    }

    private func onAddExercisePressed() {
        showAddExerciseModal = true
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

    private func syncSavedExercisesFromUser() async {
        guard let user = userManager.currentUser else {
            favouriteExercises = []
            bookmarkedExercises = []
            return
        }
        let bookmarkedIds = user.bookmarkedExerciseTemplateIds ?? []
        let favouritedIds = user.favouritedExerciseTemplateIds ?? []
        if bookmarkedIds.isEmpty && favouritedIds.isEmpty {
            favouriteExercises = []
            bookmarkedExercises = []
            return
        }
        do {
            var favs: [ExerciseTemplateModel] = []
            var bookmarks: [ExerciseTemplateModel] = []
            if !favouritedIds.isEmpty {
                favs = try await exerciseTemplateManager.getExerciseTemplates(ids: favouritedIds, limitTo: favouritedIds.count)
            }
            if !bookmarkedIds.isEmpty {
                bookmarks = try await exerciseTemplateManager.getExerciseTemplates(ids: bookmarkedIds, limitTo: bookmarkedIds.count)
            }
            favouriteExercises = favs
            bookmarkedExercises = bookmarks
        } catch {
            showAlert = AnyAppAlert(
                title: "Unable to Load Saved Exercises",
                subtitle: "We couldn't retrieve your saved exercise templates. Please try again later."
            )
        }
    }
}

#Preview {
    List {
        ExercisesView(
            isShowingInspector: Binding.constant(true),
            selectedWorkoutTemplate: Binding.constant(nil),
            selectedExerciseTemplate: Binding.constant(nil)
        )
    }
    .previewEnvironment()
}
