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
        HStack {
            if let imageName = exercise.imageName, !imageName.isEmpty {
                ImageLoaderView(urlString: imageName, resizingMode: .fit)
                    .frame(width: 60, height: 60)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                // Exercise header
                HStack {
                    Text("\(index). \(exercise.name)")
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer(minLength: 0)
                        
                    Text(String.countCaption(count: exercise.sets.filter { !$0.isWarmup }.count, unit: "set"))
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
                    ForEach(Array(exercise.sets.filter { !$0.isWarmup }.enumerated()), id: \.element.id) { setIndex, set in
                        SetDetailRow(set: set, index: setIndex + 1, trackingMode: exercise.trackingMode)
                    }
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
