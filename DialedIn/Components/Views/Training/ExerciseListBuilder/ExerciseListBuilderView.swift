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
            if presenter.searchText.isEmpty {
                userExercisesSection
                systemExercisesSection
            } else {
                filteredExercisesSection
            }
        }
        .searchable(text: $presenter.searchText, placement: .toolbar, prompt: Text("Search exercises"))
        .scrollIndicators(.hidden)
        .toolbarVisibility(.hidden)
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
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

    private var userExercisesSection: some View {
        Section {
            if !presenter.userExercises.isEmpty {
                ForEach(presenter.userExercises) { exercise in
                    CustomListCellView(
                        imageName: exercise.imageURL,
                        title: exercise.name,
                        subtitle: exercise.description,
                        isSelected: isExerciseSelected(exercise),
                        resizingMode: .fit
                    )
                    .anyButton(.highlight) {
                        delegate.onExerciseSelectionChanged?(exercise)
                    }
                    .removeListRowFormatting()
                }
            } else {
                ContentUnavailableView(
                    "No Custom Exercises",
                    systemImage: "dumbbell",
                    description: Text("You have no custom exercises.")
                )
            }
        } header: {
            HStack {
                Text("Custom Exercises")
            Spacer()
                Button {
                    presenter.onAddExercisePressed()
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
            }
        }
    }

    private var systemExercisesSection: some View {
        Section {
            ForEach(presenter.systemExercises) { exercise in
                CustomListCellView(
                    imageName: exercise.imageURL,
                    title: exercise.name,
                    subtitle: exercise.description,
                    isSelected: isExerciseSelected(exercise),
                    resizingMode: .fit
                )
                .anyButton(.highlight) {
                    delegate.onExerciseSelectionChanged?(exercise)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Official Exercises")
        }
    }

    private var filteredExercisesSection: some View {
        Section {
            ForEach(presenter.filteredExercises) { exercise in
                CustomListCellView(
                    imageName: exercise.imageURL,
                    title: exercise.name,
                    subtitle: exercise.description,
                    isSelected: isExerciseSelected(exercise),
                    resizingMode: .fit
                )
                .anyButton(.highlight) {
                    delegate.onExerciseSelectionChanged?(exercise)
                }
                .removeListRowFormatting()
            }
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
    
    func exerciseListBuilderView(router: AnyRouter, delegate: ExerciseListBuilderDelegate) -> some View {
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
}
