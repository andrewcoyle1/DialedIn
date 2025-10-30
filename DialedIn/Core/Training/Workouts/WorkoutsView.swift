//
//  WorkoutsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI

struct WorkoutsView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: WorkoutsViewModel

    var body: some View {
        List {
            if viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

                if !viewModel.favouriteWorkouts.isEmpty {
                    favouriteWorkoutTemplatesSection
                }

                myWorkoutsSection
                
                if !viewModel.systemWorkouts.isEmpty {
                    systemWorkoutTemplatesSection
                }

                if !viewModel.bookmarkedOnlyWorkouts.isEmpty {
                    bookmarkedWorkoutTemplatesSection
                }

                if !viewModel.trendingWorkoutsDeduped.isEmpty {
                    workoutTemplateSection
                }
            } else {
                // Show search results when there is a query
                workoutTemplateSection
            }
        }
        .screenAppearAnalytics(name: "WorkoutsView")
        .navigationTitle("Workouts")
        .navigationSubtitle("\(viewModel.workouts.count) workouts")
        .navigationBarTitleDisplayMode(.large)
        .scrollIndicators(.hidden)
        .onFirstTask {
            await viewModel.loadAllWorkouts()
        }
        .refreshable {
            await viewModel.loadAllWorkouts()
        }
        .onChange(of: viewModel.currentUser) {
            Task {
                await viewModel.syncSavedWorkoutsFromUser()
            }
        }
        .sheet(isPresented: $viewModel.showCreateWorkout) {
            CreateWorkoutView(viewModel: CreateWorkoutViewModel(interactor: CoreInteractor(container: container)))
        }
    }

    // MARK: UI Components
    private var favouriteWorkoutTemplatesSection: some View {
        Section {
            ForEach(viewModel.favouriteWorkouts) { workout in
                CustomListCellView(
                    imageName: workout.imageURL,
                    title: workout.name,
                    subtitle: workout.description
                )
                .anyButton(.highlight) {
                    viewModel.onWorkoutPressed(workout: workout)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Favourites")
        }
        .onAppear {
            viewModel.favouritesSectionViewed()
        }
    }

    private var bookmarkedWorkoutTemplatesSection: some View {
        Section {
            ForEach(viewModel.bookmarkedOnlyWorkouts) { workout in
                CustomListCellView(
                    imageName: workout.imageURL,
                    title: workout.name,
                    subtitle: workout.description
                )
                .anyButton(.highlight) {
                    viewModel.onWorkoutPressed(workout: workout)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Bookmarked")
        }
        .onAppear {
            viewModel.bookmarkedSectionViewed()
        }
    }

    private var workoutTemplateSection: some View {
        Section {
            if viewModel.isLoading {
                HStack {
                    ProgressView()
                    Text("Loading...")
                }
                .foregroundStyle(Color.secondary)
                .removeListRowFormatting()
            }
            ForEach(viewModel.visibleWorkoutTemplates) { workout in
                CustomListCellView(
                    imageName: workout.imageURL,
                    title: workout.name,
                    subtitle: workout.description
                )
                .anyButton(.highlight) {
                    viewModel.onWorkoutPressed(workout: workout)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text(viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Trending Templates" : "Search Results")
        }
        .onAppear {
            viewModel.trendingSectionViewed()
        }
    }

    private var myWorkoutsSection: some View {
        Section {
            if viewModel.myWorkoutsVisible.isEmpty {
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
                    viewModel.emptyStateShown()
                }
            } else {
                ForEach(viewModel.myWorkoutsVisible) { workout in
                    CustomListCellView(
                        imageName: workout.imageURL,
                        title: workout.name,
                        subtitle: workout.description
                    )
                    .anyButton(.highlight) {
                        viewModel.onWorkoutPressed(workout: workout)
                    }
                    .removeListRowFormatting()
                }
            }
        } header: {
            HStack {
                Text("My Templates")
                Spacer()
                Button {
                    viewModel.onAddWorkoutPressed()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                }
            }
        }
        .onAppear {
            viewModel.myTemplatesSectionViewed()
        }
    }
    
    private var systemWorkoutTemplatesSection: some View {
        Section {
            ForEach(viewModel.systemWorkouts) { workout in
                CustomListCellView(
                    imageName: workout.imageURL,
                    title: workout.name,
                    subtitle: workout.description
                )
                .anyButton(.highlight) {
                    viewModel.onWorkoutPressed(workout: workout)
                }
                .removeListRowFormatting()
            }
        } header: {
            HStack {
                Text("Pre-Built Templates")
                Spacer()
                Text("\(viewModel.systemWorkouts.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } footer: {
            Text("Professional workout templates designed for common training programs.")
        }
        .onAppear {
            viewModel.systemTemplatesSectionViewed()
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutsView(
            viewModel: WorkoutsViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            )
        )
    }
    .previewEnvironment()
}
