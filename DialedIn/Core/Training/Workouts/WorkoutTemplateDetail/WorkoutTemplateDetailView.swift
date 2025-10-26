//
//  WorkoutTemplateDetailView.swift
//  DialedIn
//
//  Created by AI Assistant on 23/09/2025.
//

import SwiftUI

struct WorkoutTemplateDetailView: View {
    @Environment(DependencyContainer.self) private var container

    @State var viewModel: WorkoutTemplateDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    
    let workoutTemplate: WorkoutTemplateModel
    
    private var isAuthor: Bool {
        viewModel.currentUser?.userId == workoutTemplate.authorId
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
            DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
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
            WorkoutStartView(viewModel: WorkoutStartViewModel(interactor: CoreInteractor(container: container)), template: workoutTemplate)
        }
        .sheet(isPresented: $viewModel.showEditSheet) {
            CreateWorkoutView(
                viewModel: CreateWorkoutViewModel(
                    interactor: CoreInteractor(
                    container: container),
                    workoutTemplate: workoutTemplate)
            )
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
            .disabled(viewModel.activeSession != nil)
        }
        // Hide bookmark button when the current user is the author
        if viewModel.currentUser?.userId != nil && viewModel.currentUser?.userId != workoutTemplate.authorId {
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
        WorkoutTemplateDetailView(viewModel: WorkoutTemplateDetailViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), workoutTemplate: WorkoutTemplateModel.mock)
    }
    .previewEnvironment()
}
