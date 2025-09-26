//
//  WorkoutTemplateListView.swift
//  DialedIn
//
//  Created by AI Assistant on 23/09/2025.
//

import SwiftUI

struct WorkoutTemplateListView: View {
    private let service: WorkoutTemplateProviding = LocalWorkoutTemplateService()
    @State private var templates: [WorkoutTemplateModel] = []
    @Environment(\.dismiss) private var dismiss
    @State private var path: [NavigationPathOption] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            List(templates) { template in
                CustomListCellView(
                    imageName: nil,
                    title: template.name,
                    subtitle: template.notes
                )
                .anyButton(.highlight) {
                    path.append(.workoutTemplateDetail(template: template))
                }
                .removeListRowFormatting()
            }
            .navigationTitle("Workout Templates")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: { Image(systemName: "chevron.left") }
                }
            }
            .onAppear {
                templates = service.fetchTemplates()
            }
            .navigationDestinationForCoreModule(path: $path)
        }
    }
}
 
#Preview {
    WorkoutTemplateListView()
}
