//
//  WorkoutsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
import CustomRouting

struct WorkoutsView: View {

    @State var presenter: WorkoutsPresenter

    let delegate: WorkoutsDelegate

    var body: some View {
        List {
            if presenter.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

                if !presenter.favouriteWorkouts.isEmpty {
                    favouriteWorkoutTemplatesSection
                }

                myWorkoutsSection
                
                if !presenter.systemWorkouts.isEmpty {
                    systemWorkoutTemplatesSection
                }

                if !presenter.bookmarkedOnlyWorkouts.isEmpty {
                    bookmarkedWorkoutTemplatesSection
                }

                if !presenter.trendingWorkoutsDeduped.isEmpty {
                    workoutTemplateSection
                }
            } else {
                // Show search results when there is a query
                workoutTemplateSection
            }
        }
        .screenAppearAnalytics(name: "WorkoutsView")
        .navigationTitle("Workouts")
        .navigationSubtitle("\(presenter.workouts.count) workouts")
        .navigationBarTitleDisplayMode(.large)
        .scrollIndicators(.hidden)
        .onFirstTask {
            await presenter.loadAllWorkouts()
        }
        .refreshable {
            await presenter.loadAllWorkouts()
        }
        .onChange(of: presenter.currentUser) {
            Task {
                await presenter.syncSavedWorkoutsFromUser()
            }
        }
    }

    // MARK: UI Components
    private var favouriteWorkoutTemplatesSection: some View {
        Section {
            ForEach(presenter.favouriteWorkouts) { workout in
                CustomListCellView(
                    imageName: workout.imageURL,
                    title: workout.name,
                    subtitle: workout.description
                )
                .anyButton(.highlight) {
                    presenter.onWorkoutPressed(workout: workout)
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

    private var bookmarkedWorkoutTemplatesSection: some View {
        Section {
            ForEach(presenter.bookmarkedOnlyWorkouts) { workout in
                CustomListCellView(
                    imageName: workout.imageURL,
                    title: workout.name,
                    subtitle: workout.description
                )
                .anyButton(.highlight) {
                    presenter.onWorkoutPressed(workout: workout)
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

    private var workoutTemplateSection: some View {
        Section {
            if presenter.isLoading {
                HStack {
                    ProgressView()
                    Text("Loading...")
                }
                .foregroundStyle(Color.secondary)
                .removeListRowFormatting()
            }
            ForEach(presenter.visibleWorkoutTemplates) { workout in
                CustomListCellView(
                    imageName: workout.imageURL,
                    title: workout.name,
                    subtitle: workout.description
                )
                .anyButton(.highlight) {
                    presenter.onWorkoutPressed(workout: workout)
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

    private var myWorkoutsSection: some View {
        Section {
            if presenter.myWorkoutsVisible.isEmpty {
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
                .onAppear {
                    presenter.emptyStateShown()
                }
            } else {
                ForEach(presenter.myWorkoutsVisible) { workout in
                    CustomListCellView(
                        imageName: workout.imageURL,
                        title: workout.name,
                        subtitle: workout.description
                    )
                    .anyButton(.highlight) {
                        presenter.onWorkoutPressed(workout: workout)
                    }
                    .removeListRowFormatting()
                }
            }
        } header: {
            HStack {
                Text("My Templates")
                Spacer()
                Button {
                    presenter.onAddWorkoutPressed()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                }
            }
        }
        .onAppear {
            presenter.myTemplatesSectionViewed()
        }
    }
    
    private var systemWorkoutTemplatesSection: some View {
        Section {
            ForEach(presenter.systemWorkouts) { workout in
                CustomListCellView(
                    imageName: workout.imageURL,
                    title: workout.name,
                    subtitle: workout.description
                )
                .anyButton(.highlight) {
                    presenter.onWorkoutPressed(workout: workout)
                }
                .removeListRowFormatting()
            }
        } header: {
            HStack {
                Text("Pre-Built Templates")
                Spacer()
                Text("\(presenter.systemWorkouts.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } footer: {
            Text("Professional workout templates designed for common training programs.")
        }
        .onAppear {
            presenter.systemTemplatesSectionViewed()
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.workoutsView(router: router, delegate: WorkoutsDelegate())
    }
    .previewEnvironment()
}
