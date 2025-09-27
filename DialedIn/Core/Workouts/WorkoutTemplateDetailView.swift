//
//  WorkoutTemplateDetailView.swift
//  DialedIn
//
//  Created by AI Assistant on 23/09/2025.
//

import SwiftUI

struct WorkoutTemplateDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let workout: WorkoutTemplateModel
    @State private var showStartSessionSheet: Bool = false
    
    var body: some View {
        List {
            if let url = workout.imageURL {
                imageSection(url: url)
            }

            Section(header: Text("Exercises")) {
                ForEach(workout.exercises) { exercise in
                    exerciseSection(exercise: exercise)
                }
            }
        }
        .navigationTitle(workout.name)
        .navigationSubtitle(workout.description ?? "")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showStartSessionSheet = true
                } label: {
                    Label("Start", systemImage: "play.fill")
                }
                .buttonStyle(.glassProminent)
            }
        }
        .sheet(isPresented: $showStartSessionSheet) {
            WorkoutStartView(template: workout)
        }
    }
    
    private func imageSection(url: String) -> some View {
        Section {
            ImageLoaderView(urlString: url, resizingMode: .fill)
                .frame(maxWidth: .infinity, minHeight: 180)
        }
        .removeListRowFormatting()
    }
    
    private func exerciseSection(exercise: ExerciseTemplateModel) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(exercise.name)
                    .fontWeight(.semibold)
                Spacer()
                Text(exercise.type.description)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            if let notes = exercise.description, !notes.isEmpty {
                Text(notes)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        WorkoutTemplateDetailView(workout: WorkoutTemplateModel.mock)
    }
    .previewEnvironment()
}
