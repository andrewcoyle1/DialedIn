//
//  RecipeTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI

struct RecipeTemplateListView: View {
    @Environment(RecipeTemplateManager.self) private var recipeTemplateManager
    @Environment(\.dismiss) private var dismiss
    
    let templateIds: [String]
    @State private var templates: [RecipeTemplateModel] = []
    @State private var path: [NavigationPathOption] = []
    @State private var isLoading: Bool = false
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if isLoading {
                    ProgressView()
                } else if templates.isEmpty {
                    ContentUnavailableView(
                        "No Recipes",
                        systemImage: "fork.knife",
                        description: Text("You haven't created any recipe templates yet.")
                    )
                    .removeListRowFormatting()
                } else {
                    ForEach(templates) { template in
                        CustomListCellView(
                            imageName: template.imageURL,
                            title: template.name,
                            subtitle: template.description
                        )
                        .anyButton(.highlight) {
                            path.append(.recipeTemplateDetail(template: template))
                        }
                        .removeListRowFormatting()
                    }
                }
            }
            .navigationTitle("My Recipes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: { Image(systemName: "chevron.left") }
                }
            }
            .task { await loadTemplates() }
            .refreshable {
                await loadTemplates()
            }
            .showCustomAlert(alert: $showAlert)
            .navigationDestinationForCoreModule(path: $path)
        }
    }
}

extension RecipeTemplateListView {
    private func loadTemplates() async {
        guard !templateIds.isEmpty else { return }
        isLoading = true
        
        do {
            let fetchedTemplates = try await recipeTemplateManager.getRecipeTemplates(ids: templateIds, limitTo: templateIds.count)
            templates = fetchedTemplates.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        } catch {
            showAlert = AnyAppAlert(
                title: "Unable to load recipes",
                subtitle: "Please check your internet connection and try again."
            )
        }
        
        isLoading = false
    }
}

#Preview {
    RecipeTemplateListView(templateIds: [])
        .previewEnvironment()
}
