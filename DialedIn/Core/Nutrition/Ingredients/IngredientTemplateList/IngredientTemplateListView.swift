//
//  IngredientTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI

struct IngredientTemplateListView: View {
    @State var viewModel: IngredientTemplateListViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            List {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.templates.isEmpty {
                    ContentUnavailableView(
                        "No Ingredients",
                        systemImage: "carrot",
                        description: Text("You haven't created any ingredient templates yet.")
                    )
                    .removeListRowFormatting()
                } else {
                    ForEach(viewModel.templates) { template in
                        CustomListCellView(
                            imageName: template.imageURL,
                            title: template.name,
                            subtitle: template.description
                        )
                        .anyButton(.highlight) {
                            viewModel.path.append(.ingredientTemplateDetail(template: template))
                        }
                        .removeListRowFormatting()
                    }
                }
            }
            .navigationTitle("My Ingredients")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: { Image(systemName: "chevron.left") }
                }
            }
            .task { await viewModel.loadTemplates() }
            .refreshable {
                await viewModel.loadTemplates()
            }
            .showCustomAlert(alert: $viewModel.showAlert)
            .navigationDestinationForCoreModule(path: $viewModel.path)
        }
    }
}

#Preview {
    IngredientTemplateListView(viewModel: IngredientTemplateListViewModel(interactor: CoreInteractor(container: DevPreview.shared.container), templateIds: []))
}
