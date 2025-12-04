//
//  ProgramPreviewView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct ProgramPreviewView: View {
    @State var presenter: ProgramPreviewPresenter
    @State private var previewPlan: TrainingPlan?
    
    init(presenter: ProgramPreviewPresenter, delegate: ProgramPreviewDelegate) {
        self.presenter = presenter
        self.presenter.setTemplate(delegate.template)
        self.presenter.setStartDate(delegate.startDate)
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Start Date")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(presenter.currentStartDate.formatted(date: .long, time: .omitted))
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
                                        Text(presenter.dayOfWeekName(for: date))
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
            presenter.generatePreview()
        }
        .onChange(of: presenter.currentStartDate) { _, _ in
            presenter.generatePreview()
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.programPreviewView(
            router: router, 
            delegate: ProgramPreviewDelegate(
                template: .pushPullLegs,
                startDate: Date()
            )
        )
    }
    .previewEnvironment()
}
