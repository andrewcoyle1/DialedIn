//
//  WorkoutSessionDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle
//

import SwiftUI

struct WorkoutSessionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    let session: WorkoutSessionModel
    
    var body: some View {
        List {
            // Header section
            if let endedAt = session.endedAt {
                headerSection(endedAt: endedAt)
            }
            
            // Summary stats
            summarySection
            
            // Exercises
            exercisesSection
        }
        .navigationTitle(session.name)
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func headerSection(endedAt: Date) -> some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                        Text(session.dateCreated.formatted(date: .long, time: .shortened))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        let duration = endedAt.timeIntervalSince(session.dateCreated)
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                            Text("Duration: \(Date.formatDuration(duration))")
                                .font(.subheadline)
                        }
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.green)
            }
            
            if let notes = session.notes, !notes.isEmpty {
                Text(notes)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        } header: {
            Text("Workout Summary")
        }
    }
    
    private var summarySection: some View {
        Section {
            HStack(spacing: 12) {
                SummaryStatCard(
                    value: "\(session.exercises.count)",
                    label: "Exercises",
                    icon: "list.bullet",
                    color: .blue
                )
                
                SummaryStatCard(
                    value: "\(totalSets)",
                    label: "Sets",
                    icon: "square.stack.3d.up",
                    color: .purple
                )
                
                SummaryStatCard(
                    value: volumeFormatted,
                    label: "Volume",
                    icon: "scalemass",
                    color: .orange
                )
            }
        } header: {
            Text("Stats")
        }
    }
    
    private var exercisesSection: some View {
        Section {
            ForEach(Array(session.exercises.enumerated()), id: \.element.id) { index, exercise in
                ExerciseDetailCard(exercise: exercise, index: index + 1)
            }
        } header: {
            Text("Exercises")
        }
    }
    
    private var totalSets: Int {
        session.exercises.flatMap { $0.sets }.count
    }
    
    private var totalVolume: Double {
        session.exercises.flatMap { $0.sets }.compactMap { set -> Double? in
            guard let weight = set.weightKg, let reps = set.reps else { return nil }
            return weight * Double(reps)
        }.reduce(0.0, +)
    }
    
    private var volumeFormatted: String {
        if totalVolume > 0 {
            return String(format: "%.0f kg", totalVolume)
        } else {
            return "—"
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutSessionDetailView(session: .mock)
    }
    .previewEnvironment()
}
