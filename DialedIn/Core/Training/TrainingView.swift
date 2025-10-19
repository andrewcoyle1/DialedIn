//
//  TrainingView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct TrainingView: View {

    @Environment(\.layoutMode) private var layoutMode
    @Environment(DetailNavigationModel.self) private var detail
    @Environment(TrainingPlanManager.self) private var trainingPlanManager
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager
    @Environment(WorkoutSessionManager.self) private var workoutSessionManager
    @Environment(ExerciseTemplateManager.self) private var exerciseTemplateManager
    @Environment(AuthManager.self) private var authManager
    @State private var presentationMode: TrainingPresentationMode = .program

    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    
    @State private var showNotificationsView: Bool = false
    
    @State private var searchExerciseTask: Task<Void, Never>?
    @State private var searchWorkoutTask: Task<Void, Never>?
    @State private var isLoading: Bool = false
    @State private var searchText: String = ""
    @State private var showAlert: AnyAppAlert?

    @State private var isShowingInspector: Bool = false
    @State private var selectedExerciseTemplate: ExerciseTemplateModel?
    @State private var selectedWorkoutTemplate: WorkoutTemplateModel?
    @State private var workoutToStart: WorkoutTemplateModel?
    @State private var scheduledWorkoutToStart: ScheduledWorkout?
    @State private var showCreateExercise: Bool = false
    @State private var showCreateWorkout: Bool = false
    // Centralized sheet coordination for ProgramView
    @State private var programActiveSheet: ProgramView.ActiveSheet?

    enum TrainingPresentationMode {
        case program
        case workouts
        case exercises
    }
    
    var body: some View {
        Group {
            if layoutMode == .tabBar {
                NavigationStack {
                    contentView
                }
            } else {
                contentView
            }
        }
        // Only show inspector in compact/tabBar modes; not in split view where detail is used
        .modifier(InspectorIfCompact(isPresented: $isShowingInspector, inspector: {
            Group {
                if let exercise = selectedExerciseTemplate {
                    NavigationStack { ExerciseDetailView(exerciseTemplate: exercise) }
                } else if let workout = selectedWorkoutTemplate {
                    NavigationStack { WorkoutTemplateDetailView(workoutTemplate: workout) }
                } else {
                    Text("Select an item").foregroundStyle(.secondary).padding()
                }
            }
        }, enabled: layoutMode != .splitView))
        .onChange(of: selectedExerciseTemplate) { _, exercise in
            guard layoutMode == .splitView else { return }
            if let exercise { detail.path = [.exerciseTemplate(exerciseTemplate: exercise)] }
        }
        .onChange(of: selectedWorkoutTemplate) { _, workout in
            guard layoutMode == .splitView else { return }
            if let workout { detail.path = [.workoutTemplateDetail(template: workout)] }
        }
        .showCustomAlert(alert: $showAlert)
    }
    
    private var contentView: some View {
        VStack(spacing: 0) {
            List {
                pickerSection
                listContents
            }
            .scrollIndicators(.hidden)
            #if DEBUG || MOCK
            .sheet(isPresented: $showDebugView) {
                DevSettingsView()
            }
            #endif
            .sheet(isPresented: $showNotificationsView) {
                NotificationsView()
            }
            .sheet(item: $workoutToStart) { template in
                WorkoutStartView(
                    template: template,
                    scheduledWorkout: scheduledWorkoutToStart
                )
            }
            .sheet(item: $programActiveSheet) { sheet in
                switch sheet {
                case .programPicker:
                    ProgramPickerSheetView()
                case .progressDashboard:
                    ProgressDashboardView()
                case .strengthProgress:
                    StrengthProgressView()
                case .workoutHeatmap:
                    WorkoutHeatmapView(
                        progressAnalytics: ProgressAnalyticsService(
                            workoutSessionManager: workoutSessionManager,
                            exerciseTemplateManager: exerciseTemplateManager
                        )
                    )
                }
            }
            .sheet(isPresented: $showCreateExercise) {
                CreateExerciseView()
            }
            .sheet(isPresented: $showCreateWorkout) {
                CreateWorkoutView()
            }
        }
        .navigationTitle("Training")
        .navigationSubtitle(navigationSubtitle)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }
    }

    private var pickerSection: some View {
        Section {
            Picker("Section", selection: $presentationMode) {
                Text("Program").tag(TrainingPresentationMode.program)
                Text("Workouts").tag(TrainingPresentationMode.workouts)
                Text("Exercises").tag(TrainingPresentationMode.exercises)
            }
            .pickerStyle(.segmented)
        }
        .listSectionSpacing(0)
        .removeListRowFormatting()
    }
    
    private var listContents: some View {
        Group {
            switch presentationMode {
            case .program:
                ProgramView(
                    isShowingInspector: $isShowingInspector,
                    selectedWorkoutTemplate: $selectedWorkoutTemplate,
                    selectedExerciseTemplate: $selectedExerciseTemplate,
                    activeSheet: $programActiveSheet,
                    workoutToStart: $workoutToStart,
                    scheduledWorkoutToStart: $scheduledWorkoutToStart
                )
            case .workouts:
                WorkoutsView(isShowingInspector: $isShowingInspector, selectedWorkoutTemplate: $selectedWorkoutTemplate, selectedExerciseTemplate: $selectedExerciseTemplate, showCreateWorkout: $showCreateWorkout)
            case .exercises:
                ExercisesView(isShowingInspector: $isShowingInspector, selectedWorkoutTemplate: $selectedWorkoutTemplate, selectedExerciseTemplate: $selectedExerciseTemplate, showCreateExercise: $showCreateExercise)
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        
        // Today's workout quick action
        if presentationMode == .program, !trainingPlanManager.getTodaysWorkouts().isEmpty {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        do {
                            try await startTodaysWorkout()
                        } catch {
                            showAlert = AnyAppAlert(error: error)
                        }
                    }
                } label: {
                    Label("Start Workout", systemImage: "play.fill")
                }
                .buttonStyle(.glassProminent)
            }
        }
        
        ToolbarItem(placement: .topBarLeading) {
            Button {
                onNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
        }
//        #if os(iOS)
//        if UIDevice.current.userInterfaceIdiom != .phone {
//            ToolbarSpacer(placement: .topBarTrailing)
//            ToolbarItem(placement: .topBarTrailing) {
//                Button {
//                    isShowingInspector.toggle()
//                } label: {
//                    Image(systemName: "info")
//                }
//            }
//        }
//        #else
//        ToolbarSpacer(placement: .topBarTrailing)
//        ToolbarItem(placement: .topBarTrailing) {
//            Button {
//                isShowingInspector.toggle()
//            } label: {
//                Image(systemName: "info")
//            }
//        }
//        #endif
    }
    
    private func onNotificationsPressed() {
        showNotificationsView = true
    }
    
    private var navigationSubtitle: String {
        if presentationMode == .program, let plan = trainingPlanManager.currentTrainingPlan {
            let todaysWorkouts = trainingPlanManager.getTodaysWorkouts()
            if !todaysWorkouts.isEmpty {
                let completedCount = todaysWorkouts.filter { $0.isCompleted }.count
                if completedCount == todaysWorkouts.count {
                    return "\(plan.name) • Today's workout complete ✓"
                } else {
                    return "\(plan.name) • Workout scheduled for today"
                }
            }
            
            let upcomingCount = trainingPlanManager.getUpcomingWorkouts(limit: 1).count
            if upcomingCount > 0 {
                return "\(plan.name) • Next workout scheduled"
            } else {
                return plan.name
            }
        }
        return Date.now.formatted(date: .abbreviated, time: .omitted)
    }
    
    private func startTodaysWorkout() async throws {
        let todaysWorkouts = trainingPlanManager.getTodaysWorkouts()
        guard let firstIncomplete = todaysWorkouts.first(where: { !$0.isCompleted }) else { return }
        
        let template = try await workoutTemplateManager.getWorkoutTemplate(id: firstIncomplete.workoutTemplateId)
        
        // Store scheduled workout reference for WorkoutStartView
        scheduledWorkoutToStart = firstIncomplete
        
        // Small delay to ensure any pending presentations complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Show WorkoutStartView (preview, notes, etc.)
        workoutToStart = template
    }
}

#Preview {
    TrainingView()
        .previewEnvironment()
}

// Reuse the compact-only inspector modifier from NutritionView
private struct InspectorIfCompact<InspectorContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let inspector: () -> InspectorContent
    let enabled: Bool

    func body(content: Content) -> some View {
        Group {
            if enabled {
                content
                    .inspector(isPresented: $isPresented) { self.inspector() }
            } else {
                content
            }
        }
    }
}
