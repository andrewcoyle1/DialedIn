//
//  AddExerciseModalView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI
import SwiftfulRouting

struct AddExerciseModalDelegate {
    let selectedExercises: Binding<[ExerciseTemplateModel]>
}

struct AddExerciseModalView: View {

    @State var presenter: AddExerciseModalPresenter

    var delegate: AddExerciseModalDelegate

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
        }
        .task {
            await presenter.loadExercises()
        }
        .onChange(of: presenter.searchText) {
            Task {
                await presenter.searchExercises()
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
                Task {
                    await presenter.loadExercises()
                }
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

#Preview {
    @Previewable @State var selectedExercises: [ExerciseTemplateModel] = [ExerciseTemplateModel.mock]
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = AddExerciseModalDelegate(selectedExercises: $selectedExercises)
    RouterView { router in
        builder.addExerciseModalView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
