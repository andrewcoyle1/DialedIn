//
//  TabBarView.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 10/5/24.
//

import SwiftUI

struct TabBarView: View {

    private enum Section: String, CaseIterable, Identifiable {
        case dashboard
        case exercises
        case nutrition
        case profile

        var id: Self { self }

        var title: String {
            switch self {
            case .dashboard: return "Dashboard"
            case .exercises: return "Training"
            case .nutrition: return "Nutrition"
            case .profile: return "Profile"
            }
        }

        var systemImage: String {
            switch self {
            case .dashboard: return "house"
            case .exercises: return "dumbbell"
            case .nutrition: return "carrot"
            case .profile: return "person.fill"
            }
        }
    }

    @Environment(WorkoutSessionManager.self) private var workoutSessionManager
    @State private var selectedSection: Section? = .dashboard
    @State private var presentTracker: Bool = false

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }

            TrainingView()
                .tabItem {
                    Label("Training", systemImage: "dumbbell")
                }

            NutritionView()
                .tabItem {
                    Label("Nutrition", systemImage: "carrot")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tabViewStyle(.sidebarAdaptable)
        .defaultAdaptableTabBarPlacement(.sidebar)
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory {
            if let active = workoutSessionManager.activeSession, !workoutSessionManager.isTrackerPresented {
                tabViewAccessory(active)
            }
        }
        .fullScreenCover(isPresented: Binding(get: {
            workoutSessionManager.isTrackerPresented
        }, set: { newValue in
            workoutSessionManager.isTrackerPresented = newValue
        })) {
            if let session = workoutSessionManager.activeSession {
                WorkoutTrackerView(workoutSession: session)
            }
        }
        .task {
            // Load any active session from local storage when the TabBar appears
            if let active = try? workoutSessionManager.getActiveLocalWorkoutSession() {
                workoutSessionManager.activeSession = active
            }
        }
    }

    private func tabViewAccessory(_ active: WorkoutSessionModel) -> some View {
        Button {
            workoutSessionManager.reopenActiveSession()
        } label: {
            HStack(spacing: 12) {
                iconSection

                workoutInfoSection(active)
                    .padding(.bottom, 6)
            }
            .padding()
        }
    }

    private var iconSection: some View {
        // Icon
        Image(systemName: isRestActive ? "timer" : "figure.strengthtraining.traditional")
            .font(.title2)
            .foregroundStyle(isRestActive ? .orange : .accent)
            .frame(width: 32)
    }

    private func workoutInfoSection(_ active: WorkoutSessionModel) -> some View {
        // Workout info
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(active.name)
                    .font(.headline)
                    .lineLimit(1)
                    .frame(minWidth: 150)
                    .padding(.trailing)
                Spacer()

                timeSection(workoutSession: active)
            }

            Gauge(value: progress) {
                EmptyView()
            } currentValueLabel: {
                // Text("\(Int(progress * 100))%")
                Text(progressLabel)
                    .font(.subheadline)
            }
            .gaugeStyle(.accessoryLinear)
            .tint(.accent)
            .frame(width: 280)
        }
    }

    private func timeSection(workoutSession active: WorkoutSessionModel) -> some View {
        Group {
            if let restEndTime = workoutSessionManager.restEndTime {
                let now = Date()
                if now < restEndTime {
                    // Rest timer
                    HStack(alignment: .bottom, spacing: 4) {
                        Text("Rest: ")
                        Text(timerInterval: now...restEndTime)
                            .monospacedDigit()
                            .foregroundStyle(.orange)
                    }
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                } else {
                    HStack(alignment: .bottom, spacing: 4) {
                        Text("Rest: ")
                        Text("00:00")
                            .monospacedDigit()
                            .foregroundStyle(.orange)
                    }
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                }
            } else {
                // Elapsed time
                HStack(spacing: 4) {
                    Text("Elapsed: ")
                    Text(active.dateCreated, style: .timer)
                        .monospacedDigit()
                }
                .foregroundStyle(.secondary)
                .font(.subheadline)
            }
        }
        .multilineTextAlignment(.trailing)
        .fixedSize(horizontal: true, vertical: true)
    }
    
    // MARK: - Helper Methods

    private var progress: Double {
        guard let active = workoutSessionManager.activeSession else { return 0 }
        return Double(completedSetsCount(active)) / Double(totalSetsCount(active))
    }

    private var progressLabel: String {
        guard let active = workoutSessionManager.activeSession else { return "" }
        return "\(completedSetsCount(active))/\(totalSetsCount(active)) sets"
    }
    private var isRestActive: Bool {
        guard let end = workoutSessionManager.restEndTime else { return false }
        return Date() < end
    }

    private func completedSetsCount(_ session: WorkoutSessionModel) -> Int {
        session.exercises.flatMap(\.sets).filter { $0.completedAt != nil }.count
    }

    private func totalSetsCount(_ session: WorkoutSessionModel) -> Int {
        session.exercises.flatMap(\.sets).count
    }

    private func totalVolume(_ session: WorkoutSessionModel) -> Double {
        session.exercises.flatMap(\.sets)
            .compactMap { set -> Double? in
                guard let weight = set.weightKg, let reps = set.reps else { return nil }
                return weight * Double(reps)
            }
            .reduce(0.0, +)
    }
}

#Preview("Has No Active Session") {
    TabBarView()
        .environment(WorkoutSessionManager(services: MockWorkoutSessionServices(hasActiveSession: false)))
        .previewEnvironment()
}

#Preview("Has Active Session") {
    TabBarView()
        .environment(WorkoutSessionManager(services: MockWorkoutSessionServices(hasActiveSession: true)))
        .previewEnvironment()
}
