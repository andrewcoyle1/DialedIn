//
//  WorkoutTemplateDetailView.swift
//  DialedIn
//
//  Created by AI Assistant on 23/09/2025.
//

import SwiftUI

struct WorkoutTemplateDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let template: WorkoutTemplateModel
    @State private var showStartSessionSheet: Bool = false
    
    var body: some View {
        List {
            
            Section(header: Text("Exercises")) {
                ForEach(template.exercises) { exercise in
                    exerciseSection(exercise: exercise)
                }
            }
        }
        .navigationTitle(template.name)
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
            // In real app, pass actual userId from auth
            let session = WorkoutSession.mock
            WorkoutSessionReviewView(session: session)
        }
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
                /*
            if !exercise.sets.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(exercise.sets, id: \.self) { set in
                            Text(setDescription(set, mode: exercise.trackingMode))
                                .font(.footnote)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.12))
                                .cornerRadius(8)
                        }
                    }
                }
            }
                 */
        }
        .padding(.vertical, 4)
    }
    /*
    private func setDescription(_ set: WorkoutSetTemplate, mode: TrackingMode) -> String {
        switch mode {
        case .weightReps:
            return "x\(set.reps ?? 0) @ \(Int((set.weightKg ?? 0)))kg"
        case .repsOnly:
            return "x\(set.reps ?? 0)"
        case .timeOnly:
            return "\(set.durationSec ?? 0)s"
        case .distanceTime:
            return "\(Int(set.distanceMeters ?? 0))m / \(set.durationSec ?? 0)s"
        }
    }
     */
}

#Preview {
    NavigationStack {
        WorkoutTemplateDetailView(template: WorkoutTemplateModel.mocks[0])
    }
}
