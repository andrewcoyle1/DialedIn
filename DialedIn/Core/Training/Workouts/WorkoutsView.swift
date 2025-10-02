//
//  WorkoutsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

struct WorkoutsView: View {

    @Environment(UserManager.self) private var userManager
    @Environment(ExerciseTemplateManager.self) private var exerciseTemplateManager
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager

    @State private var searchWorkoutTask: Task<Void, Never>?
    @State private var isLoading: Bool = false
    @State private var searchText: String = ""
    @State private var showAlert: AnyAppAlert?

    @State private var myWorkouts: [WorkoutTemplateModel] = []
    @State private var favouriteWorkouts: [WorkoutTemplateModel] = []
    @State private var bookmarkedWorkouts: [WorkoutTemplateModel] = []
    @State private var workouts: [WorkoutTemplateModel] = []
    @State private var showAddWorkoutModal: Bool = false

    @Binding var isShowingInspector: Bool
    @Binding var selectedWorkoutTemplate: WorkoutTemplateModel?
    @Binding var selectedExerciseTemplate: ExerciseTemplateModel?

    var body: some View {
        Group {
            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

                if !favouriteWorkouts.isEmpty {
                    favouriteWorkoutTemplatesSection
                }

                myWorkoutSection

                if !bookmarkedOnlyWorkouts.isEmpty {
                    bookmarkedWorkoutTemplatesSection
                }

                if !trendingWorkoutsDeduped.isEmpty {
                    workoutTemplateSection
                }
            } else {
                // Show search results when there is a query
                workoutTemplateSection
            }
        }
        .sheet(isPresented: $showAddWorkoutModal) {
            CreateWorkoutView()
        }
        .task {
            await loadMyWorkoutsIfNeeded()
            await loadTopWorkoutsIfNeeded()
            await syncSavedWorkoutsFromUser()
        }
        .onChange(of: userManager.currentUser) {
            Task {
                await syncSavedWorkoutsFromUser()
            }
        }
    }

    private var myWorkoutIds: Set<String> {
        Set(myWorkouts.map { $0.id })
    }

    private var favouriteWorkoutIds: Set<String> {
        Set(favouriteWorkouts.map { $0.id })
    }

    private var myWorkoutsVisible: [WorkoutTemplateModel] {
        myWorkouts.filter { !favouriteWorkoutIds.contains($0.id) }
    }

    private var bookmarkedOnlyWorkouts: [WorkoutTemplateModel] {
        bookmarkedWorkouts.filter { !favouriteWorkoutIds.contains($0.id) && !myWorkoutIds.contains($0.id) }
    }

    private var savedWorkoutIds: Set<String> {
        favouriteWorkoutIds.union(Set(bookmarkedOnlyWorkouts.map { $0.id }))
    }

    private var trendingWorkoutsDeduped: [WorkoutTemplateModel] {
        workouts.filter { !myWorkoutIds.contains($0.id) && !savedWorkoutIds.contains($0.id) }
    }

    private var visibleWorkoutTemplates: [WorkoutTemplateModel] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? trendingWorkoutsDeduped : workouts
    }

    private var favouriteWorkoutTemplatesSection: some View {
        Section {
            ForEach(favouriteWorkouts) { workout in
                CustomListCellView(
                    imageName: workout.imageURL,
                    title: workout.name,
                    subtitle: workout.description
                )
                .anyButton(.highlight) {
                    onWorkoutPressed(workout: workout)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Favourites")
        }
    }

    private var bookmarkedWorkoutTemplatesSection: some View {
        Section {
            ForEach(bookmarkedOnlyWorkouts) { workout in
                CustomListCellView(
                    imageName: workout.imageURL,
                    title: workout.name,
                    subtitle: workout.description
                )
                .anyButton(.highlight) {
                    onWorkoutPressed(workout: workout)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Bookmarked")
        }
    }

    private var workoutTemplateSection: some View {
        Section {
            if isLoading {
                HStack {
                    ProgressView()
                    Text("Loading...")
                }
                .foregroundStyle(Color.secondary)
                .removeListRowFormatting()
            }
            ForEach(visibleWorkoutTemplates) { workout in
                CustomListCellView(
                    imageName: workout.imageURL,
                    title: workout.name,
                    subtitle: workout.description
                )
                .anyButton(.highlight) {
                    onWorkoutPressed(workout: workout)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Trending Templates" : "Search Results")
        }
    }

    private var myWorkoutSection: some View {
        Section {
            if myWorkoutsVisible.isEmpty {
                HStack {
                    Image(systemName: "tray")
                        .foregroundColor(.secondary)
                    Text("No workout templates yet. Tap + to create your first one!")
                        .foregroundColor(.secondary)
                        .font(.callout)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 12)
                .removeListRowFormatting()
            } else {
                ForEach(myWorkoutsVisible) { workout in
                    CustomListCellView(
                        imageName: workout.imageURL,
                        title: workout.name,
                        subtitle: workout.description
                    )
                    .anyButton(.highlight) {
                        onWorkoutPressed(workout: workout)
                    }
                    .removeListRowFormatting()
                }
            }
        } header: {
            HStack {
                Text("My Templates")
                Spacer()
                Button {
                    showAddWorkoutModal = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                }
            }
        }
    }

    private func onWorkoutPressed(workout: WorkoutTemplateModel) {
        selectedExerciseTemplate = nil
        selectedWorkoutTemplate = workout
        isShowingInspector = true
    }

    private func performWorkoutSearch(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        searchWorkoutTask?.cancel()
        guard !trimmed.isEmpty else {
            // When clearing search, show top templates
            Task { await loadTopWorkoutsIfNeeded() }
            isLoading = false
            return
        }
        isLoading = true
        let currentQuery = trimmed
        searchWorkoutTask = Task { [workoutTemplateManager] in
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            do {
                let results = try await workoutTemplateManager.getWorkoutTemplatesByName(name: currentQuery)
                await MainActor.run {
                    workouts = results
                    isLoading = false
                }
            } catch {
                showAlert = AnyAppAlert(
                    title: "No Workouts Found",
                    subtitle: "We couldn't find any workout templates matching your search. Please try a different name or check your connection."
                )
                await MainActor.run {
                    isLoading = false
                    workouts = []
                }
            }
        }
    }

    private func loadMyWorkoutsIfNeeded() async {
        guard let userId = userManager.currentUser?.userId else { return }
        do {
            let mine = try await workoutTemplateManager.getWorkoutTemplatesForAuthor(authorId: userId)
            myWorkouts = mine
        } catch {
            // TODO: Route to log manager once available here
            showAlert = AnyAppAlert(
                title: "Unable to Load Your Workouts",
                subtitle: "We couldn't retrieve your custom workout templates. Please check your connection or try again later."
            )
        }
    }

    private func loadTopWorkoutsIfNeeded() async {
        guard searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isLoading = true
        do {
            let top = try await workoutTemplateManager.getTopWorkoutTemplatesByClicks(limitTo: 10)
            workouts = top
            isLoading = false
        } catch {
            isLoading = false
            // TODO: Route to log manager once available here
            showAlert = AnyAppAlert(
                title: "Unable to Load Trending Templates",
                subtitle: "We couldn't load top workout templates. Please try again later."
            )
        }
    }

    private func syncSavedWorkoutsFromUser() async {
        guard let user = userManager.currentUser else {
            favouriteWorkouts = []
            bookmarkedWorkouts = []
            return
        }
        let bookmarkedIds = user.bookmarkedWorkoutTemplateIds ?? []
        let favouritedIds = user.favouritedWorkoutTemplateIds ?? []
        if bookmarkedIds.isEmpty && favouritedIds.isEmpty {
            favouriteWorkouts = []
            bookmarkedWorkouts = []
            return
        }
        do {
            var favs: [WorkoutTemplateModel] = []
            var bookmarks: [WorkoutTemplateModel] = []
            if !favouritedIds.isEmpty {
                favs = try await workoutTemplateManager.getWorkoutTemplates(ids: favouritedIds, limitTo: favouritedIds.count)
            }
            if !bookmarkedIds.isEmpty {
                bookmarks = try await workoutTemplateManager.getWorkoutTemplates(ids: bookmarkedIds, limitTo: bookmarkedIds.count)
            }
            favouriteWorkouts = favs
            bookmarkedWorkouts = bookmarks
        } catch {
            showAlert = AnyAppAlert(
                title: "Unable to Load Saved Workouts",
                subtitle: "We couldn't retrieve your saved workout templates. Please try again later."
            )
        }
    }
}

#Preview {
    List {
        WorkoutsView(
            isShowingInspector: Binding.constant(true),
            selectedWorkoutTemplate: Binding.constant(nil),
            selectedExerciseTemplate: Binding.constant(nil)
        )
    }
    .previewEnvironment()
}
