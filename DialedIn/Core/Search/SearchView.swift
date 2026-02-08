//
//  SearchView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct SearchView: View {

    @State var presenter: SearchPresenter

    @Namespace private var namespace

    var body: some View {
        List {
            if !presenter.hasSearchQuery {
                recentSearchesSection
            } else {
                if presenter.isLoading {
                    loadingSection
                } else if presenter.hasResults {
                    exercisesSection
                    workoutsSection
                    recipesSection
                } else {
                    emptyResultsSection
                }
            }
        }
        .listSectionMargins(.horizontal, 0)
        .listRowSeparator(.hidden)
        .navigationTitle("Search")
        .safeAreaInset(edge: .top) {
            quickActionsSection
        }
        .searchable(
            text: $presenter.searchString,
            placement: .toolbar,
            prompt: Text("Search exercises, workouts, recipes")
        )
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            toolbarContent
        }
        .onChange(of: presenter.searchString) {
            presenter.performUnifiedSearch()
        }
        .onFirstTask {
            await presenter.loadRecentSearches()
        }
        .scrollIndicators(.hidden)
    }

    private var quickActionsSection: some View {
        Section {
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    quickActionButton(
                        title: "Start Workout",
                        systemImage: "play.circle.fill"
                    ) {
                        presenter.onStartWorkoutPressed()
                    }
                    .glassEffect()
                    .padding(.leading)

                    quickActionButton(
                        title: "Log Meal",
                        systemImage: "fork.knife"
                    ) {
                        presenter.onLogMealPressed()
                    }
                    .glassEffect(.clear)

                    quickActionButton(
                        title: "Add Exercise",
                        systemImage: "plus.circle.fill"
                    ) {
                        presenter.onAddExercisePressed()
                    }
                    .glassEffect(.clear)
                    .padding(.trailing)
                }
            }
            .scrollIndicators(.hidden)
            .removeListRowFormatting()
        }
        .listSectionMargins(.top, 0)
        .listSectionMargins(.bottom, 0)
    }

    private func quickActionButton(
        title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(Capsule())
            .anyButton(.highlight) {
                action()
            }
    }

    private var recentSearchesSection: some View {
        Section {
            if presenter.recentQueries.isEmpty {
                Text("No recent searches")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
                    .removeListRowFormatting()
            } else {
                ForEach(presenter.recentQueries, id: \.self) { query in
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundStyle(.secondary)
                            .frame(width: 24)
                        Text(query)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .anyButton(.highlight) {
                        presenter.onRecentSearchTapped(query: query)
                    }
                    .removeListRowFormatting()
                }
            }
        } header: {
            HStack {
                Text("Recent Searches")
                Spacer()
                if !presenter.recentQueries.isEmpty {
                    Button("Clear") {
                        presenter.onClearRecentSearchesPressed()
                    }
                    .font(.caption)
                }
            }
        }
    }

    private var loadingSection: some View {
        Section {
            HStack {
                ProgressView()
                Text("Searching...")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 24)
            .removeListRowFormatting()
        }
    }

    private var emptyResultsSection: some View {
        Section {
            VStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
                Text("No results found")
                    .font(.headline)
                Text("Try a different search term")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .removeListRowFormatting()
        }
    }

    private var exercisesSection: some View {
        Section {
            ForEach(presenter.exercises) { exercise in
                CustomListCellView(
                    imageName: exercise.imageURL,
                    title: exercise.name,
                    subtitle: exercise.description
                )
                .anyButton(.highlight) {
                    presenter.onExercisePressed(exercise: exercise)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Exercises")
        }
    }

    private var workoutsSection: some View {
        Section {
            ForEach(presenter.workouts) { workout in
                let subtitle = workout.exercises.map { $0.exercise.name }.joined(separator: ", ")
                CustomListCellView(
                    imageName: workout.imageURL,
                    title: workout.name,
                    subtitle: subtitle.isEmpty ? nil : subtitle
                )
                .anyButton(.highlight) {
                    presenter.onWorkoutPressed(workout: workout)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Workouts")
        }
    }

    private var recipesSection: some View {
        Section {
            ForEach(presenter.recipes) { recipe in
                CustomListCellView(
                    imageName: recipe.imageURL,
                    title: recipe.name,
                    subtitle: recipe.description
                )
                .anyButton(.highlight) {
                    presenter.onRecipePressed(recipe: recipe)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Recipes")
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onProfilePressed("search-profile-button", in: namespace)
            } label: {
                if let urlString = presenter.userImageUrl {
                    ImageLoaderView(urlString: urlString)
                        .frame(minWidth: 44, maxWidth: .infinity, minHeight: 44, maxHeight: .infinity)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person")
                }
            }
            .matchedTransitionSource(id: "search-profile-button", in: namespace)
        }
        .sharedBackgroundVisibility(.hidden)
    }
}

extension CoreBuilder {
    func searchView(router: AnyRouter) -> some View {
        SearchView(
            presenter: SearchPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())

    RouterView { router in
        builder.searchView(router: router)
    }
}
