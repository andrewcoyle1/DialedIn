//
//  WorkoutTemplateDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
import CustomRouting

struct WorkoutTemplateDetailViewDelegate {
    let workoutTemplate: WorkoutTemplateModel
}

struct WorkoutTemplateDetailView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode

    @State var viewModel: WorkoutTemplateDetailViewModel
    
    let delegate: WorkoutTemplateDetailViewDelegate

    private var isAuthor: Bool {
        viewModel.currentUser?.userId == delegate.workoutTemplate.authorId
    }
    
    var body: some View {
        List {
            if let url = delegate.workoutTemplate.imageURL {
                imageSection(url: url)
            }
            exercisesSection
        }
        .navigationTitle(delegate.workoutTemplate.name)
        .navigationSubtitle(delegate.workoutTemplate.description ?? "")
        .navigationBarTitleDisplayMode(.large)
        .scrollIndicators(.hidden)
        .showCustomAlert(alert: $viewModel.showAlert)
        .toolbar {
            toolbarContent
        }
        .onAppear { viewModel.loadInitialState(template: delegate.workoutTemplate)}
        .onChange(of: viewModel.currentUser) {_, _ in
            let user = viewModel.currentUser
            let isAuthor = user?.userId == delegate.workoutTemplate.authorId
            viewModel.isBookmarked = isAuthor || (viewModel.currentUser?.bookmarkedWorkoutTemplateIds?.contains(delegate.workoutTemplate.id) ?? false) || (user?.createdWorkoutTemplateIds?.contains(delegate.workoutTemplate.id) ?? false)
            viewModel.isFavourited = user?.favouritedWorkoutTemplateIds?.contains(delegate.workoutTemplate.id) ?? false
        }
    }

    private var exercisesSection: some View {
        Section(header: Text("Exercises")) {
            ForEach(delegate.workoutTemplate.exercises) { exercise in
                exerciseSection(exercise: exercise)
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.onDevSettingsPressed()
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
                    await viewModel.onFavoritePressed(template: delegate.workoutTemplate)
                }
            } label: {
                Image(systemName: viewModel.isFavourited ? "heart.fill" : "heart")
            }
            .disabled(viewModel.activeSession != nil)
        }
        // Hide bookmark button when the current user is the author
        if viewModel.currentUser?.userId != nil && viewModel.currentUser?.userId != delegate.workoutTemplate.authorId {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await viewModel.onBookmarkPressed(template: delegate.workoutTemplate)
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
                    viewModel.onEditWorkoutPressed(template: delegate.workoutTemplate)
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }

        // Show delete button only in edit mode
        if isAuthor && editMode?.wrappedValue == .active {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    viewModel.showDeleteConfirmation(workoutTemplate: delegate.workoutTemplate, onDismiss: {
                        dismiss()
                    })
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
                    viewModel.onStartWorkoutPressed(workoutTemplate: delegate.workoutTemplate)
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
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.workoutTemplateDetailView(router: router, delegate: WorkoutTemplateDetailViewDelegate(workoutTemplate: WorkoutTemplateModel.mock))
    }
    .previewEnvironment()
}
