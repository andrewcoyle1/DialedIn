import SwiftUI

struct ExerciseListBuilderView: View {
    
    @State var presenter: ExerciseListBuilderPresenter
    
    let delegate: ExerciseListBuilderDelegate
    
    var body: some View {
        listContents
        .screenAppearAnalytics(name: "ExerciseListBuilderView")
        .navigationTitle("Exercises")
        .navigationSubtitle("\(presenter.exercises.count) exercises")
        .navigationBarTitleDisplayMode(.large)
        .scrollIndicators(.hidden)
        .onFirstTask {
            await presenter.loadExercises()
        }
        .onChange(of: presenter.currentUser) {
            Task {
                await presenter.syncSavedExercisesFromUser()
            }
        }
        .toolbar {
            toolbarContent
        }
    }
    
    private var listContents: some View {
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
        .refreshable {
            await presenter.loadExercises()
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
                    presenter.onExercisePressed(exercise: exercise, onExercisePressed: delegate.onExerciseSelectionChanged)
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
                    presenter.onExercisePressed(exercise: exercise, onExercisePressed: delegate.onExerciseSelectionChanged)
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
                    presenter.onExercisePressed(exercise: exercise, onExercisePressed: delegate.onExerciseSelectionChanged)
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
                        presenter.onExercisePressed(exercise: exercise, onExercisePressed: delegate.onExerciseSelectionChanged)
                    }
                    .removeListRowFormatting()
                }
            }
        } header: {
            Text("My Templates")
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
                    presenter.onExercisePressed(exercise: exercise, onExercisePressed: delegate.onExerciseSelectionChanged)
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
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onAddExercisePressed()
            } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

extension CoreBuilder {
    
    func exerciseListBuilderView(router: Router, delegate: ExerciseListBuilderDelegate) -> some View {
        ExerciseListBuilderView(
            presenter: ExerciseListBuilderPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showExerciseListBuilderView(delegate: ExerciseListBuilderDelegate) {
        router.showScreen(.push) { router in
            builder.exerciseListBuilderView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = ExerciseListBuilderDelegate()
    
    return RouterView { router in
        builder.exerciseListBuilderView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
