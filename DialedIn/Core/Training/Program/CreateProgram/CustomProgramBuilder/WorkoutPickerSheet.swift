//
//  WorkoutPickerSheet.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/10/2025.
//

import SwiftUI

protocol WorkoutPickerSheetInteractor {
    var auth: UserAuthInfo? { get }
    func getWorkoutTemplatesByName(name: String) async throws -> [WorkoutTemplateModel]
    func getTopWorkoutTemplatesByClicks(limitTo: Int) async throws -> [WorkoutTemplateModel]
    func getWorkoutTemplatesForAuthor(authorId: String) async throws -> [WorkoutTemplateModel]
    func getAllLocalWorkoutTemplates() throws -> [WorkoutTemplateModel]
}

extension CoreInteractor: WorkoutPickerSheetInteractor { }

@Observable
@MainActor
class WorkoutPickerSheetViewModel {
    private let interactor: WorkoutPickerSheetInteractor

    let onSelect: (WorkoutTemplateModel) -> Void
    let onCancel: () -> Void

    var searchText: String = ""
    var officialResults: [WorkoutTemplateModel] = []
    var userResults: [WorkoutTemplateModel] = []
    var isLoading: Bool = false
    var error: AnyAppAlert?

    init(
        interactor: WorkoutPickerSheetInteractor,
        onSelect: @escaping (WorkoutTemplateModel) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.interactor = interactor
        self.onSelect = onSelect
        self.onCancel = onCancel
    }

    func loadTopWorkouts() async {
        isLoading = true
        defer { isLoading = false }
        // Include local and remote workouts
        let localAll = (try? interactor.getAllLocalWorkoutTemplates()) ?? []
        let uid = interactor.auth?.uid
        let remoteTop = (try? await interactor.getTopWorkoutTemplatesByClicks(limitTo: 15)) ?? []
        var remoteUser: [WorkoutTemplateModel] = []
        if let id = uid {
            remoteUser = (try? await interactor.getWorkoutTemplatesForAuthor(authorId: id)) ?? []
        }
        let combined = mergeUnique(localAll + remoteTop + remoteUser)
        userResults = combined.filter { $0.authorId == uid }
        officialResults = combined.filter { $0.authorId != uid }
    }

    func runSearch() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { await loadTopWorkouts(); return }
        isLoading = true
        defer { isLoading = false }
        // Local and remote search
        let localAll = (try? interactor.getAllLocalWorkoutTemplates()) ?? []
        let uid = interactor.auth?.uid
        let localMatches = localAll.filter { tmpl in
            tmpl.name.localizedCaseInsensitiveContains(query)
        }
        let remoteFound = (try? await interactor.getWorkoutTemplatesByName(name: query)) ?? []
        var remoteUser: [WorkoutTemplateModel] = []
        if let id = uid {
            remoteUser = (try? await interactor.getWorkoutTemplatesForAuthor(authorId: id)) ?? []
        }
        let combined = mergeUnique(localMatches + remoteFound + remoteUser)
        userResults = combined.filter { $0.authorId == uid }
        officialResults = combined.filter { $0.authorId != uid }
    }

    func mergeUnique(_ items: [WorkoutTemplateModel]) -> [WorkoutTemplateModel] {
        var seen = Set<String>()
        var merged: [WorkoutTemplateModel] = []
        for item in items where !seen.contains(item.workoutId) {
            seen.insert(item.workoutId)
            merged.append(item)
        }
        return merged
    }
}

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
