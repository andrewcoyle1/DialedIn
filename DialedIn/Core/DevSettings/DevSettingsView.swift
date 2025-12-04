//
//  DevSettingsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/22/24.
//

import SwiftUI
import CustomRouting

struct DevSettingsView: View {
    
    @State var presenter: DevSettingsPresenter

    var body: some View {
        List {
            debugActionsSection
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
        }
        .navigationTitle("Developer Settings")
        .screenAppearAnalytics(name: "DevSettings")
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButtonView
            }
        }
    }
    
    private var backButtonView: some View {
        Image(systemName: "xmark")
            .anyButton {
                presenter.onDismissPressed()
            }
    }

    private var authSection: some View {
        Section {
            let array = presenter.authParams()
            ForEach(array, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Auth Info")
        }
    }
    
    private var userSection: some View {
        Section {
            let array = presenter.userParams()
            ForEach(array, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("User Info")
        }
    }
    
    private var deviceSection: some View {
        Section {
            let array = presenter.deviceParams()
            ForEach(array, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Device Info")
        }
    }
    
    private var exerciseTemplateSection: some View {
        Group {
            let array = presenter.getLocalExercises()
            Section {
                ForEach(array, id: \.exerciseId) { item in
                    CustomListCellView(imageName: item.imageURL, title: item.name, subtitle: item.description)
                        .removeListRowFormatting()
                }
            } header: {
                HStack {
                    Text("Exercise Templates")
                    Spacer()
                    Text("\(array.count)")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var workoutTemplateSection: some View {
        Group {
            let workouts = presenter.getLocalWorkoutTemplates()
            Section {
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
                    Text("\(workouts.count)")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var trainingPlanSection: some View {
        Section {
            if let plan = presenter.getLocalTrainingPlan() {
                VStack(alignment: .leading, spacing: 8) {
                    // Plan basics
                    debugRow(label: "Plan ID", value: plan.planId)
                    debugRow(label: "User ID", value: plan.userId ?? "nil")
                    debugRow(label: "Name", value: plan.name)
                    debugRow(label: "Is Active", value: "\(plan.isActive)")
                    debugRow(label: "Weeks Count", value: "\(plan.weeks.count)")
                    
                    if let currentWeek = presenter.getCurrentTrainingPlanWeek() {
                        debugRow(label: "Current Week #", value: "\(currentWeek.weekNumber)")
                    }
                    
                    // Today's workouts detail
                    let todaysWorkouts = presenter.getTodaysWorkouts()
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
                                await presenter.resetTodaysWorkouts()
                            }
                        } label: {
                            Label("Reset Today's Workouts", systemImage: "arrow.counterclockwise")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .disabled(presenter.isReseeding)
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
            if let session = presenter.getActiveSession() {
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
                if let activeSession = presenter.getActiveLocalWorkoutSession() {
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
                let recentSessions = presenter.getRecentWorkoutSessions()
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
                
                TextField("Session ID", text: $presenter.testSessionId)
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
                
                Button {
                    Task {
                        await presenter.fetchSessionFromFirebase()
                    }
                } label: {
                    if presenter.isFetchingSession {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Label("Fetch Session", systemImage: "arrow.down.circle")
                            .font(.caption)
                    }
                }
                .buttonStyle(.bordered)
                .disabled(presenter.testSessionId.isEmpty || presenter.isFetchingSession)
                
                if let error = presenter.fetchError {
                    Text(error)
                        .font(.caption2)
                        .foregroundStyle(.red)
                        .padding(.top, 4)
                }
                
                if let session = presenter.fetchedSession {
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
                    await presenter.resetExerciseSeeding()
                }
            } label: {
                Label("Reset Exercise Seeding", systemImage: "arrow.clockwise")
            }
            .disabled(presenter.isReseeding)
            
            Button {
                Task {
                    await presenter.resetWorkoutSeeding()
                }
            } label: {
                Label("Reset Workout Seeding", systemImage: "arrow.clockwise")
            }
            .disabled(presenter.isReseeding)
            
            Button {
                Task {
                    await presenter.resetAllSeeding()
                }
            } label: {
                Label("Reset All Seeding", systemImage: "arrow.clockwise.circle.fill")
            }
            .disabled(presenter.isReseeding)
            
            if presenter.isReseeding {
                HStack {
                    ProgressView()
                    Text(presenter.reseedingMessage)
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
        Section {
            Button(role: .destructive) {
                presenter.onForceFreshAnonUser()
            } label: {
                Text("Clear local data & sign out")
            }
            .tint(.red)
        } header: {
            Text("Debug Actions")
        } footer: {
            Text("Clears all local data and signs out. Your Firebase account remains intact.")
        }
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
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.devSettingsView(router: router)
    }
    .previewEnvironment()
}
