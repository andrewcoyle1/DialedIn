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
    @Environment(WorkoutSessionManager.self) private var workoutSessionManager
    @Environment(AppState.self) private var appState

    @Environment(\.dismiss) private var dismiss
    
    @State private var isReseeding = false
    @State private var reseedingMessage = ""
    @State private var testSessionId = ""
    @State private var fetchedSession: WorkoutSessionModel?
    @State private var isFetchingSession = false
    @State private var fetchError: String?
    
    var body: some View {
        NavigationStack {
            List {
                authSection
                userSection
                deviceSection
                activeWorkoutSessionSection
                trainingPlanSection
                localStorageDebugSection
                firebaseTestSection
                exerciseTemplateSection
                workoutTemplateSection
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
                    // Plan basics
                    debugRow(label: "Plan ID", value: plan.planId)
                    debugRow(label: "User ID", value: plan.userId ?? "nil")
                    debugRow(label: "Name", value: plan.name)
                    debugRow(label: "Is Active", value: "\(plan.isActive)")
                    debugRow(label: "Weeks Count", value: "\(plan.weeks.count)")
                    
                    if let currentWeek = trainingPlanManager.getCurrentWeek() {
                        debugRow(label: "Current Week #", value: "\(currentWeek.weekNumber)")
                    }
                    
                    // Today's workouts detail
                    let todaysWorkouts = trainingPlanManager.getTodaysWorkouts()
                    if !todaysWorkouts.isEmpty {
                        Divider()
                        Text("Today's Workouts (\(todaysWorkouts.count))")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                        
                        ForEach(todaysWorkouts) { workout in
                            VStack(alignment: .leading, spacing: 2) {
                                debugRow(label: "  Scheduled ID", value: workout.id)
                                debugRow(label: "  Template ID", value: workout.workoutTemplateId)
                                debugRow(label: "  Name", value: workout.workoutName ?? "nil")
                                if let date = workout.scheduledDate {
                                    debugRow(label: "  Scheduled", value: date.formatted(date: .numeric, time: .shortened))
                                }
                                debugRow(label: "  Is Completed", value: "\(workout.isCompleted)")
                                if let sessionId = workout.completedSessionId {
                                    debugRow(label: "  Session ID", value: sessionId)
                                } else {
                                    debugRow(label: "  Session ID", value: "nil")
                                }
                                debugRow(label: "  Is Missed", value: "\(workout.isMissed)")
                            }
                            .padding(.vertical, 2)
                            .padding(.horizontal, 4)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(4)
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
            Text("Training Plan Debug")
        } footer: {
            Text("Shows the current training plan state and today's scheduled workouts with all IDs.")
        }
    }
    
    private var activeWorkoutSessionSection: some View {
        Section {
            if let session = workoutSessionManager.activeSession {
                VStack(alignment: .leading, spacing: 8) {
                    debugRow(label: "Session ID", value: session.id)
                    debugRow(label: "Name", value: session.name)
                    debugRow(label: "Template ID", value: session.workoutTemplateId ?? "nil")
                    debugRow(label: "Scheduled ID", value: session.scheduledWorkoutId ?? "nil")
                    debugRow(label: "Plan ID", value: session.trainingPlanId ?? "nil")
                    debugRow(label: "Created", value: session.dateCreated.formatted(date: .numeric, time: .shortened))
                    if let endedAt = session.endedAt {
                        debugRow(label: "Ended", value: endedAt.formatted(date: .numeric, time: .shortened))
                    } else {
                        debugRow(label: "Ended", value: "nil (in progress)")
                    }
                    debugRow(label: "Exercises", value: "\(session.exercises.count)")
                    
                    let completedSets = session.exercises.flatMap { $0.sets }.filter { $0.completedAt != nil }.count
                    let totalSets = session.exercises.flatMap { $0.sets }.count
                    debugRow(label: "Sets", value: "\(completedSets)/\(totalSets)")
                }
                .padding(.vertical, 4)
            } else {
                Text("No active workout session")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Active Workout Session")
        } footer: {
            Text("Shows the currently active workout session if one is in progress.")
        }
    }
    
    private var localStorageDebugSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                // Active session from local storage
                if let activeSession = try? workoutSessionManager.getActiveLocalWorkoutSession() {
                    Text("Active Session (Local)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        debugRow(label: "  Session ID", value: activeSession.id)
                        debugRow(label: "  Template ID", value: activeSession.workoutTemplateId ?? "nil")
                        debugRow(label: "  Scheduled ID", value: activeSession.scheduledWorkoutId ?? "nil")
                        debugRow(label: "  Plan ID", value: activeSession.trainingPlanId ?? "nil")
                    }
                    .padding(.vertical, 2)
                    .padding(.horizontal, 4)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(4)
                } else {
                    Text("No active session in local storage")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                
                // Recent sessions
                let recentSessions = (try? workoutSessionManager.getAllLocalWorkoutSessions()) ?? []
                let last3 = Array(recentSessions.sorted(by: { $0.dateCreated > $1.dateCreated }).prefix(3))
                
                Text("Recent Sessions (Last 3)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                
                if last3.isEmpty {
                    Text("No recent sessions")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(last3, id: \.id) { session in
                        VStack(alignment: .leading, spacing: 2) {
                            debugRow(label: "  Session ID", value: String(session.id.prefix(8)) + "...")
                            debugRow(label: "  Template ID", value: session.workoutTemplateId ?? "nil")
                            debugRow(label: "  Scheduled ID", value: session.scheduledWorkoutId ?? "nil")
                            debugRow(label: "  Plan ID", value: session.trainingPlanId ?? "nil")
                            debugRow(label: "  Created", value: session.dateCreated.formatted(date: .numeric, time: .shortened))
                            if let ended = session.endedAt {
                                debugRow(label: "  Ended", value: ended.formatted(date: .numeric, time: .shortened))
                            }
                        }
                        .padding(.vertical, 2)
                        .padding(.horizontal, 4)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(4)
                    }
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("Local Storage Debug")
        } footer: {
            Text("Verifies that scheduledWorkoutId and other IDs are properly persisted in local SwiftData storage.")
        }
    }
    
    private var firebaseTestSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("Fetch Session from Firebase")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                TextField("Session ID", text: $testSessionId)
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
                
                Button {
                    Task {
                        await fetchSessionFromFirebase()
                    }
                } label: {
                    if isFetchingSession {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Label("Fetch Session", systemImage: "arrow.down.circle")
                            .font(.caption)
                    }
                }
                .buttonStyle(.bordered)
                .disabled(testSessionId.isEmpty || isFetchingSession)
                
                if let error = fetchError {
                    Text(error)
                        .font(.caption2)
                        .foregroundStyle(.red)
                        .padding(.top, 4)
                }
                
                if let session = fetchedSession {
                    Divider()
                    
                    Text("Fetched Session")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        debugRow(label: "  Session ID", value: String(session.id.prefix(8)) + "...")
                        debugRow(label: "  Name", value: session.name)
                        debugRow(label: "  Template ID", value: session.workoutTemplateId ?? "nil")
                        debugRow(label: "  Scheduled ID", value: session.scheduledWorkoutId ?? "nil")
                        debugRow(label: "  Plan ID", value: session.trainingPlanId ?? "nil")
                        debugRow(label: "  Created", value: session.dateCreated.formatted(date: .numeric, time: .shortened))
                        if let ended = session.endedAt {
                            debugRow(label: "  Ended", value: ended.formatted(date: .numeric, time: .shortened))
                        }
                    }
                    .padding(.vertical, 2)
                    .padding(.horizontal, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(4)
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("Firebase Test")
        } footer: {
            Text("Fetch a session from Firebase to verify that scheduledWorkoutId and trainingPlanId are properly stored and retrieved.")
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
                Text("Clear local data & sign out")
            }
            .tint(.red)
        } header: {
            Text("Debug Actions")
        } footer: {
            Text("Clears all local data and signs out. Your Firebase account remains intact.")
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
    
    private func fetchSessionFromFirebase() async {
        isFetchingSession = true
        fetchError = nil
        fetchedSession = nil
        
        do {
            let session = try await workoutSessionManager.getWorkoutSession(id: testSessionId)
            await MainActor.run {
                fetchedSession = session
                isFetchingSession = false
            }
        } catch {
            await MainActor.run {
                fetchError = error.localizedDescription
                isFetchingSession = false
            }
        }
    }
    
    private func debugRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption2)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.trailing)
        }
    }
    
    #if DEBUG
    private func onForceFreshAnonUser() {
        Task {
            guard let userId = userManager.currentUser?.userId else {
                // No user, just sign out
                try? authManager.signOut()
                return
            }
            
            // 1. Stop all listeners FIRST to prevent permission errors
            await MainActor.run {
                // Stop TrainingPlanManager listener
                trainingPlanManager.clearAllLocalData()
            }
            
            // 2. Clear ALL local data
            // Clear workout sessions
            do {
                try workoutSessionManager.deleteAllLocalWorkoutSessionsForAuthor(authorId: userId)
            } catch {
                print("Error clearing local workout sessions: \(error)")
            }
            
            // Clear user data and stop UserManager listener
            userManager.signOut()
            
            // 3. Sign out (account remains intact in Firebase)
            do {
                try authManager.signOut()
                print("✅ Signed out successfully - account preserved")
            } catch {
                print("⚠️ Sign out failed: \(error)")
            }
            
            // UI will reset to onboarding automatically when auth state changes
        }
    }
    #endif
}

#Preview {
    DevSettingsView()
        .previewEnvironment()
}
