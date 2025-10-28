//
//  WorkoutPickerSheet.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/10/2025.
//

import SwiftUI

struct WorkoutPickerSheet: View {

    @State var viewModel: WorkoutPickerSheetViewModel
    
    var body: some View {
        List {
            if viewModel.isLoading {
                Section { ProgressView().frame(maxWidth: .infinity) }
            }
            if !viewModel.userResults.isEmpty {
                Section {
                    ForEach(viewModel.userResults, id: \.id) { workout in
                        Button { viewModel.onSelect(workout) } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(workout.name).font(.body)
                                if let desc = workout.description, !desc.isEmpty {
                                    Text(desc).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Your Workouts")
                }
            }
            if !viewModel.officialResults.isEmpty {
                Section {
                    ForEach(viewModel.officialResults, id: \.id) { workout in
                        Button { viewModel.onSelect(workout) } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(workout.name).font(.body)
                                if let desc = workout.description, !desc.isEmpty {
                                    Text(desc).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Official Workouts")
                }
            }
            if !viewModel.isLoading && viewModel.userResults.isEmpty && viewModel.officialResults.isEmpty {
                Section {
                    Text("No workouts found")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Select Workout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel", action: viewModel.onCancel) }
        }
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
        .onSubmit(of: .search) {
            Task { await viewModel.runSearch() }
        }
        .task {
            await viewModel.loadTopWorkouts()
        }
        .showCustomAlert(alert: $viewModel.error)
    }
}

#Preview {
    WorkoutPickerSheet(
        viewModel: WorkoutPickerSheetViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            ),
            onSelect: { template in
                print(
                    template.name
                )
            },
            onCancel: {
                print(
                    "Cancel"
                )
            }
        )
    )
}
