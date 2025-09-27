//
//  WorkoutSessionReviewView.swift
//  DialedIn
//
//  Created by AI Assistant on 23/09/2025.
//

import SwiftUI

struct WorkoutSessionReviewView: View {
    @Environment(\.dismiss) private var dismiss
    let session: WorkoutSessionModel
    
    var body: some View {
        NavigationStack {
            List {
                if let notes = session.notes, !notes.isEmpty {
                    Section(header: Text("Notes")) { Text(notes) }
                }
                Section(header: Text("Exercises")) {
                    ForEach(session.exercises) { exercise in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(exercise.name)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(modeText(exercise.trackingMode))
                                    .foregroundColor(.secondary)
                                    .font(.footnote)
                            }
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(exercise.sets) { set in
                                        Text(setSummary(set, mode: exercise.trackingMode))
                                            .font(.footnote)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.accentColor.opacity(0.12))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Review Session")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Label("Start", systemImage: "checkmark")
                    }
                    .buttonStyle(.glassProminent)
                }
            }
        }
    }
    
    private func modeText(_ mode: TrackingMode) -> String {
        switch mode {
        case .weightReps: return "Weight + Reps"
        case .repsOnly: return "Reps Only"
        case .timeOnly: return "Time Only"
        case .distanceTime: return "Distance + Time"
        }
    }
    
    private func setSummary(_ set: WorkoutSetModel, mode: TrackingMode) -> String {
        switch mode {
        case .weightReps:
            return "x\(set.reps ?? 0) @ \(Int(set.weightKg ?? 0))kg"
        case .repsOnly:
            return "x\(set.reps ?? 0)"
        case .timeOnly:
            return "\(set.durationSec ?? 0)s"
        case .distanceTime:
            return "\(Int(set.distanceMeters ?? 0))m / \(set.durationSec ?? 0)s"
        }
    }
}

#Preview {
    WorkoutSessionReviewView(session: WorkoutSessionModel.mock)
}
