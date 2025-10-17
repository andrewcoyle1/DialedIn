//
//  WorkoutsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI

struct WorkoutsView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager
    @Environment(LogManager.self) private var logManager

    @State private var isLoading: Bool = false
    @State private var searchText: String = ""
    @State private var showAlert: AnyAppAlert?

    @State private var searchWorkoutTask: Task<Void, Never>?
    @State private var myWorkouts: [WorkoutTemplateModel] = []
    @State private var favouriteWorkouts: [WorkoutTemplateModel] = []
    @State private var bookmarkedWorkouts: [WorkoutTemplateModel] = []
    @State private var workouts: [WorkoutTemplateModel] = []
    @State private var showAddWorkoutModal: Bool = false

    @Binding var isShowingInspector: Bool
    @Binding var selectedWorkoutTemplate: WorkoutTemplateModel?
    @Binding var selectedExerciseTemplate: ExerciseTemplateModel?

    // MARK: Computed Variables

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

    var body: some View {
        Group {
            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

                if !favouriteWorkouts.isEmpty {
                    favouriteWorkoutTemplatesSection
                }

                myWorkoutsSection

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
        .screenAppearAnalytics(name: "WorkoutsView")
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

    // MARK: UI Components
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
        .onAppear {
            logManager.trackEvent(event: Event.favouritesSectionViewed(count: favouriteWorkouts.count))
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
        .onAppear {
            logManager.trackEvent(event: Event.bookmarkedSectionViewed(count: bookmarkedOnlyWorkouts.count))
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
        .onAppear {
            logManager.trackEvent(event: Event.trendingSectionViewed(count: visibleWorkoutTemplates.count))
        }
    }

    private var myWorkoutsSection: some View {
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
                .onAppear {
                    logManager.trackEvent(event: Event.emptyStateShown)
                }
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
        .onAppear {
            logManager.trackEvent(event: Event.myTemplatesSectionViewed(count: myWorkoutsVisible.count))
        }
    }

    // MARK: Business Logic

    private func onAddWorkoutPressed() {
        logManager.trackEvent(event: Event.onAddWorkoutPressed)
        showAddWorkoutModal = true
    }

    private func onWorkoutPressed(workout: WorkoutTemplateModel) {
        // Only increment click count for non-system workouts
        // System workouts (IDs starting with "system-") are read-only
        if !workout.id.hasPrefix("system-") {
            Task {
                logManager.trackEvent(event: Event.incrementWorkoutStart)
                do {
                    try await workoutTemplateManager.incrementWorkoutTemplateInteraction(id: workout.id)
                    logManager.trackEvent(event: Event.incrementWorkoutSuccess)
                } catch {
                    logManager.trackEvent(event: Event.incrementWorkoutFail(error: error))
                }
            }
        }
        selectedExerciseTemplate = nil
        selectedWorkoutTemplate = workout
        isShowingInspector = true
    }

    private func onWorkoutPressedFromFavourites(workout: WorkoutTemplateModel) {
        logManager.trackEvent(event: Event.onWorkoutPressedFromFavourites)
        onWorkoutPressed(workout: workout)
    }

    private func onWorkoutPressedFromBookmarked(workout: WorkoutTemplateModel) {
        logManager.trackEvent(event: Event.onWorkoutPressedFromBookmarked)
        onWorkoutPressed(workout: workout)
    }

    private func onWorkoutPressedFromTrending(workout: WorkoutTemplateModel) {
        logManager.trackEvent(event: Event.onWorkoutPressedFromTrending)
        onWorkoutPressed(workout: workout)
    }

    private func onWorkoutPressedFromMyTemplates(workout: WorkoutTemplateModel) {
        logManager.trackEvent(event: Event.onWorkoutPressedFromMyTemplates)
        onWorkoutPressed(workout: workout)
    }

    private func performWorkoutSearch(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        // Cancel any ongoing search
        searchWorkoutTask?.cancel()

        guard !trimmed.isEmpty else {
            handleSearchCleared()
            return
        }

        startFreshSearch(for: trimmed)
    }

    private func handleSearchCleared() {
        logManager.trackEvent(event: Event.searchCleared)
        Task { await loadTopWorkoutsIfNeeded() }
    }

    private func startFreshSearch(for query: String) {
        isLoading = true
        logManager.trackEvent(event: Event.performWorkoutSearchStart)

        searchWorkoutTask = Task { [workoutTemplateManager] in
            do {
                // Debounce the search
                try? await Task.sleep(for: .milliseconds(350))
                guard !Task.isCancelled else { return }

                // Perform the actual search
                let results = try await workoutTemplateManager.getWorkoutTemplatesByName(name: query)

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

    private func handleSearchResults(_ results: [WorkoutTemplateModel], for query: String) {
        workouts = results
        isLoading = false

        if results.isEmpty {
            logManager.trackEvent(event: Event.performWorkoutSearchEmptyResults(query: query))
        } else {
            logManager.trackEvent(event: Event.performWorkoutSearchSuccess(query: query, resultCount: results.count))
        }
    }

    private func handleSearchError(_ error: Error) {
        logManager.trackEvent(event: Event.performWorkoutSearchFail(error: error))
        isLoading = false
        workouts = []

        showAlert = AnyAppAlert(
            title: "No Workouts Found",
            subtitle: "We couldn't find any workout templates matching your search. Please try a different name or check your connection."
        )
    }

    private func loadMyWorkoutsIfNeeded() async {
        guard let userId = userManager.currentUser?.userId else { return }
        logManager.trackEvent(event: Event.loadMyWorkoutsStart)
        do {
            let mine = try await workoutTemplateManager.getWorkoutTemplatesForAuthor(authorId: userId)
            myWorkouts = mine
            logManager.trackEvent(event: Event.loadMyWorkoutsSuccess(count: mine.count))
        } catch {
            logManager.trackEvent(event: Event.loadMyWorkoutsFail(error: error))
            showAlert = AnyAppAlert(
                title: "Unable to Load Your Workouts",
                subtitle: "We couldn't retrieve your custom workout templates. Please check your connection or try again later."
            )
        }
    }

    private func loadTopWorkoutsIfNeeded() async {
        guard searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isLoading = true
        logManager.trackEvent(event: Event.loadTopWorkoutsStart)
        do {
            let top = try await workoutTemplateManager.getTopWorkoutTemplatesByClicks(limitTo: 10)
            workouts = top
            isLoading = false
            logManager.trackEvent(event: Event.loadTopWorkoutsSuccess(count: top.count))
        } catch {
            isLoading = false
            logManager.trackEvent(event: Event.loadTopWorkoutsFail(error: error))
            showAlert = AnyAppAlert(
                title: "Unable to Load Trending Templates",
                subtitle: "We couldn't load top workout templates. Please try again later."
            )
        }
    }

    private func syncSavedWorkoutsFromUser() async {
        logManager.trackEvent(event: Event.syncWorkoutsFromCurrentUserStart)
        guard let user = userManager.currentUser else {
            logManager.trackEvent(event: Event.syncWorkoutsFromCurrentUserNoUid)
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
            logManager.trackEvent(event: Event.syncWorkoutsFromCurrentUserSuccess(favouriteCount: favs.count, bookmarkedCount: bookmarks.count))
        } catch {
            logManager.trackEvent(event: Event.syncWorkoutsFromCurrentUserFail(error: error))
            showAlert = AnyAppAlert(
                title: "Unable to Load Saved Workouts",
                subtitle: "We couldn't retrieve your saved workouts. Please try again later."
            )
        }
    }

    // MARK: Analytics Events

    enum Event: LoggableEvent {
        case performWorkoutSearchStart
        case performWorkoutSearchSuccess(query: String, resultCount: Int)
        case performWorkoutSearchFail(error: Error)
        case performWorkoutSearchEmptyResults(query: String)
        case searchCleared
        case loadMyWorkoutsStart
        case loadMyWorkoutsSuccess(count: Int)
        case loadMyWorkoutsFail(error: Error)
        case loadTopWorkoutsStart
        case loadTopWorkoutsSuccess(count: Int)
        case loadTopWorkoutsFail(error: Error)
        case incrementWorkoutStart
        case incrementWorkoutSuccess
        case incrementWorkoutFail(error: Error)
        case syncWorkoutsFromCurrentUserStart
        case syncWorkoutsFromCurrentUserNoUid
        case syncWorkoutsFromCurrentUserSuccess(favouriteCount: Int, bookmarkedCount: Int)
        case syncWorkoutsFromCurrentUserFail(error: Error)
        case onAddWorkoutPressed
        case favouritesSectionViewed(count: Int)
        case bookmarkedSectionViewed(count: Int)
        case trendingSectionViewed(count: Int)
        case myTemplatesSectionViewed(count: Int)
        case emptyStateShown
        case onWorkoutPressedFromFavourites
        case onWorkoutPressedFromBookmarked
        case onWorkoutPressedFromTrending
        case onWorkoutPressedFromMyTemplates

        var eventName: String {
            switch self {
            case .performWorkoutSearchStart:          return "WorkoutsView_Search_Start"
            case .performWorkoutSearchSuccess:        return "WorkoutsView_Search_Success"
            case .performWorkoutSearchFail:           return "WorkoutsView_Search_Fail"
            case .performWorkoutSearchEmptyResults:   return "WorkoutsView_Search_EmptyResults"
            case .searchCleared:                         return "WorkoutsView_Search_Cleared"
            case .loadMyWorkoutsStart:                return "WorkoutsView_LoadMyWorkouts_Start"
            case .loadMyWorkoutsSuccess:              return "WorkoutsView_LoadMyWorkouts_Success"
            case .loadMyWorkoutsFail:                 return "WorkoutsView_LoadMyWorkouts_Fail"
            case .loadTopWorkoutsStart:               return "WorkoutsView_LoadTopWorkouts_Start"
            case .loadTopWorkoutsSuccess:             return "WorkoutsView_LoadTopWorkouts_Success"
            case .loadTopWorkoutsFail:                return "WorkoutsView_LoadTopWorkouts_Fail"
            case .incrementWorkoutStart:              return "WorkoutsView_IncrementWorkout_Start"
            case .incrementWorkoutSuccess:            return "WorkoutsView_IncrementWorkout_Success"
            case .incrementWorkoutFail:               return "WorkoutsView_IncrementWorkout_Fail"
            case .syncWorkoutsFromCurrentUserStart:   return "WorkoutsView_UserSync_Start"
            case .syncWorkoutsFromCurrentUserNoUid:   return "WorkoutsView_UserSync_NoUID"
            case .syncWorkoutsFromCurrentUserSuccess: return "WorkoutsView_UserSync_Success"
            case .syncWorkoutsFromCurrentUserFail:    return "WorkoutsView_UserSync_Fail"
            case .onAddWorkoutPressed:                return "WorkoutsView_AddWorkoutPressed"
            case .favouritesSectionViewed:               return "WorkoutsView_Favourites_SectionViewed"
            case .bookmarkedSectionViewed:               return "WorkoutsView_Bookmarked_SectionViewed"
            case .trendingSectionViewed:                 return "WorkoutsView_Trending_SectionViewed"
            case .myTemplatesSectionViewed:              return "WorkoutsView_MyTemplates_SectionViewed"
            case .emptyStateShown:                       return "WorkoutsView_EmptyState_Shown"
            case .onWorkoutPressedFromFavourites:     return "WorkoutsView_WorkoutPressed_Favourites"
            case .onWorkoutPressedFromBookmarked:     return "WorkoutsView_WorkoutPressed_Bookmarked"
            case .onWorkoutPressedFromTrending:       return "WorkoutsView_WorkoutPressed_Trending"
            case .onWorkoutPressedFromMyTemplates:    return "WorkoutsView_WorkoutPressed_MyTemplates"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .performWorkoutSearchSuccess(query: let query, resultCount: let count):
                return ["query": query, "resultCount": count]
            case .performWorkoutSearchEmptyResults(query: let query):
                return ["query": query]
            case .loadMyWorkoutsSuccess(count: let count):
                return ["count": count]
            case .loadTopWorkoutsSuccess(count: let count):
                return ["count": count]
            case .syncWorkoutsFromCurrentUserSuccess(favouriteCount: let favCount, bookmarkedCount: let bookCount):
                return ["favouriteCount": favCount, "bookmarkedCount": bookCount]
            case .favouritesSectionViewed(count: let count):
                return ["count": count]
            case .bookmarkedSectionViewed(count: let count):
                return ["count": count]
            case .trendingSectionViewed(count: let count):
                return ["count": count]
            case .myTemplatesSectionViewed(count: let count):
                return ["count": count]
            case .loadMyWorkoutsFail(error: let error), .loadTopWorkoutsFail(error: let error), .performWorkoutSearchFail(error: let error), .incrementWorkoutFail(error: let error), .syncWorkoutsFromCurrentUserFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .loadMyWorkoutsFail, .loadTopWorkoutsFail, .performWorkoutSearchFail, .incrementWorkoutFail, .syncWorkoutsFromCurrentUserFail:
                return .severe
            case .syncWorkoutsFromCurrentUserNoUid:
                return .warning
            default:
                return .analytic

            }
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
