//
//  TrainingView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct TrainingView: View {
    
    @Environment(UserManager.self) private var userManager
    @Environment(ExerciseTemplateManager.self) private var exerciseTemplateManager
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager
    
    @State private var presentationMode: TrainingPresentationMode = .workouts

    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    
    @State private var searchExerciseTask: Task<Void, Never>?
    @State private var searchWorkoutTask: Task<Void, Never>?
    @State private var isLoading: Bool = false
    @State private var searchText: String = ""
    @State private var showAlert: AnyAppAlert?
    @State private var isShowingInspector: Bool = false
    
    @State private var myExercises: [ExerciseTemplateModel] = []
    @State private var favouriteExercises: [ExerciseTemplateModel] = []
    @State private var bookmarkedExercises: [ExerciseTemplateModel] = []
    @State private var exercises: [ExerciseTemplateModel] = []
    @State private var showAddExerciseModal: Bool = false
    @State private var selectedExerciseTemplate: ExerciseTemplateModel?

    @State private var myWorkouts: [WorkoutTemplateModel] = []
    @State private var favouriteWorkouts: [WorkoutTemplateModel] = []
    @State private var bookmarkedWorkouts: [WorkoutTemplateModel] = []
    @State private var workouts: [WorkoutTemplateModel] = []
    @State private var showAddWorkoutModal: Bool = false
    @State private var selectedWorkoutTemplate: WorkoutTemplateModel?

    enum TrainingPresentationMode {
        case workouts
        case exercises
    }
    
    var body: some View {
        NavigationStack {
            List {
                pickerSection
                switch presentationMode {
                case .workouts:
                    workoutSection
                case .exercises:
                    exerciseSection
                }
            }
            .navigationTitle("Training")
            .navigationSubtitle(Date.now.formatted(date: .abbreviated, time: .omitted))
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .scrollIndicators(.hidden)
            .showCustomAlert(alert: $showAlert)
            .toolbar {
                #if DEBUG || MOCK
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showDebugView = true
                    } label: {
                        Image(systemName: "info")
                    }
                }
                #endif
                
                #if os(iOS)
                if UIDevice.current.userInterfaceIdiom != .phone {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isShowingInspector.toggle()
                        } label: {
                            Image(systemName: "info")
                        }
                    }
                }
                #else
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingInspector.toggle()
                    } label: {
                        Image(systemName: "info")
                    }
                }
                #endif
            }
            #if DEBUG || MOCK
            .sheet(isPresented: $showDebugView) {
                DevSettingsView()
            }
            #endif
            .sheet(isPresented: $showAddWorkoutModal) {
                CreateWorkoutView()
            }
            .sheet(isPresented: $showAddExerciseModal) {
                CreateExerciseView()
            }
            .task {
                await loadMyExercisesIfNeeded()
                await loadTopExercisesIfNeeded()
                await syncSavedExercisesFromUser()
                
                await loadMyWorkoutsIfNeeded()
                await loadTopWorkoutsIfNeeded()
                await syncSavedWorkoutsFromUser()
            }
            .onChange(of: userManager.currentUser) {
                Task {
                    await syncSavedExercisesFromUser()
                    await syncSavedWorkoutsFromUser()
                }
            }
        }
        .inspector(isPresented: $isShowingInspector) {
            Group {
                if let exercise = selectedExerciseTemplate {
                    NavigationStack {
                        ExerciseDetailView(exerciseTemplate: exercise)
                    }
                } else if let workout = selectedWorkoutTemplate {
                    NavigationStack {
                        WorkoutTemplateDetailView(workoutTemplate: workout)
                    }
                } else {
                    Text("Select an item")
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
            .inspectorColumnWidth(min: 300, ideal: 400, max: 600)
        }
    }
}

#Preview {
    TabView {
        TrainingView()
            .tabItem {
                Label("Training", systemImage: "dumbbell")
            }
        
        TrainingView()
            .tabItem {
                Label("Training", systemImage: "dumbbell")
            }
        
        TrainingView()
            .tabItem {
                Label("Training", systemImage: "dumbbell")
            }
        
        TrainingView()
            .tabItem {
                Label("Training", systemImage: "dumbbell")
            }
    }
    .tabBarMinimizeBehavior(.onScrollDown)
    .previewEnvironment()
}

extension TrainingView {
    private var pickerSection: some View {
        Section {
            Picker("Section", selection: $presentationMode) {
                Text("Workouts").tag(TrainingPresentationMode.workouts)
                Text("Exercises").tag(TrainingPresentationMode.exercises)
            }
            .pickerStyle(.segmented)
        }
        .listSectionSpacing(0)
        .removeListRowFormatting()
    }
    
    private var exerciseSection: some View {
        Group {
            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                
                if !favouriteExercises.isEmpty {
                    favouriteExerciseTemplatesSection
                }
                
                myExerciseSection
                
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
    
    private var workoutSection: some View {
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
    
    private var myExerciseSection: some View {
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

    enum Event: LoggableEvent {
        case start
        case success
        case fail(error: Error)

        var eventName: String {
            switch self {
            case .start:    return "Start"
            case .success:  return "Success"
            case .fail:     return "Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .fail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .fail:
                return .severe
            default:
                return .analytic

            }
        }
    }
}
    
extension TrainingView {
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
