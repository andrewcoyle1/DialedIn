//
//  TrainingView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI

struct TrainingView: View {
    
    @State private var presentationMode: PresentationMode = .exercises
    @State private var showDebugView: Bool = false
    
    enum PresentationMode {
        case workouts
        case exercises
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                switch presentationMode {
                case .workouts:
                    WorkoutsView()
                case .exercises:
                    ExerciseView()
                }
            }
            .navigationTitle("Training")
            .navigationSubtitle(Date.now.formatted(date: .abbreviated, time: .omitted))
            .toolbar {
                #if DEBUG || MOCK
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showDebugView = true
                    } label: {
                        Image(systemName: "info")
                    }
                }
                #endif
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Mode", selection: $presentationMode) {
                            Text("Workouts").tag(PresentationMode.workouts)
                            Text("Exercises").tag(PresentationMode.exercises)
                        }
                    } label: {
                        Label("Section", systemImage: "line.3.horizontal.decrease")
                    }
                    
                }
            }
            #if DEBUG || MOCK
            .sheet(isPresented: $showDebugView) {
                DevSettingsView()
            }
            #endif
        }
    }
    
    private var pickerSection: some View {
        Section {
            Picker("Section", selection: $presentationMode) {
                Text("Workouts").tag(PresentationMode.workouts)
                Text("Workouts").tag(PresentationMode.exercises)
            }
            .pickerStyle(.segmented)
        }
        .listSectionSpacing(0)
        .removeListRowFormatting()
    }
}

#Preview {
    TrainingView()
        .previewEnvironment()
}
