import SwiftUI

struct ExerciseListBuilderDelegate {
    var onExerciseSelectionChanged: ((ExerciseModel) -> Void)?
    /// Optional list of exercises that should display as "selected" in the UI.
    /// If `nil`, no selection state is shown.
    var selectedExercises: [ExerciseModel]?
}

struct ExerciseListBuilderView: View {
    
    @State var presenter: ExerciseListBuilderPresenter
    
    let delegate: ExerciseListBuilderDelegate
    
    private func isExerciseSelected(_ exercise: ExerciseModel) -> Bool {
        delegate.selectedExercises?.contains(exercise) ?? false
    }
    
    var body: some View {
        List {
            
            if !presenter.favouriteExercisesVisible.isEmpty {
                favouriteExerciseTemplatesSection
            }

            if !presenter.myExercisesVisible.isEmpty {
                myExercisesSection
            }

            if !presenter.officialExercisesVisible.isEmpty {
                officialExercisesSection
            }

            if !presenter.bookmarkedOnlyExercises.isEmpty {
                bookmarkedExerciseTemplatesSection
            }

            if !presenter.trendingExercisesDeduped.isEmpty || presenter.isLoading {
                exerciseTemplateSection
            }
        }
        .searchable(text: $presenter.searchText, placement: .toolbar, prompt: Text("Search exercises"))
        .refreshable {
            await presenter.loadExercises()
        }
        .scrollIndicators(.hidden)
        .toolbarVisibility(.hidden)
        .screenAppearAnalytics(name: "ExerciseListBuilderView")
        .onFirstTask {
            await presenter.loadExercises()
        }
        .onChange(of: presenter.currentUser) {
            Task {
                await presenter.syncSavedExercisesFromUser()
            }
        }
        .safeAreaInset(edge: .top) {
            filterSection
        }
    }
    
    private var filterSection: some View {
        ScrollView(.horizontal) {
            HStack {
                Image(systemName: "arrow.counterclockwise")
                    .padding(8)
                    .glassEffect(.clear)
                    .anyButton {
                        
                    }
                    .padding(.leading)
                
                Label("Gym", systemImage: "building")
                    .padding(8)
                    .glassEffect(.clear)
                    .anyButton {
                        
                    }

                Label("Type", systemImage: "signpost.right")
                    .padding(8)
                    .glassEffect(.clear)
                    .anyButton {
                        
                    }

                Label("Laterality", systemImage: "arrowshape.left.arrowshape.right")
                    .padding(8)
                    .glassEffect(.clear)
                    .anyButton {
                        
                    }

                Label("Resistance", systemImage: "scalemass")
                    .padding(8)
                    .glassEffect(.clear)
                    .anyButton {
                        
                    }

                Label("Support", systemImage: "bed.double")
                    .padding(8)
                    .glassEffect(.clear)
                    .anyButton {
                        
                    }

                Label("Range of Motion", systemImage: "arrowshape.left.arrowshape.right")
                    .padding(8)
                    .glassEffect(.clear)
                    .anyButton {
                        
                    }

                Label("Stability", systemImage: "camera.metering.center.weighted.average")
                    .padding(8)
                    .glassEffect(.clear)
                    .anyButton {
                        
                    }

                Label("Library", systemImage: "book.closed")
                    .padding(8)
                    .glassEffect(.clear)
                    .anyButton {
                        
                    }
                    .padding(.trailing)

            }
        }
        .scrollIndicators(.hidden)
    }

    private var favouriteExerciseTemplatesSection: some View {
        Section {
            ForEach(presenter.favouriteExercisesVisible) { exercise in
                CustomListCellView(
                    imageName: exercise.imageURL,
                    title: exercise.name,
                    subtitle: exercise.description,
                    isSelected: isExerciseSelected(exercise)
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
                    subtitle: exercise.description,
                    isSelected: isExerciseSelected(exercise)
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
            if presenter.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && presenter.myExercisesVisible.isEmpty {
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
            } else if !presenter.myExercisesVisible.isEmpty {
                ForEach(presenter.myExercisesVisible) { exercise in
                    CustomListCellView(
                        imageName: exercise.imageURL,
                        title: exercise.name,
                        subtitle: exercise.description,
                        isSelected: isExerciseSelected(exercise)
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
