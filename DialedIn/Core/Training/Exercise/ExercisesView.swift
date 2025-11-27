//
//  ExercisesView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
import CustomRouting

struct ExercisesDelegate {
    let onExerciseSelectionChanged: ((ExerciseTemplateModel) -> Void)?
}

struct ExercisesView: View {

    @Environment(\.layoutMode) private var layoutMode

    @State var presenter: ExercisesPresenter

    let delegate: ExercisesDelegate

    var body: some View {
        List {
            if presenter.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

                if !presenter.favouriteExercises.isEmpty {
                    favouriteExerciseTemplatesSection
                }

                myExercisesSection
                
                if !presenter.officialExercisesVisible.isEmpty {
                    officialExercisesSection
                }

                if !presenter.bookmarkedOnlyExercises.isEmpty {
                    bookmarkedExerciseTemplatesSection
                }

                if !presenter.trendingExercisesDeduped.isEmpty {
                    exerciseTemplateSection
                }
            } else {
                // Show search results when there is a query
                exerciseTemplateSection
            }
        }
        .screenAppearAnalytics(name: "ExercisesView")
        .navigationTitle("Exercises")
        .navigationSubtitle("\(presenter.exercises.count) exercises")
        .navigationBarTitleDisplayMode(.large)
        .scrollIndicators(.hidden)
        .onFirstTask {
            await presenter.loadMyExercisesIfNeeded()
            await presenter.loadOfficialExercises()
            await presenter.loadTopExercisesIfNeeded()
            await presenter.syncSavedExercisesFromUser()
        }
        .refreshable {
            await presenter.loadMyExercisesIfNeeded()
            await presenter.loadOfficialExercises()
            await presenter.loadTopExercisesIfNeeded()
            await presenter.syncSavedExercisesFromUser()
        }
        .onChange(of: presenter.currentUser) {
            Task {
                await presenter.syncSavedExercisesFromUser()
            }
        }
    }
    
    private var favouriteExerciseTemplatesSection: some View {
        Section {
            ForEach(presenter.favouriteExercises) { exercise in
                CustomListCellView(
                    imageName: exercise.imageURL,
                    title: exercise.name,
                    subtitle: exercise.description
                )
                .anyButton(.highlight) {
                    presenter.onExercisePressed(exercise: exercise, onExerciseSelectionChanged: delegate.onExerciseSelectionChanged)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Favourites")
        }
        .onAppear {
            presenter.favouritesSectionViewed()
        }
    }

    private var bookmarkedExerciseTemplatesSection: some View {
        Section {
            ForEach(presenter.bookmarkedOnlyExercises) { exercise in
                CustomListCellView(
                    imageName: exercise.imageURL,
                    title: exercise.name,
                    subtitle: exercise.description
                )
                .anyButton(.highlight) {
                    presenter.onExercisePressed(exercise: exercise, onExerciseSelectionChanged: delegate.onExerciseSelectionChanged)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Bookmarked")
        }
        .onAppear {
            presenter.bookmarkedSectionViewed()
        }
    }

    private var exerciseTemplateSection: some View {
        Section {
            if presenter.isLoading {
                HStack {
                    ProgressView()
                    Text("Loading...")
                }
                .foregroundStyle(Color.secondary)
                .removeListRowFormatting()
            }
            ForEach(presenter.visibleExerciseTemplates) { exercise in
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
                    presenter.onExercisePressed(exercise: exercise, onExerciseSelectionChanged: delegate.onExerciseSelectionChanged)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text(presenter.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Trending Templates" : "Search Results")
        }
        .onAppear {
            presenter.trendingSectionViewed()
        }
    }

    private var myExercisesSection: some View {
        Section {
            if presenter.myExercisesVisible.isEmpty {
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
                    presenter.emptyStateShown()
                }
            } else {
                ForEach(presenter.myExercisesVisible) { exercise in
                    CustomListCellView(
                        imageName: exercise.imageURL,
                        title: exercise.name,
                        subtitle: exercise.description
                    )
                    .anyButton(.highlight) {
                        presenter.onExercisePressed(exercise: exercise, onExerciseSelectionChanged: delegate.onExerciseSelectionChanged)
                    }
                    .removeListRowFormatting()
                }
            }
        } header: {
            HStack {
                Text("My Templates")
                Spacer()
                Button {
                    presenter.onAddExercisePressed()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                }
            }
        }
        .onAppear {
            presenter.myTemplatesViewed()
        }
    }
    
    private var officialExercisesSection: some View {
        Section {
            ForEach(presenter.officialExercisesVisible) { exercise in
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
                .anyButton(.highlight) {
                    presenter.onExercisePressed(exercise: exercise, onExerciseSelectionChanged: delegate.onExerciseSelectionChanged)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Official Exercises")
        }
        .onAppear {
            presenter.officialSectionViewed()
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.exercisesView(router: router, delegate: ExercisesDelegate(onExerciseSelectionChanged: nil))
    }
    .previewEnvironment()
}
