//
//  IngredientTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI

struct IngredientTemplateListView: View {
    @Environment(IngredientTemplateManager.self) private var ingredientTemplateManager
    @Environment(\.dismiss) private var dismiss
    
    let templateIds: [String]
    @State private var templates: [IngredientTemplateModel] = []
    @State private var path: [NavigationPathOption] = []
    @State private var isLoading: Bool = false
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if isLoading {
                    ProgressView()
                } else if templates.isEmpty {
                    ContentUnavailableView(
                        "No Ingredients",
                        systemImage: "carrot",
                        description: Text("You haven't created any ingredient templates yet.")
                    )
                } else {
                    List {
                        ForEach(templates) { template in
                            CustomListCellView(
                                imageName: template.imageURL,
                                title: template.name,
                                subtitle: template.description
                            )
                            .anyButton(.highlight) {
                                path.append(.ingredientTemplateDetail(template: template))
                            }
                            .removeListRowFormatting()
                        }
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
            .task { await loadTemplates() }
            .showCustomAlert(alert: $showAlert)
            .navigationDestinationForCoreModule(path: $path)
        }
    }
}

extension IngredientTemplateListView {
    private func loadTemplates() async {
        guard !templateIds.isEmpty else { return }
        isLoading = true
        
        do {
            let fetchedTemplates = try await ingredientTemplateManager.getIngredientTemplates(ids: templateIds, limitTo: templateIds.count)
            templates = fetchedTemplates.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        } catch {
            showAlert = AnyAppAlert(
                title: "Unable to load ingredients",
                subtitle: "Please check your internet connection and try again."
            )
        }
        
        isLoading = false
    }
}

#Preview {
    IngredientTemplateListView(templateIds: [])
        .previewEnvironment()
}
