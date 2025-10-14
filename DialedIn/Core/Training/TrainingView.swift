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

    enum TrainingPresentationMode {
        case program
        case workouts
        case exercises
    }
    
    var body: some View {
        NavigationStack {
            List {
                pickerSection
                listContents
            }
            .navigationTitle("Training")
            .navigationSubtitle(Date.now.formatted(date: .abbreviated, time: .omitted))
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .scrollIndicators(.hidden)
            .showCustomAlert(alert: $showAlert)
            .toolbar {
                toolbarContent
            }
            #if DEBUG || MOCK
            .sheet(isPresented: $showDebugView) {
                DevSettingsView()
            }
            #endif
            .sheet(isPresented: $showNotificationsView) {
                NotificationsView()
            }
        }
        .inspector(isPresented: $isShowingInspector) {
            Group {
                if let exercise = selectedExerciseTemplate {
                    NavigationStack {
                        ExerciseDetailView(exerciseTemplate: exercise)
                    }
                } else if let workout = selectedWorkoutTemplate {
                    NavigationStack {
                        WorkoutTemplateDetailView(workoutTemplate: workout)
                    }
                } else {
                    Text("Select an item")
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
            .inspectorColumnWidth(min: 300, ideal: 400, max: 600)
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
                ProgramView(isShowingInspector: $isShowingInspector, selectedWorkoutTemplate: $selectedWorkoutTemplate, selectedExerciseTemplate: $selectedExerciseTemplate)
            case .workouts:
                WorkoutsView(isShowingInspector: $isShowingInspector, selectedWorkoutTemplate: $selectedWorkoutTemplate, selectedExerciseTemplate: $selectedExerciseTemplate)
            case .exercises:
                ExercisesView(isShowingInspector: $isShowingInspector, selectedWorkoutTemplate: $selectedWorkoutTemplate, selectedExerciseTemplate: $selectedExerciseTemplate)
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

        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom != .phone {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingInspector.toggle()
                } label: {
                    Image(systemName: "info")
                }
            }
        }
        #else
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isShowingInspector.toggle()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                onNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
        }
    }
    
    private func onNotificationsPressed() {
        showNotificationsView = true
    }
}

#Preview {
    TrainingView()
        .previewEnvironment()
}
