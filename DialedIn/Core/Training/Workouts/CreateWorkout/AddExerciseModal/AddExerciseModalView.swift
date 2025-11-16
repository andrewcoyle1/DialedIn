//
//  AddExerciseModalView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

struct AddExerciseModalViewDelegate {
    let selectedExercises: Binding<[ExerciseTemplateModel]>
}

struct AddExerciseModalView: View {

    @Environment(\.dismiss) private var dismiss

    @State var viewModel: AddExerciseModalViewModel

    var delegate: AddExerciseModalViewDelegate

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    progressSection
                } else if let errorMessage = viewModel.errorMessage {
                    errorSection(errorMessage: errorMessage)
                } else {
                    listSection
                }
            }
            .searchable(text: $viewModel.searchText)
            .navigationTitle("Add Exercises")
            .navigationSubtitle("Select one or more exercises to add")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .task {
                await viewModel.loadExercises()
            }
            .onChange(of: viewModel.searchText) {
                Task {
                    await viewModel.searchExercises()
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
                Task {
                    await viewModel.loadExercises()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var listSection: some View {
        List {
            ForEach(viewModel.filteredExercises) { exercise in
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
                        viewModel.onExercisePressed(exercise: exercise, selectedExercises: delegate.selectedExercises)
                    }
                    .removeListRowFormatting()
            }
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    @Previewable @State var showModal: Bool = true
    @Previewable @State var selectedExercises: [ExerciseTemplateModel] = [ExerciseTemplateModel.mock]
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = AddExerciseModalViewDelegate(selectedExercises: $selectedExercises)
    Button("Show Modal") {
        showModal = true
    }
    .sheet(isPresented: $showModal) {
        builder.addExerciseModalView(delegate: delegate)
    }
    .previewEnvironment()
}
