//
//  WorkoutTemplateDetailView.swift
//  DialedIn
//
//  Created by AI Assistant on 23/09/2025.
//

import SwiftUI

@Observable
@MainActor
class WorkoutTemplateDetailViewModel {
    private let userManager: UserManager
    private let workoutTemplateManager: WorkoutTemplateManager
    private let workoutSessionManager: WorkoutSessionManager
    
    private(set) var isDeleting: Bool = false

    var showStartSessionSheet: Bool = false
    var showAlert: AnyAppAlert?
    var showEditSheet: Bool = false
    var showDeleteConfirmation: Bool = false
    var isBookmarked: Bool = false
    var isFavourited: Bool = false
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    init(
        container: DependencyContainer
    ) {
        self.userManager = container.resolve(UserManager.self)!
        self.workoutTemplateManager = container.resolve(WorkoutTemplateManager.self)!
        self.workoutSessionManager = container.resolve(WorkoutSessionManager.self)!
    }
    
    func loadInitialState(template: WorkoutTemplateModel) {
        let user = currentUser
        // Always treat authored templates as bookmarked
        let isAuthor = user?.userId == template.authorId
        isBookmarked = isAuthor || (user?.bookmarkedWorkoutTemplateIds?.contains(template.id) ?? false) || (user?.createdWorkoutTemplateIds?.contains(template.id) ?? false)
        isFavourited = user?.favouritedWorkoutTemplateIds?.contains(template.id) ?? false
    }
    
    func onBookmarkPressed(template: WorkoutTemplateModel) async {
        let newState = !isBookmarked
        do {
            // If unbookmarking and currently favourited, unfavourite first to enforce rule
            if !newState && isFavourited {
                try await workoutTemplateManager.favouriteWorkoutTemplate(id: template.id, isFavourited: false)
                isFavourited = false
                // Remove from user's favourited list
                try await userManager.removeFavouritedWorkoutTemplate(workoutId: template.id)
            }
            try await workoutTemplateManager.bookmarkWorkoutTemplate(id: template.id, isBookmarked: newState)
            if newState {
                try await userManager.addBookmarkedWorkoutTemplate(workoutId: template.id)
            } else {
                try await userManager.removeBookmarkedWorkoutTemplate(workoutId: template.id)
            }
            isBookmarked = newState
        } catch {
            showAlert = AnyAppAlert(title: "Failed to update bookmark status", subtitle: "Please try again later")
        }
    }
    
    func onFavoritePressed(template: WorkoutTemplateModel) async {
        let newState = !isFavourited
        do {
            // If favouriting and not bookmarked, bookmark first to enforce rule
            if newState && !isBookmarked {
                try await workoutTemplateManager.bookmarkWorkoutTemplate(id: template.id, isBookmarked: true)
                try await userManager.addBookmarkedWorkoutTemplate(workoutId: template.id)
                isBookmarked = true
            }
            try await workoutTemplateManager.favouriteWorkoutTemplate(id: template.id, isFavourited: newState)
            if newState {
                try await userManager.addFavouritedWorkoutTemplate(workoutId: template.id)
            } else {
                try await userManager.removeFavouritedWorkoutTemplate(workoutId: template.id)
            }
            isFavourited = newState
        } catch {
            showAlert = AnyAppAlert(title: "Failed to update favourite status", subtitle: "Please try again later")
        }
    }
    
    func deleteWorkout(template: WorkoutTemplateModel, onDismiss: @escaping () -> Void) async {
        isDeleting = true
        do {
            // Remove from user's created templates list
            try await userManager.removeCreatedWorkoutTemplate(workoutId: template.id)
            
            // Remove from bookmarked if bookmarked
            if isBookmarked {
                try await userManager.removeBookmarkedWorkoutTemplate(workoutId: template.id)
            }
            
            // Remove from favourited if favourited
            if isFavourited {
                try await userManager.removeFavouritedWorkoutTemplate(workoutId: template.id)
            }
            
            // Delete the workout template
            try await workoutTemplateManager.deleteWorkoutTemplate(id: template.id)
            
            // Dismiss the view after successful deletion
            onDismiss()
        } catch {
            isDeleting = false
            showAlert = AnyAppAlert(title: "Failed to delete workout", subtitle: "Please try again later")
        }
    }
}

struct WorkoutTemplateDetailView: View {
    @Environment(DependencyContainer.self) private var container

