//
//  WorkoutTemplateDetailView.swift
//  DialedIn
//
//  Created by AI Assistant on 23/09/2025.
//

import SwiftUI

struct WorkoutTemplateDetailView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager
    @Environment(WorkoutSessionManager.self) private var workoutSessionManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    let workoutTemplate: WorkoutTemplateModel
    @State private var showStartSessionSheet: Bool = false
    
    @State private var isBookmarked: Bool = false
    @State private var isFavourited: Bool = false
    
    @State private var showAlert: AnyAppAlert?
    @State private var showEditSheet: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var isDeleting: Bool = false
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    
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
        .showCustomAlert(alert: $showAlert)
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView()
        }
        #endif
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
            
            // Show edit button for authors
            if isAuthor {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await onFavoritePressed()
                    }
                } label: {
                    Image(systemName: isFavourited ? "heart.fill" : "heart")
                }
                .disabled(workoutSessionManager.activeSession != nil)
            }
            // Hide bookmark button when the current user is the author
            if userManager.currentUser?.userId != nil && userManager.currentUser?.userId != workoutTemplate.authorId {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await onBookmarkPressed()
                        }
                    } label: {
                        Image(systemName: isBookmarked ? "book.closed.fill" : "book.closed")
                    }
                }
            }
            
            // Show edit button when not in edit mode
            if isAuthor && editMode?.wrappedValue != .active {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showEditSheet = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
            }
            
            // Show delete button only in edit mode
            if isAuthor && editMode?.wrappedValue == .active {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        if isDeleting {
                            ProgressView()
                        } else {
                            Image(systemName: "trash")
                        }
                    }
                    .disabled(isDeleting)
                }
            }
            
            // Hide start button in edit mode
            if editMode?.wrappedValue != .active {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showStartSessionSheet = true
                    } label: {
                        Label("Start", systemImage: "play.fill")
                    }
                    .buttonStyle(.glassProminent)
                }
            }
            
        }
        .onAppear { loadInitialState()}
        .onChange(of: userManager.currentUser) {_, _ in
            let user = userManager.currentUser
            let isAuthor = user?.userId == workoutTemplate.authorId
            isBookmarked = isAuthor || (user?.bookmarkedWorkoutTemplateIds?.contains(workoutTemplate.id) ?? false) || (user?.createdWorkoutTemplateIds?.contains(workoutTemplate.id) ?? false)
            isFavourited = user?.favouritedWorkoutTemplateIds?.contains(workoutTemplate.id) ?? false
        }
        .sheet(isPresented: $showStartSessionSheet) {
            WorkoutStartView(template: workoutTemplate)
                .environment(userManager)
        }
        .sheet(isPresented: $showEditSheet) {
            CreateWorkoutView(workoutTemplate: workoutTemplate)
        }
        .confirmationDialog("Delete Workout", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                Task {
                    await deleteWorkout()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete '\(workoutTemplate.name)'? This action cannot be undone.")
        }
    }
    
    private func loadInitialState() {
        let user = userManager.currentUser
        // Always treat authored templates as bookmarked
        let isAuthor = user?.userId == workoutTemplate.authorId
        isBookmarked = isAuthor || (user?.bookmarkedWorkoutTemplateIds?.contains(workoutTemplate.id) ?? false) || (user?.createdWorkoutTemplateIds?.contains(workoutTemplate.id) ?? false)
        isFavourited = user?.favouritedWorkoutTemplateIds?.contains(workoutTemplate.id) ?? false
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
    
    private func onBookmarkPressed() async {
        let newState = !isBookmarked
        do {
            // If unbookmarking and currently favourited, unfavourite first to enforce rule
            if !newState && isFavourited {
                try await workoutTemplateManager.favouriteWorkoutTemplate(id: workoutTemplate.id, isFavourited: false)
                isFavourited = false
                // Remove from user's favourited list
                try await userManager.removeFavouritedWorkoutTemplate(workoutId: workoutTemplate.id)
            }
            try await workoutTemplateManager.bookmarkWorkoutTemplate(id: workoutTemplate.id, isBookmarked: newState)
            if newState {
                try await userManager.addBookmarkedWorkoutTemplate(workoutId: workoutTemplate.id)
            } else {
                try await userManager.removeBookmarkedWorkoutTemplate(workoutId: workoutTemplate.id)
            }
            isBookmarked = newState
        } catch {
            showAlert = AnyAppAlert(title: "Failed to update bookmark status", subtitle: "Please try again later")
        }
    }
    
    private func onFavoritePressed() async {
        let newState = !isFavourited
        do {
            // If favouriting and not bookmarked, bookmark first to enforce rule
            if newState && !isBookmarked {
                try await workoutTemplateManager.bookmarkWorkoutTemplate(id: workoutTemplate.id, isBookmarked: true)
                try await userManager.addBookmarkedWorkoutTemplate(workoutId: workoutTemplate.id)
                isBookmarked = true
            }
            try await workoutTemplateManager.favouriteWorkoutTemplate(id: workoutTemplate.id, isFavourited: newState)
            if newState {
                try await userManager.addFavouritedWorkoutTemplate(workoutId: workoutTemplate.id)
            } else {
                try await userManager.removeFavouritedWorkoutTemplate(workoutId: workoutTemplate.id)
            }
            isFavourited = newState
        } catch {
            showAlert = AnyAppAlert(title: "Failed to update favourite status", subtitle: "Please try again later")
        }
    }
    
    private func deleteWorkout() async {
        isDeleting = true
        do {
            // Remove from user's created templates list
            try await userManager.removeCreatedWorkoutTemplate(workoutId: workoutTemplate.id)
            
            // Remove from bookmarked if bookmarked
            if isBookmarked {
                try await userManager.removeBookmarkedWorkoutTemplate(workoutId: workoutTemplate.id)
            }
            
            // Remove from favourited if favourited
            if isFavourited {
                try await userManager.removeFavouritedWorkoutTemplate(workoutId: workoutTemplate.id)
            }
            
            // Delete the workout template
            try await workoutTemplateManager.deleteWorkoutTemplate(id: workoutTemplate.id)
            
            // Dismiss the view after successful deletion
            dismiss()
        } catch {
            isDeleting = false
            showAlert = AnyAppAlert(title: "Failed to delete workout", subtitle: "Please try again later")
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutTemplateDetailView(workoutTemplate: WorkoutTemplateModel.mock)
    }
    .previewEnvironment()
}
