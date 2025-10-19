//
//  ProgramPreviewView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct ProgramPreviewView: View {
    let template: ProgramTemplateModel
    let startDate: Date
    
    @State private var previewPlan: TrainingPlan?
    @Environment(ProgramTemplateManager.self) private var programTemplateManager
    @Environment(AuthManager.self) private var authManager
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Start Date")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(startDate.formatted(date: .long, time: .omitted))
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
                                        Text(dayOfWeekName(for: date))
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
            generatePreview()
        }
        .onChange(of: startDate) { _, _ in
            generatePreview()
        }
    }
    
    private func generatePreview() {
        guard let userId = authManager.auth?.uid else { return }
        
        previewPlan = programTemplateManager.instantiateTemplate(
            template,
            for: userId,
            startDate: startDate,
            planName: nil
        )
    }
    
    private func dayOfWeekName(for date: Date) -> String {
        date.formatted(.dateTime.weekday(.wide))
    }
}

#Preview {
    NavigationStack {
        ProgramPreviewView(
            template: .pushPullLegs,
            startDate: Date()
        )
    }
    .previewEnvironment()
}
