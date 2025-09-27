//
//  ExerciseTrackerCard.swift
//  DialedIn
//
//  Created by AI Assistant on 26/09/2025.
//

import SwiftUI

struct ExerciseTrackerCard: View {
    let exercise: WorkoutExerciseModel
    let exerciseIndex: Int
    let isCurrentExercise: Bool
    let isExpanded: Bool
    let onToggleExpansion: () -> Void
    let onSetUpdate: (WorkoutSetModel) -> Void
    let onAddSet: () -> Void
    let onDeleteSet: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Exercise Header
            exerciseHeader
            
            // Sets content (expandable)
            if isExpanded {
                setsContent
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(26)
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(isCurrentExercise ? Color.blue : Color.clear, lineWidth: 2)
        )
        // .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
    
    // MARK: - Exercise Header
    
    private var exerciseHeader: some View {
        Button {
            onToggleExpansion()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(exerciseIndex + 1).")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        
                        Text(exercise.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    
                    HStack(spacing: 12) {
                        Text(exercise.trackingMode.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(completedSetsCount)/\(exercise.sets.count) sets")
                            .font(.caption)
                            .foregroundColor(completedSetsCount == exercise.sets.count ? .green : .secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
            }
            .padding()
            .tappableBackground()
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Sets Content
    
    private var setsContent: some View {
        VStack(spacing: 12) {
            Divider()
                .padding(.horizontal)
            
            // Sets list
            ForEach(exercise.sets) { set in
                SetTrackerRow(
                    set: set,
                    trackingMode: exercise.trackingMode,
                    onUpdate: onSetUpdate,
                    onDelete: { onDeleteSet(set.id) }
                )
            }
            
            // Add set button
            Button {
                onAddSet()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Set")
                }
                .font(.footnote.bold())
                .foregroundColor(.blue)
                .padding(.vertical, 8)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    // MARK: - Computed Properties
    
    private var completedSetsCount: Int {
        exercise.sets.filter { $0.completedAt != nil }.count
    }
}

// MARK: - Extensions

extension TrackingMode {
    var displayName: String {
        switch self {
        case .weightReps:
            return "Weight & Reps"
        case .repsOnly:
            return "Reps Only"
        case .timeOnly:
            return "Time Only"
        case .distanceTime:
            return "Distance & Time"
        }
    }
}

#Preview {
    VStack {
        ExerciseTrackerCard(
            exercise: WorkoutExerciseModel.mock,
            exerciseIndex: 0,
            isCurrentExercise: true,
            isExpanded: true,
            onToggleExpansion: {},
            onSetUpdate: { _ in },
            onAddSet: {},
            onDeleteSet: { _ in }
        )
        
        ExerciseTrackerCard(
            exercise: WorkoutExerciseModel.mock,
            exerciseIndex: 1,
            isCurrentExercise: false,
            isExpanded: false,
            onToggleExpansion: {},
            onSetUpdate: { _ in },
            onAddSet: {},
            onDeleteSet: { _ in }
        )
    }
    .padding()
    .previewEnvironment()
}
