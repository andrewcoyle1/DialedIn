//
//  ProgramRow.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct ProgramRow: View {
    let plan: TrainingPlan
    let isActive: Bool
    let onActivate: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.name)
                        .font(.headline)
                    
                    if let description = plan.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title3)
                }
            }
            
            // Stats
            HStack(spacing: 16) {
                if plan.endDate != nil {
                    StatLabel(
                        icon: "calendar",
                        text: "\(programDuration) weeks"
                    )
                } else {
                    StatLabel(
                        icon: "calendar",
                        text: "Ongoing"
                    )
                }
                
                StatLabel(
                    icon: "figure.strengthtraining.traditional",
                    text: "\(totalWorkouts) workouts"
                )
                
                if plan.isActive {
                    StatLabel(
                        icon: "checkmark.circle",
                        text: "\(Int(plan.adherenceRate * 100))%"
                    )
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            
            // Dates
            HStack {
                Text("Started \(plan.startDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if let endDate = plan.endDate {
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text("Ends \(endDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Actions
            HStack(spacing: 12) {
                if !isActive {
                    Button {
                        onActivate()
                    } label: {
                        Label("Set Active", systemImage: "checkmark.circle")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                }
                
                Button {
                    onEdit()
                } label: {
                    Label("Edit", systemImage: "pencil")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var programDuration: Int {
        guard let endDate = plan.endDate else { return 0 }
        let calendar = Calendar.current
        let weeks = calendar.dateComponents([.weekOfYear], from: plan.startDate, to: endDate).weekOfYear ?? 0
        return max(weeks, 0)
    }
    
    private var totalWorkouts: Int {
        plan.weeks.flatMap { $0.scheduledWorkouts }.count
    }
}

#Preview {
    ProgramRow(plan: TrainingPlan.mock, isActive: false) {
        
    } onEdit: {
        
    } onDelete: {
        
    }
    .previewEnvironment()
}