    @State var viewModel: WorkoutTemplateDetailViewModel
    
    @Environment(UserManager.self) private var userManager
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager
    @Environment(WorkoutSessionManager.self) private var workoutSessionManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    
    let workoutTemplate: WorkoutTemplateModel
    
    private var isAuthor: Bool {
        userManager.currentUser?.userId == workoutTemplate.authorId
    }
    
    var body: some View {
        List {
            if let url = workoutTemplate.imageURL {
                imageSection(url: url)
            }

            Section(header: Text("Exercises")) {
                ForEach(workoutTemplate.exercises) { exercise in
                    exerciseSection(exercise: exercise)
                }
            }
        }
        .navigationTitle(workoutTemplate.name)
        .navigationSubtitle(workoutTemplate.description ?? "")
        .navigationBarTitleDisplayMode(.large)
        .showCustomAlert(alert: $viewModel.showAlert)
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(container: container))
        }
        #endif
        .toolbar {
            toolbarContent
        }
        .onAppear { viewModel.loadInitialState(template: workoutTemplate)}
        .onChange(of: viewModel.currentUser) {_, _ in
            let user = viewModel.currentUser
            let isAuthor = user?.userId == workoutTemplate.authorId
            viewModel.isBookmarked = isAuthor || (viewModel.currentUser?.bookmarkedWorkoutTemplateIds?.contains(workoutTemplate.id) ?? false) || (user?.createdWorkoutTemplateIds?.contains(workoutTemplate.id) ?? false)
            viewModel.isFavourited = user?.favouritedWorkoutTemplateIds?.contains(workoutTemplate.id) ?? false
        }
        .sheet(isPresented: $viewModel.showStartSessionSheet) {
            WorkoutStartView(viewModel: WorkoutStartViewModel(container: container), template: workoutTemplate)
                .environment(userManager)
        }
        .sheet(isPresented: $viewModel.showEditSheet) {
            CreateWorkoutView(workoutTemplate: workoutTemplate)
        }
        .confirmationDialog("Delete Workout", isPresented: $viewModel.showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteWorkout(template: workoutTemplate, onDismiss: {
                        dismiss()
                    })
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete '\(workoutTemplate.name)'? This action cannot be undone.")
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif

        // Show edit button for authors
        if isAuthor {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                Task {
                    await viewModel.onFavoritePressed(template: workoutTemplate)
                }
            } label: {
                Image(systemName: viewModel.isFavourited ? "heart.fill" : "heart")
            }
            .disabled(workoutSessionManager.activeSession != nil)
        }
        // Hide bookmark button when the current user is the author
        if userManager.currentUser?.userId != nil && userManager.currentUser?.userId != workoutTemplate.authorId {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await viewModel.onBookmarkPressed(template: workoutTemplate)
                    }
                } label: {
                    Image(systemName: viewModel.isBookmarked ? "book.closed.fill" : "book.closed")
                }
            }
        }

        // Show edit button when not in edit mode
        if isAuthor && editMode?.wrappedValue != .active {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.showEditSheet = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }

        // Show delete button only in edit mode
        if isAuthor && editMode?.wrappedValue == .active {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    viewModel.showDeleteConfirmation = true
                } label: {
                    if viewModel.isDeleting {
                        ProgressView()
                    } else {
                        Image(systemName: "trash")
                    }
                }
                .disabled(viewModel.isDeleting)
            }
        }

        // Hide start button in edit mode
        if editMode?.wrappedValue != .active {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.showStartSessionSheet = true
                } label: {
                    Label("Start", systemImage: "play.fill")
                }
                .buttonStyle(.glassProminent)
            }
        }
    }
    
    private func imageSection(url: String) -> some View {
        Section {
            ImageLoaderView(urlString: url, resizingMode: .fill)
                .frame(maxWidth: .infinity, minHeight: 180)
        }
        .removeListRowFormatting()
    }
    
    private func exerciseSection(exercise: ExerciseTemplateModel) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(exercise.name)
                    .fontWeight(.semibold)
                Spacer()
                Text(exercise.type.description)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            if let notes = exercise.description, !notes.isEmpty {
                Text(notes)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        WorkoutTemplateDetailView(viewModel: WorkoutTemplateDetailViewModel(container: DevPreview.shared.container), workoutTemplate: WorkoutTemplateModel.mock)
    }
    .previewEnvironment()
}
