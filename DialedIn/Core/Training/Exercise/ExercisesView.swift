//
//  ExercisesView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI

struct ExercisesView: View {
    @Environment(CoreBuilder.self) private var builder
    @Environment(\.layoutMode) private var layoutMode
    @State var viewModel: ExercisesViewModel
    
    var body: some View {
        List {
            if viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

                if !viewModel.favouriteExercises.isEmpty {
                    favouriteExerciseTemplatesSection
                }

                myExercisesSection
                
                if !viewModel.officialExercisesVisible.isEmpty {
                    officialExercisesSection
                }

                if !viewModel.bookmarkedOnlyExercises.isEmpty {
                    bookmarkedExerciseTemplatesSection
                }

                if !viewModel.trendingExercisesDeduped.isEmpty {
                    exerciseTemplateSection
                }
            } else {
                // Show search results when there is a query
                exerciseTemplateSection
            }
        }
        .screenAppearAnalytics(name: "ExercisesView")
        .navigationTitle("Exercises")
        .navigationSubtitle("\(viewModel.exercises.count) exercises")
        .navigationBarTitleDisplayMode(.large)
        .scrollIndicators(.hidden)
        .onFirstTask {
            await viewModel.loadMyExercisesIfNeeded()
            await viewModel.loadOfficialExercises()
            await viewModel.loadTopExercisesIfNeeded()
            await viewModel.syncSavedExercisesFromUser()
        }
        .refreshable {
            await viewModel.loadMyExercisesIfNeeded()
            await viewModel.loadOfficialExercises()
            await viewModel.loadTopExercisesIfNeeded()
            await viewModel.syncSavedExercisesFromUser()
        }
        .onChange(of: viewModel.currentUser) {
            Task {
                await viewModel.syncSavedExercisesFromUser()
            }
        }
        .sheet(isPresented: $viewModel.showCreateExercise) {
            builder.createExerciseView()
        }
    }
    
    private var favouriteExerciseTemplatesSection: some View {
        Section {
            ForEach(viewModel.favouriteExercises) { exercise in
                CustomListCellView(
                    imageName: exercise.imageURL,
                    title: exercise.name,
                    subtitle: exercise.description
                )
                .anyButton(.highlight) {
                    viewModel.onExercisePressed(exercise: exercise)
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

    private var bookmarkedExerciseTemplatesSection: some View {
        Section {
            ForEach(viewModel.bookmarkedOnlyExercises) { exercise in
                CustomListCellView(
                    imageName: exercise.imageURL,
                    title: exercise.name,
                    subtitle: exercise.description
                )
                .anyButton(.highlight) {
                    viewModel.onExercisePressed(exercise: exercise)
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

    private var exerciseTemplateSection: some View {
        Section {
            if viewModel.isLoading {
                HStack {
                    ProgressView()
                    Text("Loading...")
                }
                .foregroundStyle(Color.secondary)
                .removeListRowFormatting()
            }
            ForEach(viewModel.visibleExerciseTemplates) { exercise in
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
                    viewModel.onExercisePressed(exercise: exercise)
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

    private var myExercisesSection: some View {
        Section {
            if viewModel.myExercisesVisible.isEmpty {
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
                    viewModel.emptyStateShown()
                }
            } else {
                ForEach(viewModel.myExercisesVisible) { exercise in
                    CustomListCellView(
                        imageName: exercise.imageURL,
                        title: exercise.name,
                        subtitle: exercise.description
                    )
                    .anyButton(.highlight) {
                        viewModel.onExercisePressed(exercise: exercise)
                    }
                    .removeListRowFormatting()
                }
            }
        } header: {
            HStack {
                Text("My Templates")
                Spacer()
                Button {
                    viewModel.showCreateExercise = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                }
            }
        }
        .onAppear {
            viewModel.myTemplatesViewed()
        }
    }
    
    private var officialExercisesSection: some View {
        Section {
            ForEach(viewModel.officialExercisesVisible) { exercise in
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
                    viewModel.onExercisePressed(exercise: exercise)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Official Exercises")
        }
        .onAppear {
            viewModel.officialSectionViewed()
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    NavigationStack {
        builder.exercisesView()
    }
    .previewEnvironment()
}
