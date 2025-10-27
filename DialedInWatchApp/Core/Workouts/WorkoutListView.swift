//
//  WorkoutListView.swift
//  DialedInWatchApp
//
//  Created by AI Assistant on 25/10/2025.
//

import SwiftUI

struct WorkoutListView: View {
    @State private var selectedTemplateId: String?
    
    var body: some View {
        NavigationStack {
            List(WorkoutTemplateModel.mocks) { template in
                NavigationLink {
                    WorkoutDetailView(template: template)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(template.name)
                            .font(.headline)
                        
                        if let description = template.description {
                            Text(description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        
                        Text("\(template.exercises.count) exercises")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Workouts")
//            .overlay {
//                if dependencies.templateStore.templates.isEmpty {
//                    VStack(spacing: 8) {
//                        Image(systemName: "fitness.app")
//                            .font(.system(size: 40))
//                            .foregroundStyle(.secondary)
//                        
//                        Text("No workouts")
//                            .font(.headline)
//                            .foregroundStyle(.secondary)
//                        
//                        Text("Sync from iPhone")
//                            .font(.caption)
//                            .foregroundStyle(.tertiary)
//                    }
//                }
//            }
        }
    }
}

#Preview {
    WorkoutListView()
}


