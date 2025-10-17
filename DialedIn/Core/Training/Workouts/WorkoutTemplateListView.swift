//
//  WorkoutTemplateListView.swift
//  DialedIn
//
//  Created by AI Assistant on 23/09/2025.
//

import SwiftUI

struct WorkoutTemplateListView: View {
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager
    @Environment(\.dismiss) private var dismiss
    
    let templateIds: [String]?
    @State private var templates: [WorkoutTemplateModel] = []
    @State private var path: [NavigationPathOption] = []
    @State private var isLoading: Bool = false
    @State private var showAlert: AnyAppAlert?
    
    init(templateIds: [String]? = nil) {
        self.templateIds = templateIds
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if isLoading {
                    ProgressView()
                } else if templates.isEmpty {
                    ContentUnavailableView(
                        "No Workouts",
                        systemImage: "figure.run",
                        description: Text(templateIds != nil ? "You haven't created any workout templates yet." : "No workout templates available.")
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
            .task { await loadTemplates() }
            .showCustomAlert(alert: $showAlert)
            .navigationDestinationForCoreModule(path: $path)
        }
    }
}
 
#Preview {
    WorkoutTemplateListView()
        .previewEnvironment()
}

extension WorkoutTemplateListView {
    private func loadTemplates() async {
        isLoading = true
        
        do {
            if let templateIds = templateIds {
                // Load user's specific templates
                guard !templateIds.isEmpty else {
                    isLoading = false
                    return
                }
                let fetchedTemplates = try await workoutTemplateManager.getWorkoutTemplates(ids: templateIds, limitTo: templateIds.count)
                templates = fetchedTemplates.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            } else {
                // Load top templates
                let top = try await workoutTemplateManager.getTopWorkoutTemplatesByClicks(limitTo: 20)
                templates = top
            }
        } catch {
            showAlert = AnyAppAlert(title: "Unable to Load Workouts", subtitle: "Please try again later.")
        }
        
        isLoading = false
    }
}
