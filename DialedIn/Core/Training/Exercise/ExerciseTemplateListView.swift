//
//  ExerciseTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI

struct ExerciseTemplateListView: View {
    @Environment(ExerciseTemplateManager.self) private var exerciseTemplateManager
    @Environment(\.dismiss) private var dismiss
    
    let templateIds: [String]
    @State private var templates: [ExerciseTemplateModel] = []
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
                        "No Exercises",
                        systemImage: "figure.strengthtraining.traditional",
                        description: Text("You haven't created any exercise templates yet.")
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
                                path.append(.exerciseTemplate(exerciseTemplate: template))
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
            .task { await loadTemplates() }
            .showCustomAlert(alert: $showAlert)
            .navigationDestinationForCoreModule(path: $path)
        }
    }
}

extension ExerciseTemplateListView {
    private func loadTemplates() async {
        guard !templateIds.isEmpty else { return }
        isLoading = true
        
        do {
            let fetchedTemplates = try await exerciseTemplateManager.getExerciseTemplates(ids: templateIds, limitTo: templateIds.count)
            templates = fetchedTemplates.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        } catch {
            showAlert = AnyAppAlert(
                title: "Unable to load exercises",
                subtitle: "Please check your internet connection and try again."
            )
        }
        
        isLoading = false
    }
}

#Preview {
    ExerciseTemplateListView(templateIds: [])
        .previewEnvironment()
}
