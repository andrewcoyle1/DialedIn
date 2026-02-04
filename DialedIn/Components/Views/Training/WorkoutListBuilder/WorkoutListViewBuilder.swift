//
//  WorkoutsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
import SwiftfulRouting

struct WorkoutListDelegateBuilder {
    var onWorkoutSelectionChanged: ((WorkoutTemplateModel) -> Void)?
}

struct WorkoutListViewBuilder: View {

    @State var presenter: WorkoutListPresenterBuilder

    let delegate: WorkoutListDelegateBuilder
    
    var body: some View {
        List {
            if presenter.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

                if !presenter.favouriteWorkouts.isEmpty {
                    favouriteWorkoutTemplatesSection
                }

                if !presenter.myWorkouts.isEmpty {
                    myWorkoutsSection
                }
                
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
        .navigationSubtitle("\(presenter.workoutsCount) workouts")
        .navigationBarTitleDisplayMode(.inline)
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    presenter.onAddWorkoutPressed()
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.glassProminent)
            }
        }
    }

    // MARK: UI Components
    private var favouriteWorkoutTemplatesSection: some View {
        Section {
            ForEach(presenter.favouriteWorkouts) { workout in
                workoutRow(workout)
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
                workoutRow(workout)
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
                workoutRow(workout)
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
                    workoutRow(workout)
                }
            }
        } header: {
            Text("My Templates")
        }
        .onAppear {
            presenter.myTemplatesSectionViewed()
        }
    }
    
    private func workoutRow(_ workout: WorkoutTemplateModel) -> some View {
        let subtitle = workout.exercises.map { "\($0.exercise.name)"}.joined(separator: ", ")
        return CustomListCellView(
            imageName: workout.imageURL,
            title: workout.name,
            subtitle: subtitle
        )
        .anyButton(.highlight) {
            presenter.onWorkoutPressedFromMyTemplates(workout: workout, onWorkoutPressed: delegate.onWorkoutSelectionChanged)
        }
        .removeListRowFormatting()
    }
    
    private var systemWorkoutTemplatesSection: some View {
        Section {
            ForEach(presenter.systemWorkouts) { workout in
                workoutRow(workout)
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

extension CoreBuilder {
    func workoutListViewBuilder(router: AnyRouter, delegate: WorkoutListDelegateBuilder) -> some View {
        WorkoutListViewBuilder(
            presenter: WorkoutListPresenterBuilder(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
}

#Preview {
    let container = DevPreview.shared.container()
    RouterView { router in
        WorkoutListViewBuilder(
            presenter: WorkoutListPresenterBuilder(
                interactor: CoreInteractor(container: container),
                router: CoreRouter(
                    router: router,
                    builder: CoreBuilder(container: container)
                )
            ),
            delegate: WorkoutListDelegateBuilder(
                onWorkoutSelectionChanged: { template in
                    print(
                        template.name
                    )
                }
            )
        )
    }
    .previewEnvironment()
}
