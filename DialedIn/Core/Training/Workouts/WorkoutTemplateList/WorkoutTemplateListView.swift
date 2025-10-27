//
//  WorkoutTemplateListView.swift
//  DialedIn
//
//  Created by AI Assistant on 23/09/2025.
//

import SwiftUI

struct WorkoutTemplateListView: View {
    @Environment(\.dismiss) private var dismiss

    @State var viewModel: WorkoutTemplateListViewModel
    
    let templateIds: [String]?
    @State private var path: [NavigationPathOption] = []

    init(viewModel: WorkoutTemplateListViewModel, templateIds: [String]? = nil) {
        self.viewModel = viewModel
        self.templateIds = templateIds
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.templates.isEmpty {
                    ContentUnavailableView(
                        "No Workouts",
                        systemImage: "figure.run",
                        description: Text(templateIds != nil ? "You haven't created any workout templates yet." : "No workout templates available.")
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
                                path.append(.workoutTemplateDetail(template: template))
                            }
                            .removeListRowFormatting()
                        }
                    }
                }
            }
            .navigationTitle(templateIds != nil ? "My Workouts" : "Workout Templates")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: { Image(systemName: "chevron.left") }
                }
            }
            .task { await viewModel.loadTemplates(templateIds: templateIds ?? []) }
            .showCustomAlert(alert: $viewModel.showAlert)
            .navigationDestinationForCoreModule(path: $path)
        }
    }
}
 
#Preview {
    WorkoutTemplateListView(viewModel: WorkoutTemplateListViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
        .previewEnvironment()
}
