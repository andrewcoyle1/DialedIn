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
    let workoutTemplate: WorkoutTemplateModel
    @State private var showStartSessionSheet: Bool = false
    
    @State private var isBookmarked: Bool = false
    @State private var isFavourited: Bool = false
    
    @State private var showAlert: AnyAppAlert?
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    
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
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showStartSessionSheet = true
                } label: {
                    Label("Start", systemImage: "play.fill")
                }
                .buttonStyle(.glassProminent)
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
}

#Preview {
    NavigationStack {
        WorkoutTemplateDetailView(workoutTemplate: WorkoutTemplateModel.mock)
    }
    .previewEnvironment()
}
