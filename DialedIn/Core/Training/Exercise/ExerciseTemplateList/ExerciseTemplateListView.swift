//
//  ExerciseTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI

struct ExerciseTemplateListView: View {
    @State var viewModel: ExerciseTemplateListViewModel
    @Environment(ExerciseTemplateManager.self) private var exerciseTemplateManager
    @Environment(\.dismiss) private var dismiss
    
    let templateIds: [String]
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.templates.isEmpty {
                    ContentUnavailableView(
                        "No Exercises",
                        systemImage: "figure.strengthtraining.traditional",
                        description: Text("You haven't created any exercise templates yet.")
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
                                viewModel.path.append(.exerciseTemplate(exerciseTemplate: template))
                            }
                            .removeListRowFormatting()
                        }
                    }
                }
            }
            .navigationTitle("My Exercises")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: { Image(systemName: "chevron.left") }
                }
            }
            .task { await viewModel.loadTemplates(templateIds: templateIds) }
            .showCustomAlert(alert: $viewModel.showAlert)
            .navigationDestinationForCoreModule(path: $viewModel.path)
        }
    }
}

#Preview {
    ExerciseTemplateListView(viewModel: ExerciseTemplateListViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), templateIds: [])
        .previewEnvironment()
}
