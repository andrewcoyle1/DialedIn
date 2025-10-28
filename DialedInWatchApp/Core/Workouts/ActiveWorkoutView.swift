//
//  ActiveWorkoutView.swift
//  DialedInWatchApp
//
//  Created by Andrew Coyle on 25/10/2025.
//

import SwiftUI

struct ActiveWorkoutView: View {

    @State private var currentExerciseIndex = 0
    @State private var showingCompleteAlert = false
    
    var currentExercise: WorkoutExerciseModel? {
        let session = WorkoutSessionModel.mock
        return session.exercises[currentExerciseIndex]
    }
    
    var body: some View {
        Group {
            if let exercise = currentExercise {
                ExerciseTrackingView(
                    exercise: exercise,
                    exerciseIndex: currentExerciseIndex
                )
            } else {
                EmptyWorkoutView()
            }
        }
        .alert("Complete Workout?", isPresented: $showingCompleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Complete") {
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    print("Workout Complete")
                }
            }
        }
    }
}

struct ExerciseTrackingView: View {
    let exercise: WorkoutExerciseModel
    let exerciseIndex: Int
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Exercise Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.title2)
                        .bold()
                    
                    Text("Set \(exerciseIndex + 1)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Sets Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sets")
                        .font(.headline)
                    
                    ForEach(exercise.sets) { set in
                        HStack {
                            Text("Set \(set.index)")
                                .font(.body)
                            
                            Spacer()
                            
                            if exercise.trackingMode == .weightReps {
                                if let weight = set.weightKg {
                                    Text("\(Int(weight))kg")
                                        .foregroundStyle(.secondary)
                                }
                                if let reps = set.reps {
                                    Text("× \(reps)")
                                        .foregroundStyle(.secondary)
                                }
                            } else if exercise.trackingMode == .repsOnly {
                                if let reps = set.reps {
                                    Text("\(reps) reps")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
    }
}

struct EmptyWorkoutView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            
            Text("No Active Workout")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("Start a workout from the Workouts tab")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview("Empty") {
    ActiveWorkoutView()
}
