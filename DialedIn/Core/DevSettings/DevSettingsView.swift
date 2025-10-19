//
//  DevSettingsView.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 10/22/24.
//
import SwiftUI
import SwiftfulUtilities

struct DevSettingsView: View {
    
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(ExerciseTemplateManager.self) private var exerciseTemplateManager
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager
    @Environment(TrainingPlanManager.self) private var trainingPlanManager
    @Environment(AppState.self) private var appState

    @Environment(\.dismiss) private var dismiss
    
    @State private var isReseeding = false
    @State private var reseedingMessage = ""
    
    var body: some View {
        NavigationStack {
            List {
                authSection
                userSection
                deviceSection
                exerciseTemplateSection
                workoutTemplateSection
                trainingPlanSection
                seedingSection
                debugActionsSection
            }
            .navigationTitle("Dev Settings 🫨")
            .screenAppearAnalytics(name: "DevSettings")
            .scrollIndicators(.hidden)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButtonView
                }
            }
        }
    }
    
    private var backButtonView: some View {
        Image(systemName: "xmark")
            .anyButton {
                onBackButtonPressed()
            }
    }
    
    private func onBackButtonPressed() {
        dismiss()
    }
    
    private var authSection: some View {
        Section {
            let array = authManager.auth?.eventParameters.asAlphabeticalArray ?? []
            ForEach(array, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Auth Info")
        }
    }
    
    private var userSection: some View {
        Section {
            let array = userManager.currentUser?.eventParameters.asAlphabeticalArray ?? []
            ForEach(array, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("User Info")
        }
    }
    
    private var deviceSection: some View {
        Section {
            let array = SwiftfulUtilities.Utilities.eventParameters.asAlphabeticalArray
            ForEach(array, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Device Info")
        }
    }
    
    private var exerciseTemplateSection: some View {
        Section {
            let array = (try? exerciseTemplateManager.getAllLocalExerciseTemplates()) ?? []
            ForEach(array, id: \.exerciseId) { item in
                CustomListCellView(imageName: item.imageURL, title: item.name, subtitle: item.description)
                    .removeListRowFormatting()
            }
        } header: {
            HStack {
                Text("Exercise Templates")
                Spacer()
                Text("\(((try? exerciseTemplateManager.getAllLocalExerciseTemplates()) ?? []).count)")
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var workoutTemplateSection: some View {
        Section {
            let workouts = (try? workoutTemplateManager.getAllLocalWorkoutTemplates()) ?? []
            ForEach(workouts, id: \.workoutId) { workout in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(workout.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        if workout.isSystemWorkout {
                            Text("System")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.blue.opacity(0.1))
                                .foregroundStyle(.blue)
                                .clipShape(Capsule())
                        }
                    }
                    
                    if let description = workout.description {
                        Text(description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.caption2)
                        Text("\(workout.exercises.count) exercises")
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        } header: {
            HStack {
                Text("Workout Templates")
                Spacer()
                Text("\(((try? workoutTemplateManager.getAllLocalWorkoutTemplates()) ?? []).count)")
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var trainingPlanSection: some View {
        Section {
            if let plan = trainingPlanManager.currentTrainingPlan {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(plan.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(plan.weeks.count) weeks")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    let todaysWorkouts = trainingPlanManager.getTodaysWorkouts()
                    if !todaysWorkouts.isEmpty {
                        Divider()
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Today's Workouts: \(todaysWorkouts.count)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            ForEach(todaysWorkouts) { workout in
                                HStack {
                                    Text("• Workout")
                                        .font(.caption2)
                                    Spacer()
                                    if workout.isCompleted {
                                        Text("Completed ✓")
                                            .font(.caption2)
                                            .foregroundStyle(.green)
                                    } else if workout.isMissed {
                                        Text("Missed")
                                            .font(.caption2)
                                            .foregroundStyle(.red)
                                    } else {
                                        Text("Scheduled")
                                            .font(.caption2)
                                            .foregroundStyle(.orange)
                                    }
                                }
                            }
                        }
                        
                        Button {
                            Task {
                                await resetTodaysWorkouts()
                            }
                        } label: {
                            Label("Reset Today's Workouts", systemImage: "arrow.counterclockwise")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .disabled(isReseeding)
                    }
                }
                .padding(.vertical, 4)
            } else {
                Text("No active training plan")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Training Plan")
        } footer: {
            Text("Reset today's workouts to test the start/complete/discard flow again.")
        }
    }
    
    private var seedingSection: some View {
        Section {
            Button {
                Task {
                    await resetExerciseSeeding()
                }
            } label: {
                Label("Reset Exercise Seeding", systemImage: "arrow.clockwise")
            }
            .disabled(isReseeding)
            
            Button {
                Task {
                    await resetWorkoutSeeding()
                }
            } label: {
                Label("Reset Workout Seeding", systemImage: "arrow.clockwise")
            }
            .disabled(isReseeding)
            
            Button {
                Task {
                    await resetAllSeeding()
                }
            } label: {
                Label("Reset All Seeding", systemImage: "arrow.clockwise.circle.fill")
            }
            .disabled(isReseeding)
            
            if isReseeding {
                HStack {
                    ProgressView()
                    Text(reseedingMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Data Seeding")
        } footer: {
            Text("Use these options to reset and re-seed system exercises and workouts. Useful for testing or if seeding failed.")
        }
    }
    
    @ViewBuilder
    private var debugActionsSection: some View {
        #if DEBUG
        Section {
            Button(role: .destructive) {
                defer {
                    onForceFreshAnonUser()
                }
                dismiss()
            } label: {
                Text("Force fresh anonymous user")
            }
            .tint(.red)
        } header: {
            Text("Debug Actions")
        }
        #endif
    }
    
    private func itemRow(item: (key: String, value: Any)) -> some View {
        HStack {
            Text(item.key)
            Spacer(minLength: 4)
            
            if let value = String.convertToString(item.value) {
                Text(value)
            } else {
                Text("Unknown")
            }
        }
        .font(.caption)
        .lineLimit(1)
        .minimumScaleFactor(0.3)
    }
    
    private func resetExerciseSeeding() async {
        isReseeding = true
        reseedingMessage = "Resetting exercises..."
        
        UserDefaults.standard.removeObject(forKey: "hasSeededPrebuiltExercises")
        UserDefaults.standard.removeObject(forKey: "prebuiltExercisesSeedingVersion")
        
        reseedingMessage = "Complete! Restart app to reseed."
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        isReseeding = false
        reseedingMessage = ""
    }
    
    private func resetWorkoutSeeding() async {
        isReseeding = true
        reseedingMessage = "Resetting workouts..."
        
        UserDefaults.standard.removeObject(forKey: "hasSeededPrebuiltWorkouts")
        UserDefaults.standard.removeObject(forKey: "prebuiltWorkoutsSeedingVersion")
        
        reseedingMessage = "Complete! Restart app to reseed."
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        isReseeding = false
        reseedingMessage = ""
    }
    
    private func resetAllSeeding() async {
        isReseeding = true
        reseedingMessage = "Resetting all seeding..."
        
        UserDefaults.standard.removeObject(forKey: "hasSeededPrebuiltExercises")
        UserDefaults.standard.removeObject(forKey: "prebuiltExercisesSeedingVersion")
        UserDefaults.standard.removeObject(forKey: "hasSeededPrebuiltWorkouts")
        UserDefaults.standard.removeObject(forKey: "prebuiltWorkoutsSeedingVersion")
        
        reseedingMessage = "Complete! Restart app to reseed."
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        isReseeding = false
        reseedingMessage = ""
    }
    
    private func resetTodaysWorkouts() async {
        isReseeding = true
        reseedingMessage = "Resetting today's workouts..."
        
        guard var plan = trainingPlanManager.currentTrainingPlan else {
            reseedingMessage = "No active plan"
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            isReseeding = false
            reseedingMessage = ""
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Find and reset today's workouts
        for (weekIndex, week) in plan.weeks.enumerated() {
            for (workoutIndex, workout) in week.scheduledWorkouts.enumerated() {
                if let scheduledDate = workout.scheduledDate,
                   calendar.isDate(scheduledDate, inSameDayAs: today) {
                    // Reset to incomplete
                    let resetWorkout = ScheduledWorkout(
                        id: workout.id,
                        workoutTemplateId: workout.workoutTemplateId,
                        dayOfWeek: workout.dayOfWeek,
                        scheduledDate: workout.scheduledDate,
                        completedSessionId: nil,
                        isCompleted: false,
                        notes: workout.notes
                    )
                    plan.weeks[weekIndex].scheduledWorkouts[workoutIndex] = resetWorkout
                }
            }
        }
        
        // Save updated plan
        try? await trainingPlanManager.updatePlan(plan)
        
        reseedingMessage = "Reset complete!"
        
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        isReseeding = false
        reseedingMessage = ""
    }
    
    #if DEBUG
    private func onForceFreshAnonUser() {
        Task {
            // Attempt account deletion first; if that fails, sign out
            do {
                try await authManager.deleteAccount()
            } catch {
                try? authManager.signOut()
            }
            // Clear local user cache
            userManager.clearAllLocalData()
            // UI will reset to onboarding automatically when auth/user state changes
        }
    }
    #endif
}

#Preview {
    DevSettingsView()
        .previewEnvironment()
}
