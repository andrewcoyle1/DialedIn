//
//  WorkoutStartView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/09/2025.
//

import SwiftUI

struct WorkoutStartView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss
    
    @State var viewModel: WorkoutStartViewModel
    
    let template: WorkoutTemplateModel
    let scheduledWorkout: ScheduledWorkout?
    
    init(viewModel: WorkoutStartViewModel, template: WorkoutTemplateModel, scheduledWorkout: ScheduledWorkout? = nil) {
        self.viewModel = viewModel
        self.template = template
        self.scheduledWorkout = scheduledWorkout
    }
    
    var body: some View {
        NavigationStack {
            List {
                workoutPreview
                exercisesSection
                notesSection
            }
            .navigationTitle("Start Workout")
            .navigationBarTitleDisplayMode(.large)
            .navigationSubtitle(template.name)
            .scrollIndicators(.hidden)
            .safeAreaInset(edge: .bottom) {
                startButton
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
        }
        
        .adaptiveFullScreenCover(isPresented: $viewModel.showingTracker, onDismiss: {
            // Start screen dismisses itself when tracker is dismissed if no active session
            if viewModel.activeSession == nil {
                dismiss()
            }
        }, content: {
            if let session = viewModel.createdSession {
                WorkoutTrackerView(viewModel: WorkoutTrackerViewModel(container: container, workoutSession: session), initialWorkoutSession: session)
            }
        })
    }
        
    private var workoutPreview: some View {
        Section {
            // Stats
            HStack(spacing: 20) {
                StatCard(title: "Exercises", value: "\(template.exercises.count)")
                StatCard(title: "Est. Time", value: viewModel.estimatedTime(template: template))
                StatCard(title: "Focus", value: viewModel.primaryMuscleGroup(template: template))
            }
        } header: {
            Text("Workout Overview")
        }
    }
        
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
    
    private var notesSection: some View {
        Section {
            TextEditor(text: $viewModel.workoutNotes)
                .frame(minHeight: 80)
                .padding(8)
                .cornerRadius(8)
            
        } header: {
            Text("Workout Notes (Optional)")
        }
    }
        
    private var startButton: some View {
        Button {
            viewModel.startWorkout(template: template, scheduledWorkout: scheduledWorkout)
        } label: {
            HStack {
                if viewModel.isStarting {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "play.fill")
                }
                
                Text(viewModel.isStarting ? "Starting..." : "Start Workout")
            }
            .frame(maxWidth: .infinity)
            .frame(height: 55)
        }
        .buttonStyle(.glassProminent)
        .disabled(viewModel.isStarting)
        .padding(.horizontal)
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Cancel") {
                dismiss()
            }
        }
    }
}

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
    WorkoutStartView(viewModel: WorkoutStartViewModel(container: DevPreview.shared.container), template: WorkoutTemplateModel.mock)
        .previewEnvironment()
}
