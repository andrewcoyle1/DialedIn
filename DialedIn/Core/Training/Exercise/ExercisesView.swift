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
    @Environment(LogManager.self) private var logManager

    @State private var isLoading: Bool = false
    @State private var searchText: String = ""
    @State private var showAlert: AnyAppAlert?

    @State private var searchExerciseTask: Task<Void, Never>?
    @State private var myExercises: [ExerciseTemplateModel] = []
    @State private var favouriteExercises: [ExerciseTemplateModel] = []
    @State private var bookmarkedExercises: [ExerciseTemplateModel] = []
    @State private var officialExercises: [ExerciseTemplateModel] = []
    @State private var exercises: [ExerciseTemplateModel] = []

    @Binding var isShowingInspector: Bool
    @Binding var selectedWorkoutTemplate: WorkoutTemplateModel?
    @Binding var selectedExerciseTemplate: ExerciseTemplateModel?
    @Binding var showCreateExercise: Bool

    // MARK: Computed Variables

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
    
    private var officialExerciseIds: Set<String> {
        Set(officialExercises.map { $0.id })
    }

    private var savedExerciseIds: Set<String> {
        favouriteExerciseIds.union(Set(bookmarkedOnlyExercises.map { $0.id }))
    }
    
    private var officialExercisesVisible: [ExerciseTemplateModel] {
        officialExercises.filter { !favouriteExerciseIds.contains($0.id) && !myExerciseIds.contains($0.id) && !savedExerciseIds.contains($0.id) }
    }

    private var trendingExercisesDeduped: [ExerciseTemplateModel] {
        exercises.filter { !myExerciseIds.contains($0.id) && !savedExerciseIds.contains($0.id) && !officialExerciseIds.contains($0.id) }
    }

    private var visibleExerciseTemplates: [ExerciseTemplateModel] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? trendingExercisesDeduped : exercises
    }

    var body: some View {
        Group {
            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

                if !favouriteExercises.isEmpty {
                    favouriteExerciseTemplatesSection
                }

                myExercisesSection
                
                if !officialExercisesVisible.isEmpty {
                    officialExercisesSection
                }

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
        .screenAppearAnalytics(name: "ExercisesView")
        .task {
            await loadMyExercisesIfNeeded()
            await loadOfficialExercises()
            await loadTopExercisesIfNeeded()
            await syncSavedExercisesFromUser()
        }
        .onChange(of: userManager.currentUser) {
            Task {
                await syncSavedExercisesFromUser()
            }
        }
    }

    // MARK: UI Components
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
        .onAppear {
            logManager.trackEvent(event: ExercisesViewEvents.favouritesSectionViewed(count: favouriteExercises.count))
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
        .onAppear {
            logManager.trackEvent(event: ExercisesViewEvents.bookmarkedSectionViewed(count: bookmarkedOnlyExercises.count))
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
                HStack(spacing: 8) {
                    ZStack {
                        if let imageName = exercise.imageURL {
                            if imageName.starts(with: "http://") || imageName.starts(with: "https://") {
                                ImageLoaderView(urlString: imageName, resizingMode: .fit)
                            } else {
                                // Treat as bundled asset name
                                Image(imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        } else {
                            Rectangle()
                                .fill(.secondary.opacity(0.5))
                        }
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .frame(height: 60)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name)
                            .font(.headline)
                        if let subtitle = exercise.description {
                            Text(subtitle)
                                .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(12)
                .padding(.vertical, 4)
                .background(Color(uiColor: .systemBackground))
                .anyButton(.highlight) {
                    onExercisePressed(exercise: exercise)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Trending Templates" : "Search Results")
        }
        .onAppear {
            logManager.trackEvent(event: ExercisesViewEvents.trendingSectionViewed(count: visibleExerciseTemplates.count))
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
                .onAppear {
                    logManager.trackEvent(event: ExercisesViewEvents.emptyStateShown)
                }
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
                    showCreateExercise = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                }
            }
        }
        .onAppear {
            logManager.trackEvent(event: ExercisesViewEvents.myTemplatesSectionViewed(count: myExercisesVisible.count))
        }
    }
    
    private var officialExercisesSection: some View {
        Section {
            ForEach(officialExercisesVisible) { exercise in
                HStack(spacing: 8) {
                    ZStack {
                        if let imageName = exercise.imageURL {
                            if imageName.starts(with: "http://") || imageName.starts(with: "https://") {
                                ImageLoaderView(urlString: imageName, resizingMode: .fit)
                            } else {
                                // Treat as bundled asset name
                                Image(imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        } else {
                            Rectangle()
                                .fill(.secondary.opacity(0.5))
                        }
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 60, height: 60)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name)
                            .font(.headline)
                        if let subtitle = exercise.description {
                            Text(subtitle)
                                .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(12)
                .padding(.vertical, 4)
                .background(Color(uiColor: .systemBackground))
//                CustomListCellView(
//                    imageName: exercise.imageURL,
//                    title: exercise.name,
//                    subtitle: exercise.description
//                )
                .anyButton(.highlight) {
                    onExercisePressed(exercise: exercise)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Official Exercises")
        }
        .onAppear {
            logManager.trackEvent(event: ExercisesViewEvents.officialSectionViewed(count: officialExercisesVisible.count))
        }
    }

    // MARK: Business Logic

    private func onAddExercisePressed() {
        logManager.trackEvent(event: ExercisesViewEvents.onAddExercisePressed)
        showCreateExercise = true
    }

    private func onExercisePressed(exercise: ExerciseTemplateModel) {
        // Only increment click count for non-system exercises
        // System exercises (IDs starting with "system-") are read-only
        if !exercise.id.hasPrefix("system-") {
            Task {
                logManager.trackEvent(event: ExercisesViewEvents.incrementExerciseStart)
                do {
                    try await exerciseTemplateManager.incrementExerciseTemplateInteraction(id: exercise.id)
                    logManager.trackEvent(event: ExercisesViewEvents.incrementExerciseSuccess)
                } catch {
                    logManager.trackEvent(event: ExercisesViewEvents.incrementExerciseFail(error: error))
                }
            }
        }
        selectedWorkoutTemplate = nil
        selectedExerciseTemplate = exercise
        isShowingInspector = true
    }

    private func onExercisePressedFromFavourites(exercise: ExerciseTemplateModel) {
        logManager.trackEvent(event: ExercisesViewEvents.onExercisePressedFromFavourites)
        onExercisePressed(exercise: exercise)
    }

    private func onExercisePressedFromBookmarked(exercise: ExerciseTemplateModel) {
        logManager.trackEvent(event: ExercisesViewEvents.onExercisePressedFromBookmarked)
        onExercisePressed(exercise: exercise)
    }

    private func onExercisePressedFromTrending(exercise: ExerciseTemplateModel) {
        logManager.trackEvent(event: ExercisesViewEvents.onExercisePressedFromTrending)
        onExercisePressed(exercise: exercise)
    }

    private func onExercisePressedFromMyTemplates(exercise: ExerciseTemplateModel) {
        logManager.trackEvent(event: ExercisesViewEvents.onExercisePressedFromMyTemplates)
        onExercisePressed(exercise: exercise)
    }

    private func performExerciseSearch(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        // Cancel any ongoing search
        searchExerciseTask?.cancel()

        guard !trimmed.isEmpty else {
            handleSearchCleared()
            return
        }

        startFreshSearch(for: trimmed)
    }

    private func handleSearchCleared() {
        logManager.trackEvent(event: ExercisesViewEvents.searchCleared)
        Task { await loadTopExercisesIfNeeded() }
    }

    private func startFreshSearch(for query: String) {
        isLoading = true
        logManager.trackEvent(event: ExercisesViewEvents.performExerciseSearchStart)

        searchExerciseTask = Task { [exerciseTemplateManager] in
            do {
                // Debounce the search
                try? await Task.sleep(for: .milliseconds(350))
                guard !Task.isCancelled else { return }

                // Perform the actual search
                let results = try await exerciseTemplateManager.getExerciseTemplatesByName(name: query)

                // Update UI on main thread
                await MainActor.run {
                    handleSearchResults(results, for: query)
                }

            } catch {
                await MainActor.run {
                    handleSearchError(error)
                }
            }
        }
    }

    private func handleSearchResults(_ results: [ExerciseTemplateModel], for query: String) {
        exercises = results
        isLoading = false

        if results.isEmpty {
            logManager.trackEvent(event: ExercisesViewEvents.performExerciseSearchEmptyResults(query: query))
        } else {
            logManager.trackEvent(event: ExercisesViewEvents.performExerciseSearchSuccess(query: query, resultCount: results.count))
        }
    }

    private func handleSearchError(_ error: Error) {
        logManager.trackEvent(event: ExercisesViewEvents.performExerciseSearchFail(error: error))
        isLoading = false
        exercises = []

        showAlert = AnyAppAlert(
            title: "No Exercises Found",
            subtitle: "We couldn't find any exercise templates matching your search. Please try a different name or check your connection."
        )
    }

    private func loadMyExercisesIfNeeded() async {
        guard let userId = userManager.currentUser?.userId else { return }
        logManager.trackEvent(event: ExercisesViewEvents.loadMyExercisesStart)
        do {
            let mine = try await exerciseTemplateManager.getExerciseTemplatesForAuthor(authorId: userId)
            myExercises = mine
            logManager.trackEvent(event: ExercisesViewEvents.loadMyExercisesSuccess(count: mine.count))
        } catch {
            logManager.trackEvent(event: ExercisesViewEvents.loadMyExercisesFail(error: error))
            showAlert = AnyAppAlert(
                title: "Unable to Load Your Exercises",
                subtitle: "We couldn't retrieve your custom exercise templates. Please check your connection or try again later."
            )
        }
    }
    
    private func loadOfficialExercises() async {
        logManager.trackEvent(event: ExercisesViewEvents.loadOfficialExercisesStart)
        do {
            let official = try exerciseTemplateManager.getSystemExerciseTemplates()
            officialExercises = official
            logManager.trackEvent(event: ExercisesViewEvents.loadOfficialExercisesSuccess(count: official.count))
        } catch {
            logManager.trackEvent(event: ExercisesViewEvents.loadOfficialExercisesFail(error: error))
            // Don't show alert for official exercises - it's not critical
        }
    }

    private func loadTopExercisesIfNeeded() async {
        guard searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isLoading = true
        logManager.trackEvent(event: ExercisesViewEvents.loadTopExercisesStart)
        do {
            let top = try await exerciseTemplateManager.getTopExerciseTemplatesByClicks(limitTo: 10)
            exercises = top
            isLoading = false
            logManager.trackEvent(event: ExercisesViewEvents.loadTopExercisesSuccess(count: top.count))
        } catch {
            isLoading = false
            logManager.trackEvent(event: ExercisesViewEvents.loadTopExercisesFail(error: error))
            showAlert = AnyAppAlert(
                title: "Unable to Load Trending Templates",
                subtitle: "We couldn't load top exercise templates. Please try again later."
            )
        }
    }

    private func syncSavedExercisesFromUser() async {
        logManager.trackEvent(event: ExercisesViewEvents.syncExercisesFromCurrentUserStart)
        guard let user = userManager.currentUser else {
            logManager.trackEvent(event: ExercisesViewEvents.syncExercisesFromCurrentUserNoUid)
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
            logManager.trackEvent(event: ExercisesViewEvents.syncExercisesFromCurrentUserSuccess(favouriteCount: favs.count, bookmarkedCount: bookmarks.count))
        } catch {
            logManager.trackEvent(event: ExercisesViewEvents.syncExercisesFromCurrentUserFail(error: error))
            showAlert = AnyAppAlert(
                title: "Unable to Load Saved Exercises",
                subtitle: "We couldn't retrieve your saved exercises. Please try again later."
            )
        }
    }
}

#Preview {
    List {
        ExercisesView(
            isShowingInspector: Binding.constant(true),
            selectedWorkoutTemplate: Binding.constant(nil),
            selectedExerciseTemplate: Binding.constant(nil),
            showCreateExercise: Binding.constant(false)
        )
    }
    .previewEnvironment()
}
