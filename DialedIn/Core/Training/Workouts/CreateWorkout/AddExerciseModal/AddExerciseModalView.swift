//
//  AddExerciseModalView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

struct AddExerciseModalView: View {
    @State var viewModel: AddExerciseModalViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                        Text("Loading exercises...")
                            .foregroundStyle(.secondary)
                    }
                } else if let errorMessage = viewModel.errorMessage {
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
                } else {
                    List {
                        ForEach(viewModel.filteredExercises) { exercise in
                            CustomListCellView(imageName: exercise.imageURL, title: exercise.name, subtitle: exercise.description, isSelected: viewModel.selectedExercises.contains(where: { $0.id == exercise.id }))
                                .anyButton {
                                    viewModel.onExercisePressed(exercise: exercise)
                                }
                                .removeListRowFormatting()
                        }
                    }
                    .scrollIndicators(.hidden)
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
}

#Preview {
    @Previewable @State var showModal: Bool = true
    @Previewable @State var selectedExercises: [ExerciseTemplateModel] = [ExerciseTemplateModel.mock]
    Button("Show Modal") {
        showModal = true
    }
    .sheet(isPresented: $showModal) {
        AddExerciseModalView(
            viewModel: AddExerciseModalViewModel(
                container: DevPreview.shared.container,
                selectedExercises: $selectedExercises
            )
        )
    }
    .previewEnvironment()
}
