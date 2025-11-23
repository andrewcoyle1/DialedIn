//
//  WorkoutStartView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/09/2025.
//

import SwiftUI
import CustomRouting

struct WorkoutStartViewDelegate {

    let template: WorkoutTemplateModel
    let scheduledWorkout: ScheduledWorkout?

    init(template: WorkoutTemplateModel, scheduledWorkout: ScheduledWorkout? = nil) {
        self.template = template
        self.scheduledWorkout = scheduledWorkout
    }
}

struct WorkoutStartView: View {

    @State var viewModel: WorkoutStartViewModel
    
    let delegate: WorkoutStartViewDelegate

    var body: some View {
        NavigationStack {
            List {
                workoutPreview
                exercisesSection
                notesSection
            }
            .navigationTitle("Start Workout")
            .navigationBarTitleDisplayMode(.large)
            .navigationSubtitle(delegate.template.name)
            .scrollIndicators(.hidden)
            .safeAreaInset(edge: .bottom) {
                startButton
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
        }
    }
        
    private var workoutPreview: some View {
        Section {
            // Stats
            HStack(spacing: 20) {
                StatCard(
                    value: "\(delegate.template.exercises.count)",
                    label: "Exercises",
                )
                StatCard(
                    value: viewModel.estimatedTime(
                        template: delegate.template
                    ),
                    label: "Est. Time"
                )
                StatCard(
                    value: viewModel.primaryMuscleGroup(
                        template: delegate.template
                    ),
                    label: "Focus"
                )
            }
        } header: {
            Text("Workout Overview")
        }
    }
        
    private var exercisesSection: some View {
        Section {
            // Exercise list preview
            ForEach(Array(delegate.template.exercises.prefix(5).enumerated()), id: \.element.id) { index, exercise in
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
            
            if delegate.template.exercises.count > 5 {
                Text("+ \(delegate.template.exercises.count - 5) more exercises")
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
            viewModel.startWorkout(template: delegate.template, scheduledWorkout: delegate.scheduledWorkout)
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
                viewModel.dismissScreen()
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
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = WorkoutStartViewDelegate(template: .mock)
    RouterView { router in
        builder.workoutStartView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
