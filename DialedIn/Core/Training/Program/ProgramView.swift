//
//  ProgramView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 14/10/2025.
//

import SwiftUI

struct ProgramView: View {
    
    @Environment(TrainingPlanManager.self) private var trainingPlanManager
    
    @Binding var isShowingInspector: Bool
    @Binding var selectedWorkoutTemplate: WorkoutTemplateModel?
    @Binding var selectedExerciseTemplate: ExerciseTemplateModel?

    @State private var isShowingCalendar: Bool = true
    @State private var collapsedSubtitle: String = "No sessions planned yet — tap to plan"
    
    var body: some View {
        listContents
    }
    
    private var listContents: some View {
        Group {
            calendarSection
            chartSection
        }
    }
    
    private var calendarSection: some View {
        WorkoutCalendarView()
    }
    
    private var chartSection: some View {
        Section {
            HistoryChart(series: TimeSeriesData.last30Days)
        } header: {
            Text("Chart")
        }
    }
}

#Preview {
    List {
        ProgramView(isShowingInspector: Binding.constant(true),
                    selectedWorkoutTemplate: Binding.constant(nil),
                    selectedExerciseTemplate: Binding.constant(nil))
    }
    .previewEnvironment()
}
