//
//  SearchView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

struct SearchView: View {

    @Environment(\.colorScheme) private var colorScheme
    @State var presenter: SearchPresenter

    var body: some View {
        List {
            if !presenter.hasSearchQuery {
                quickActionsGridSection
            } else {
                if presenter.isLoading {
                    loadingSection
                } else if presenter.hasResults {
                    usersSection
                    exercisesSection
                    workoutsSection
                    recipesSection
                    ingredientsSection
                } else {
                    emptyResultsSection
                }
            }
        }
        .listSectionMargins(.horizontal, 0)
        .listRowSeparator(.hidden)
        .navigationTitle("Quick Actions")
        .toolbarRole(.browser)
        .toolbarTitleDisplayMode(.inlineLarge)
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

    @ViewBuilder
    private var quickActionsGridSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                QuickActionButton(
                    title: "Start Workout",
                    systemImage: "play.circle.fill"
                )
                .anyButton {
                    presenter.onStartWorkoutPressed()
                }
                
                QuickActionButton(
                    title: "Add Exercise",
                    systemImage: "plus.circle.fill"
                )
                .anyButton {
                    presenter.onAddExercisePressed()
                }
                
                QuickActionButton(
                    title: "Log Meal",
                    systemImage: "fork.knife"
                )
                .anyButton {
                    presenter.onLogMealPressed()
                }
                
                QuickActionButton(
                    title: "Log Weight",
                    systemImage: "scalemass"
                )
                .anyButton {
                    presenter.onLogWeightPressed()
                }
            }
            .removeListRowFormatting()
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

    @ViewBuilder
    private var usersSection: some View {
        if !presenter.filteredUsers.isEmpty {
            Section {
                ForEach(presenter.filteredUsers) { user in
                    UserSearchRow(
                        user: user,
                        isFollowing: presenter.isFollowing(userId: user.userId),
                        onFollowPressed: { presenter.onFollowPressed(user: user) },
                        onUnfollowPressed: { presenter.onUnfollowPressed(user: user) }
                    )
                    .removeListRowFormatting()
                }
            } header: {
                Text("People")
            }
        }
    }

    @ViewBuilder
    private var exercisesSection: some View {
        if !presenter.filteredExercises.isEmpty {
            searchItemSection(
                header: "Exercises",
                items: presenter.filteredExercises,
                action: { item in
                    guard let item = item as? ExerciseModel else { return }
                    presenter.onExercisePressed(exercise: item)
                }
            )
        }
    }

    @ViewBuilder
    private var workoutsSection: some View {
        if !presenter.filteredWorkoutTemplates.isEmpty {
            Section {
                ForEach(presenter.filteredWorkoutTemplates) { workout in
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
    }

    @ViewBuilder
    private var recipesSection: some View {
        if !presenter.filteredRecipeTemplates.isEmpty {
            Section {
                ForEach(presenter.filteredRecipeTemplates) { recipe in
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
    }

    @ViewBuilder
    private var ingredientsSection: some View {
        if !presenter.filteredFoods.isEmpty {
            searchItemSection(
                header: "Ingredients",
                items: presenter.filteredFoods,
                action: { item in
                    guard let item = item as? FoodModel else { return }
                    presenter.onIngredientPressed(ingredient: item)
                }
            )
        }
    }
    
    @ViewBuilder
    private func searchItemSection(header: String, items: [any SearchListItem], action: @escaping (any SearchListItem) -> Void) -> some View {
        Section {
            ForEach(items, id: \.id) { item in
                CustomListCellView(
                    imageName: item.imageURL,
                    title: item.name,
                    subtitle: item.description
                )
                .anyButton(.highlight) {
                    action(item)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Ingredients")
        }

    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onProfilePressed()
            } label: {
                if let urlString = presenter.userImageUrl {
                    ImageLoaderView(urlString: urlString)
                        .frame(minWidth: 44, maxWidth: .infinity, minHeight: 44, maxHeight: .infinity)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person")
                }
            }
        }
        .sharedBackgroundVisibility(.hidden)
    }
}

protocol SearchListItem: Identifiable {
    var id: String { get }
    var name: String { get }
    var description: String? { get }
    var imageURL: String? { get }
}

private struct UserSearchRow: View {

    let user: UserModel
    let isFollowing: Bool
    let onFollowPressed: () -> Void
    let onUnfollowPressed: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            if let imageUrl = user.profileImageNameCalculated {
                ImageLoaderView(urlString: imageUrl)
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(user.fullNameCalculated ?? user.firstNameCalculated ?? "Unknown")
                    .font(.body.weight(.medium))
            }

            Spacer(minLength: 0)

            Button {
                if isFollowing {
                    onUnfollowPressed()
                } else {
                    onFollowPressed()
                }
            } label: {
                Text(isFollowing ? "Following" : "Follow")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(isFollowing ? Color(.secondarySystemBackground) : Color.accentColor)
                    .foregroundStyle(isFollowing ? Color.primary : Color.white)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }
}

private struct QuickActionButton: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    let title: String
    let systemImage: String
    
    var body: some View {
            Label(title, systemImage: systemImage)
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(colorScheme.backgroundPrimary, in: .containerRelative)
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
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)

    RouterView { router in
        builder.searchView(router: router)
    }
}
