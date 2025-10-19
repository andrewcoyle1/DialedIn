//
//  ExerciseDetailCard.swift
//  DialedIn
//
//  Created by Andrew Coyle on 19/10/2025.
//

import SwiftUI

struct ExerciseDetailCard: View {
    let exercise: WorkoutExerciseModel
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise header
            HStack {
                Text("\(index). \(exercise.name)")
                    .font(.headline)
                
                Spacer()
                
                Text("\(exercise.sets.count) sets")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if let notes = exercise.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            // Sets
            VStack(spacing: 8) {
                ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { setIndex, set in
                    SetDetailRow(set: set, index: setIndex + 1, trackingMode: exercise.trackingMode)
                }
            }
        }
    }
}

#Preview {
    List {
        ExerciseDetailCard(
            exercise: WorkoutExerciseModel.mock,
            index: 1
        )
    }
}
