//
//  WorkoutTemplateListView.swift
//  DialedIn
//
//  Created by AI Assistant on 23/09/2025.
//

import SwiftUI

struct WorkoutTemplateListView: View {
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager
    @State private var templates: [WorkoutTemplateModel] = []
    @Environment(\.dismiss) private var dismiss
    @State private var path: [NavigationPathOption] = []
    @State private var isLoading: Bool = false
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(templates) { template in
                    CustomListCellView(
                        imageName: nil,
                        title: template.name
                    )
                    .anyButton(.highlight) {
                        path.append(.workoutTemplateDetail(template: template))
                    }
                    .removeListRowFormatting()
                }
            }
            .navigationTitle("Workout Templates")
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
            let top = try await workoutTemplateManager.getTopWorkoutTemplatesByClicks(limitTo: 20)
            await MainActor.run {
                templates = top
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                showAlert = AnyAppAlert(title: "Unable to Load Workouts", subtitle: "Please try again later.")
            }
        }
    }
}
