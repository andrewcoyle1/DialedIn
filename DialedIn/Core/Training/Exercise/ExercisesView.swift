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
    @State private var showAddExerciseModal: Bool = false

    @Binding var isShowingInspector: Bool
    @Binding var selectedWorkoutTemplate: WorkoutTemplateModel?
    @Binding var selectedExerciseTemplate: ExerciseTemplateModel?

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
        .sheet(isPresented: $showAddExerciseModal) {
            CreateExerciseView()
        }
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
            logManager.trackEvent(event: Event.favouritesSectionViewed(count: favouriteExercises.count))
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
            logManager.trackEvent(event: Event.bookmarkedSectionViewed(count: bookmarkedOnlyExercises.count))
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
            logManager.trackEvent(event: Event.trendingSectionViewed(count: visibleExerciseTemplates.count))
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
                    logManager.trackEvent(event: Event.emptyStateShown)
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
                    showAddExerciseModal = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                }
            }
        }
        .onAppear {
            logManager.trackEvent(event: Event.myTemplatesSectionViewed(count: myExercisesVisible.count))
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
            logManager.trackEvent(event: Event.officialSectionViewed(count: officialExercisesVisible.count))
        }
    }

    // MARK: Business Logic

    private func onAddExercisePressed() {
        logManager.trackEvent(event: Event.onAddExercisePressed)
        showAddExerciseModal = true
    }

    private func onExercisePressed(exercise: ExerciseTemplateModel) {
        // Only increment click count for non-system exercises
        // System exercises (IDs starting with "system-") are read-only
        if !exercise.id.hasPrefix("system-") {
            Task {
                logManager.trackEvent(event: Event.incrementExerciseStart)
                do {
                    try await exerciseTemplateManager.incrementExerciseTemplateInteraction(id: exercise.id)
                    logManager.trackEvent(event: Event.incrementExerciseSuccess)
                } catch {
                    logManager.trackEvent(event: Event.incrementExerciseFail(error: error))
                }
            }
        }
        selectedWorkoutTemplate = nil
        selectedExerciseTemplate = exercise
        isShowingInspector = true
    }

    private func onExercisePressedFromFavourites(exercise: ExerciseTemplateModel) {
        logManager.trackEvent(event: Event.onExercisePressedFromFavourites)
        onExercisePressed(exercise: exercise)
    }

    private func onExercisePressedFromBookmarked(exercise: ExerciseTemplateModel) {
        logManager.trackEvent(event: Event.onExercisePressedFromBookmarked)
        onExercisePressed(exercise: exercise)
    }

    private func onExercisePressedFromTrending(exercise: ExerciseTemplateModel) {
        logManager.trackEvent(event: Event.onExercisePressedFromTrending)
        onExercisePressed(exercise: exercise)
    }

    private func onExercisePressedFromMyTemplates(exercise: ExerciseTemplateModel) {
        logManager.trackEvent(event: Event.onExercisePressedFromMyTemplates)
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
        logManager.trackEvent(event: Event.searchCleared)
        Task { await loadTopExercisesIfNeeded() }
    }

    private func startFreshSearch(for query: String) {
        isLoading = true
        logManager.trackEvent(event: Event.performExerciseSearchStart)

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
            logManager.trackEvent(event: Event.performExerciseSearchEmptyResults(query: query))
        } else {
            logManager.trackEvent(event: Event.performExerciseSearchSuccess(query: query, resultCount: results.count))
        }
    }

    private func handleSearchError(_ error: Error) {
        logManager.trackEvent(event: Event.performExerciseSearchFail(error: error))
        isLoading = false
        exercises = []

        showAlert = AnyAppAlert(
            title: "No Exercises Found",
            subtitle: "We couldn't find any exercise templates matching your search. Please try a different name or check your connection."
        )
    }

    private func loadMyExercisesIfNeeded() async {
        guard let userId = userManager.currentUser?.userId else { return }
        logManager.trackEvent(event: Event.loadMyExercisesStart)
        do {
            let mine = try await exerciseTemplateManager.getExerciseTemplatesForAuthor(authorId: userId)
            myExercises = mine
            logManager.trackEvent(event: Event.loadMyExercisesSuccess(count: mine.count))
        } catch {
            logManager.trackEvent(event: Event.loadMyExercisesFail(error: error))
            showAlert = AnyAppAlert(
                title: "Unable to Load Your Exercises",
                subtitle: "We couldn't retrieve your custom exercise templates. Please check your connection or try again later."
            )
        }
    }
    
    private func loadOfficialExercises() async {
        logManager.trackEvent(event: Event.loadOfficialExercisesStart)
        do {
            let official = try exerciseTemplateManager.getSystemExerciseTemplates()
            officialExercises = official
            logManager.trackEvent(event: Event.loadOfficialExercisesSuccess(count: official.count))
        } catch {
            logManager.trackEvent(event: Event.loadOfficialExercisesFail(error: error))
            // Don't show alert for official exercises - it's not critical
        }
    }

    private func loadTopExercisesIfNeeded() async {
        guard searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isLoading = true
        logManager.trackEvent(event: Event.loadTopExercisesStart)
        do {
            let top = try await exerciseTemplateManager.getTopExerciseTemplatesByClicks(limitTo: 10)
            exercises = top
            isLoading = false
            logManager.trackEvent(event: Event.loadTopExercisesSuccess(count: top.count))
        } catch {
            isLoading = false
            logManager.trackEvent(event: Event.loadTopExercisesFail(error: error))
            showAlert = AnyAppAlert(
                title: "Unable to Load Trending Templates",
                subtitle: "We couldn't load top exercise templates. Please try again later."
            )
        }
    }

    private func syncSavedExercisesFromUser() async {
        logManager.trackEvent(event: Event.syncExercisesFromCurrentUserStart)
        guard let user = userManager.currentUser else {
            logManager.trackEvent(event: Event.syncExercisesFromCurrentUserNoUid)
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
            logManager.trackEvent(event: Event.syncExercisesFromCurrentUserSuccess(favouriteCount: favs.count, bookmarkedCount: bookmarks.count))
        } catch {
            logManager.trackEvent(event: Event.syncExercisesFromCurrentUserFail(error: error))
            showAlert = AnyAppAlert(
                title: "Unable to Load Saved Exercises",
                subtitle: "We couldn't retrieve your saved exercises. Please try again later."
            )
        }
    }

    // MARK: Analytics Events

    enum Event: LoggableEvent {
        case performExerciseSearchStart
        case performExerciseSearchSuccess(query: String, resultCount: Int)
        case performExerciseSearchFail(error: Error)
        case performExerciseSearchEmptyResults(query: String)
        case searchCleared
        case loadMyExercisesStart
        case loadMyExercisesSuccess(count: Int)
        case loadMyExercisesFail(error: Error)
        case loadOfficialExercisesStart
        case loadOfficialExercisesSuccess(count: Int)
        case loadOfficialExercisesFail(error: Error)
        case loadTopExercisesStart
        case loadTopExercisesSuccess(count: Int)
        case loadTopExercisesFail(error: Error)
        case incrementExerciseStart
        case incrementExerciseSuccess
        case incrementExerciseFail(error: Error)
        case syncExercisesFromCurrentUserStart
        case syncExercisesFromCurrentUserNoUid
        case syncExercisesFromCurrentUserSuccess(favouriteCount: Int, bookmarkedCount: Int)
        case syncExercisesFromCurrentUserFail(error: Error)
        case onAddExercisePressed
        case favouritesSectionViewed(count: Int)
        case bookmarkedSectionViewed(count: Int)
        case officialSectionViewed(count: Int)
        case trendingSectionViewed(count: Int)
        case myTemplatesSectionViewed(count: Int)
        case emptyStateShown
        case onExercisePressedFromFavourites
        case onExercisePressedFromBookmarked
        case onExercisePressedFromTrending
        case onExercisePressedFromMyTemplates

        var eventName: String {
            switch self {
            case .performExerciseSearchStart:          return "ExercisesView_Search_Start"
            case .performExerciseSearchSuccess:        return "ExercisesView_Search_Success"
            case .performExerciseSearchFail:           return "ExercisesView_Search_Fail"
            case .performExerciseSearchEmptyResults:   return "ExercisesView_Search_EmptyResults"
            case .searchCleared:                         return "ExercisesView_Search_Cleared"
            case .loadMyExercisesStart:                return "ExercisesView_LoadMyExercises_Start"
            case .loadMyExercisesSuccess:              return "ExercisesView_LoadMyExercises_Success"
            case .loadMyExercisesFail:                 return "ExercisesView_LoadMyExercises_Fail"
            case .loadOfficialExercisesStart:          return "ExercisesView_LoadOfficialExercises_Start"
            case .loadOfficialExercisesSuccess:        return "ExercisesView_LoadOfficialExercises_Success"
            case .loadOfficialExercisesFail:           return "ExercisesView_LoadOfficialExercises_Fail"
            case .loadTopExercisesStart:               return "ExercisesView_LoadTopExercises_Start"
            case .loadTopExercisesSuccess:             return "ExercisesView_LoadTopExercises_Success"
            case .loadTopExercisesFail:                return "ExercisesView_LoadTopExercises_Fail"
            case .incrementExerciseStart:              return "ExercisesView_IncrementExercise_Start"
            case .incrementExerciseSuccess:            return "ExercisesView_IncrementExercise_Success"
            case .incrementExerciseFail:               return "ExercisesView_IncrementExercise_Fail"
            case .syncExercisesFromCurrentUserStart:   return "ExercisesView_UserSync_Start"
            case .syncExercisesFromCurrentUserNoUid:   return "ExercisesView_UserSync_NoUID"
            case .syncExercisesFromCurrentUserSuccess: return "ExercisesView_UserSync_Success"
            case .syncExercisesFromCurrentUserFail:    return "ExercisesView_UserSync_Fail"
            case .onAddExercisePressed:                return "ExercisesView_AddExercisePressed"
            case .favouritesSectionViewed:               return "ExercisesView_Favourites_SectionViewed"
            case .bookmarkedSectionViewed:               return "ExercisesView_Bookmarked_SectionViewed"
            case .officialSectionViewed:                 return "ExercisesView_Official_SectionViewed"
            case .trendingSectionViewed:                 return "ExercisesView_Trending_SectionViewed"
            case .myTemplatesSectionViewed:              return "ExercisesView_MyTemplates_SectionViewed"
            case .emptyStateShown:                       return "ExercisesView_EmptyState_Shown"
            case .onExercisePressedFromFavourites:     return "ExercisesView_ExercisePressed_Favourites"
            case .onExercisePressedFromBookmarked:     return "ExercisesView_ExercisePressed_Bookmarked"
            case .onExercisePressedFromTrending:       return "ExercisesView_ExercisePressed_Trending"
            case .onExercisePressedFromMyTemplates:    return "ExercisesView_ExercisePressed_MyTemplates"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .performExerciseSearchSuccess(query: let query, resultCount: let count):
                return ["query": query, "resultCount": count]
            case .performExerciseSearchEmptyResults(query: let query):
                return ["query": query]
            case .loadMyExercisesSuccess(count: let count):
                return ["count": count]
            case .loadOfficialExercisesSuccess(count: let count):
                return ["count": count]
            case .loadTopExercisesSuccess(count: let count):
                return ["count": count]
            case .syncExercisesFromCurrentUserSuccess(favouriteCount: let favCount, bookmarkedCount: let bookCount):
                return ["favouriteCount": favCount, "bookmarkedCount": bookCount]
            case .favouritesSectionViewed(count: let count):
                return ["count": count]
            case .bookmarkedSectionViewed(count: let count):
                return ["count": count]
            case .officialSectionViewed(count: let count):
                return ["count": count]
            case .trendingSectionViewed(count: let count):
                return ["count": count]
            case .myTemplatesSectionViewed(count: let count):
                return ["count": count]
            case .loadMyExercisesFail(error: let error), .loadOfficialExercisesFail(error: let error), .loadTopExercisesFail(error: let error), .performExerciseSearchFail(error: let error), .incrementExerciseFail(error: let error), .syncExercisesFromCurrentUserFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .loadMyExercisesFail, .loadOfficialExercisesFail, .loadTopExercisesFail, .performExerciseSearchFail, .incrementExerciseFail, .syncExercisesFromCurrentUserFail:
                return .severe
            case .syncExercisesFromCurrentUserNoUid:
                return .warning
            default:
                return .analytic

            }
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
