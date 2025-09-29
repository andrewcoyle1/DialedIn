//
//  WorkoutStartView.swift
//  DialedIn
//
//  Created by AI Assistant on 26/09/2025.
//

import SwiftUI

struct WorkoutStartView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(WorkoutSessionManager.self) private var workoutSessionManager
    @Environment(\.dismiss) private var dismiss
    
    let template: WorkoutTemplateModel
    
    @State private var workoutNotes = ""
    @State private var isStarting = false
    @State private var showingTracker = false
    @State private var createdSession: WorkoutSessionModel?
    
    var body: some View {
        NavigationStack {
            List {
                // Workout Preview
                workoutPreview
                
                // Exercises
                exercisesSection
                
                // Notes section
                notesSection
            }
            .navigationTitle("Start Workout")
            .navigationBarTitleDisplayMode(.large)
            .navigationSubtitle(template.name)
            .scrollIndicators(.hidden)
            .safeAreaInset(edge: .bottom) {
                // Start button
                startButton
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingTracker, onDismiss: {
            // Start screen dismisses itself when tracker is dismissed if no active session
            if workoutSessionManager.activeSession == nil {
                dismiss()
            }
        }) {
            if let session = createdSession {
                WorkoutTrackerView(workoutSession: session)
            }
        }
    }
    
    // MARK: - Workout Preview
    
    private var workoutPreview: some View {
        Section {
            // Stats
            HStack(spacing: 20) {
                StatCard(title: "Exercises", value: "\(template.exercises.count)")
                StatCard(title: "Est. Time", value: estimatedTime)
                StatCard(title: "Focus", value: primaryMuscleGroup)
            }
        } header: {
            Text("Workout Overview")
        }
    }
    
    // MARK: - Exercises Section
    
    private var exercisesSection: some View {
        Section {
            // Exercise list preview
                
                ForEach(Array(template.exercises.prefix(5).enumerated()), id: \.element.id) { index, exercise in
                    HStack {
                        Text("\(index + 1).")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 20, alignment: .leading)
                        
                        Text(exercise.name)
                            .font(.footnote)
                        
                        Spacer()
                        
                        Text(exercise.type.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if template.exercises.count > 5 {
                    Text("+ \(template.exercises.count - 5) more exercises")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 20)
                }
        } header: {
            Text("Exercises")
            
        }
    }
    // MARK: - Notes Section
    
    private var notesSection: some View {
        Section {
            TextEditor(text: $workoutNotes)
                .frame(minHeight: 80)
                .padding(8)
                .cornerRadius(8)
            
        } header: {
            Text("Workout Notes (Optional)")
        }
    }
    
    // MARK: - Start Button
    
    private var startButton: some View {
        Button {
            startWorkout()
        } label: {
            HStack {
                if isStarting {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "play.fill")
                }
                
                Text(isStarting ? "Starting..." : "Start Workout")
            }
            .frame(maxWidth: .infinity)
            .frame(height: 55)
        }
        .buttonStyle(.glassProminent)
        .disabled(isStarting)
        .padding(.horizontal)
    }
    
    // MARK: - Computed Properties
    
    private var estimatedTime: String {
        // Rough estimate: 3-4 minutes per exercise
        let minutes = template.exercises.count * 4
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(remainingMinutes)m"
        }
    }
    
    private var primaryMuscleGroup: String {
        // Find the most common exercise category
        let categories = template.exercises.map { $0.type }
        let categoryFrequency = Dictionary(grouping: categories, by: { $0 })
            .mapValues { $0.count }
        
        let mostCommon = categoryFrequency.max(by: { $0.value < $1.value })?.key
        return mostCommon?.displayName ?? "Mixed"
    }
    
    // MARK: - Actions
    
    private func startWorkout() {
        guard let userId = userManager.currentUser?.userId else {
            return
        }
        
        Task {
            isStarting = true
            
            do {
                // Create workout session from template
                let session = WorkoutSessionModel(
                    authorId: userId,
                    template: template,
                    notes: workoutNotes.isEmpty ? nil : workoutNotes
                )
                
                // Save locally first (MainActor-isolated)
                try workoutSessionManager.addLocalWorkoutSession(session: session)
                
                await MainActor.run {
                    createdSession = session
                    workoutSessionManager.startActiveSession(session)
                    isStarting = false
                    showingTracker = true
                }
                
            } catch {
                await MainActor.run {
                    isStarting = false
                    // Handle error - could show an alert
                }
            }
        }
    }
}

// MARK: - Extensions

extension ExerciseCategory {
    var displayName: String {
        switch self {
        case .barbell:
            return "Barbell"
        case .dumbbell:
            return "Dumbbell"
        case .kettlebell:
            return "Kettlebell"
        case .medicineBall:
            return "Medicine Ball"
        case .machine:
            return "Machine"
        case .cable:
            return "Cable"
        case .weightedBodyweight:
            return "Weighted"
        case .assistedBodyweight:
            return "Assisted"
        case .repsOnly:
            return "Bodyweight"
        case .cardio:
            return "Cardio"
        case .duration:
            return "Duration"
        case .none:
            return "Other"
        }
    }
}

#Preview {
    WorkoutStartView(template: WorkoutTemplateModel.mock)
        .previewEnvironment()
}
