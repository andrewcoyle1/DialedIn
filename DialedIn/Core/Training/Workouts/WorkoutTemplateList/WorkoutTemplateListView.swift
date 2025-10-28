//
//  WorkoutTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI

struct WorkoutTemplateListView: View {
    @State var viewModel: WorkoutTemplateListViewModel
    @Environment(\.dismiss) private var dismiss
        
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.templates.isEmpty {
                    ContentUnavailableView(
                        "No Workouts",
                        systemImage: "figure.run",
                        description: Text(viewModel.templateIds != nil ? "You haven't created any workout templates yet." : "No workout templates available.")
                    )
                } else {
                    List {
                        ForEach(viewModel.templates) { template in
                            CustomListCellView(
                                imageName: template.imageURL,
                                title: template.name,
                                subtitle: template.description
                            )
                            .anyButton(.highlight) {
                                viewModel.path.append(.workoutTemplateDetail(template: template))
                            }
                            .removeListRowFormatting()
                        }
                    }
                }
            }
            .navigationTitle(viewModel.templateIds != nil ? "My Workouts" : "Workout Templates")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
            }
            .task {
                await viewModel.loadTemplates(
                    templateIds: viewModel.templateIds ?? []
                )
            }
            .showCustomAlert(alert: $viewModel.showAlert)
            .navigationDestinationForCoreModule(path: $viewModel.path)
        }
    }
}
 
#Preview {
    WorkoutTemplateListView(
        viewModel: WorkoutTemplateListViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            ),
            templateIds: []
        )
    )
}
