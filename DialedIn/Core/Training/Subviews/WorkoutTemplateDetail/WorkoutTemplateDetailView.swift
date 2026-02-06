//
//  WorkoutTemplateDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
import SwiftfulRouting

struct WorkoutTemplateDetailDelegate {
    let workoutTemplate: WorkoutTemplateModel
}

struct WorkoutTemplateDetailView: View {

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
        // Show edit button when not in edit mode
        if isAuthor {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    presenter.onEditWorkoutPressed(template: delegate.workoutTemplate)
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }

        // Show delete button only in edit mode
        if isAuthor {
            ToolbarItem(placement: .topBarLeading) {
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

        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif

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

        // Hide start button in edit mode
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onStartWorkoutPressed(workoutTemplate: delegate.workoutTemplate)
            } label: {
                Label("Start", systemImage: "play.fill")
            }
            .buttonStyle(.glassProminent)
        }
    }
    
    private func imageSection(url: String) -> some View {
        Section {
            ImageLoaderView(urlString: url, resizingMode: .fill)
                .frame(maxWidth: .infinity, minHeight: 180)
        }
        .removeListRowFormatting()
    }
    
    private func exerciseSection(exercise: WorkoutTemplateExercise) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(exercise.exercise.name)
                    .fontWeight(.semibold)
                Spacer()
                Text(exercise.exercise.type?.name ?? "Uncategorized")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            if let notes = exercise.exercise.description, !notes.isEmpty {
                Text(notes)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

extension CoreBuilder {
    func workoutTemplateDetailView(router: AnyRouter, delegate: WorkoutTemplateDetailDelegate) -> some View {
        WorkoutTemplateDetailView(
            presenter: WorkoutTemplateDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showWorkoutTemplateDetailView(delegate: WorkoutTemplateDetailDelegate) {
        router.showScreen(.push) { router in
            builder.workoutTemplateDetailView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.workoutTemplateDetailView(router: router, delegate: WorkoutTemplateDetailDelegate(workoutTemplate: WorkoutTemplateModel.mock))
    }
    .previewEnvironment()
}
