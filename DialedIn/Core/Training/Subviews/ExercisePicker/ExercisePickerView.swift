//
//  ExercisePickerView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

struct ExercisePickerDelegate {
    let selectedExercises: Binding<[ExerciseModel]>
}

struct ExercisePickerView: View {

    @State var presenter: ExercisePickerPresenter

    var delegate: ExercisePickerDelegate

    var body: some View {
        Group {
            if presenter.isLoading {
                progressSection
            } else if let errorMessage = presenter.errorMessage {
                errorSection(errorMessage: errorMessage)
            } else {
                listSection
            }
        }
        .searchable(text: $presenter.searchText)
        .navigationTitle("Add Exercises")
        .navigationSubtitle("Select one or more exercises to add")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    presenter.dismissScreen()
                } label: {
                    Image(systemName: "xmark")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    presenter.onAddExercisePressed()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }

    private var progressSection: some View {
        VStack {
            ProgressView()
            Text("Loading exercises...")
                .foregroundStyle(.secondary)
        }
    }

    private func errorSection(errorMessage: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text("Error Loading Exercises")
                .font(.headline)
            Text(errorMessage)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Try Again") {
                // TODO: Solve case where exercises dont load
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var listSection: some View {
        List {
            ForEach(presenter.filteredExercises) { exercise in
                CustomListCellView(
                    imageName: exercise.imageURL,
                    title: exercise.name,
                    subtitle: exercise.description,
                    isSelected: delegate.selectedExercises.wrappedValue.contains(
                        where: {
                            $0.id == exercise.id
                        })
                )
                    .anyButton {
                        presenter.onExercisePressed(exercise: exercise, selectedExercises: delegate.selectedExercises)
                    }
                    .removeListRowFormatting()
            }
        }
        .scrollIndicators(.hidden)
    }
}

extension CoreBuilder {
    func exercisePickerView(router: AnyRouter, delegate: ExercisePickerDelegate) -> some View {
        ExercisePickerView(
            presenter: ExercisePickerPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showExercisePickerView(delegate: ExercisePickerDelegate) {
        router.showScreen(.sheet) { router in
            builder.exercisePickerView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    @Previewable @State var selectedExercises: [ExerciseModel] = [ExerciseModel.mock]
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = ExercisePickerDelegate(selectedExercises: $selectedExercises)
    RouterView { router in
        builder.exercisePickerView(router: router, delegate: delegate)
    }
    
}
