//
//  WorkoutTemplateDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
import CustomRouting

struct WorkoutTemplateDetailView: View {

    @Environment(\.editMode) private var editMode

    @State var presenter: WorkoutTemplateDetailPresenter
    
    let delegate: WorkoutTemplateDetailDelegate

    private var isAuthor: Bool {
        presenter.currentUser?.userId == delegate.workoutTemplate.authorId
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
        .toolbar {
            toolbarContent
        }
        .onAppear { presenter.loadInitialState(template: delegate.workoutTemplate)}
        .onChange(of: presenter.currentUser) {_, _ in
            let user = presenter.currentUser
            let isAuthor = user?.userId == delegate.workoutTemplate.authorId
            presenter.isBookmarked = isAuthor || (presenter.currentUser?.bookmarkedWorkoutTemplateIds?.contains(delegate.workoutTemplate.id) ?? false) || (user?.createdWorkoutTemplateIds?.contains(delegate.workoutTemplate.id) ?? false)
            presenter.isFavourited = user?.favouritedWorkoutTemplateIds?.contains(delegate.workoutTemplate.id) ?? false
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
                presenter.onDevSettingsPressed()
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
                    await presenter.onFavoritePressed(template: delegate.workoutTemplate)
                }
            } label: {
                Image(systemName: presenter.isFavourited ? "heart.fill" : "heart")
            }
            .disabled(presenter.activeSession != nil)
        }
        // Hide bookmark button when the current user is the author
        if presenter.currentUser?.userId != nil && presenter.currentUser?.userId != delegate.workoutTemplate.authorId {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await presenter.onBookmarkPressed(template: delegate.workoutTemplate)
                    }
                } label: {
                    Image(systemName: presenter.isBookmarked ? "book.closed.fill" : "book.closed")
                }
            }
        }

        // Show edit button when not in edit mode
        if isAuthor && editMode?.wrappedValue != .active {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    presenter.onEditWorkoutPressed(template: delegate.workoutTemplate)
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }

        // Show delete button only in edit mode
        if isAuthor && editMode?.wrappedValue == .active {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    presenter.showDeleteConfirmation(workoutTemplate: delegate.workoutTemplate)
                } label: {
                    if presenter.isDeleting {
                        ProgressView()
                    } else {
                        Image(systemName: "trash")
                    }
                }
                .disabled(presenter.isDeleting)
            }
        }

        // Hide start button in edit mode
        if editMode?.wrappedValue != .active {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    presenter.onStartWorkoutPressed(workoutTemplate: delegate.workoutTemplate)
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
        builder.workoutTemplateDetailView(router: router, delegate: WorkoutTemplateDetailDelegate(workoutTemplate: WorkoutTemplateModel.mock))
    }
    .previewEnvironment()
}
