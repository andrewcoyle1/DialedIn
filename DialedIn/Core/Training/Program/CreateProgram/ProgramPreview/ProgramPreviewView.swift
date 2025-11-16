//
//  ProgramPreviewView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct ProgramPreviewViewDelegate {
    let template: ProgramTemplateModel
    var startDate: Date
}

struct ProgramPreviewView: View {
    @State var viewModel: ProgramPreviewViewModel
    @State private var previewPlan: TrainingPlan?
    
    init(viewModel: ProgramPreviewViewModel, delegate: ProgramPreviewViewDelegate) {
        self.viewModel = viewModel
        self.viewModel.setTemplate(delegate.template)
        self.viewModel.setStartDate(delegate.startDate)
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Start Date")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(viewModel.currentStartDate.formatted(date: .long, time: .omitted))
                    }
                    .font(.subheadline)
                }
            } header: {
                Text("Program Details")
            }
            
            if let plan = previewPlan {
                ForEach(plan.weeks.prefix(2)) { week in
                    Section {
                        ForEach(week.scheduledWorkouts) { workout in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Workout")
                                        .font(.subheadline)
                                    if let date = workout.scheduledDate {
                                        Text(date.formatted(date: .complete, time: .omitted))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text(viewModel.dayOfWeekName(for: date))
                                            .font(.caption2)
                                            .foregroundStyle(.blue)
                                    }
                                }
                                Spacer()
                            }
                        }
                    } header: {
                        Text("Week \(week.weekNumber)")
                    }
                }
            }
        }
        .navigationTitle("Schedule Preview")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.generatePreview()
        }
        .onChange(of: viewModel.currentStartDate) { _, _ in
            viewModel.generatePreview()
        }
    }
}

#Preview {
    NavigationStack {
        ProgramPreviewView(
            viewModel: ProgramPreviewViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)),
            template: .pushPullLegs,
            startDate: Date()
        )
    }
    .previewEnvironment()
}
