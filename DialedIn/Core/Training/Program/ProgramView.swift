//
//  ProgramView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 14/10/2025.
//

import SwiftUI

struct ProgramView: View {
    
    @Binding var isShowingInspector: Bool
    @Binding var selectedWorkoutTemplate: WorkoutTemplateModel?
    @Binding var selectedExerciseTemplate: ExerciseTemplateModel?

    var body: some View {
        Group {
            listContents
            
        }
    }
    
    private var listContents: some View {
        Section {
            HistoryChart(series: TimeSeriesData.last30Days)
        } header: {
            Text("Header")
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
