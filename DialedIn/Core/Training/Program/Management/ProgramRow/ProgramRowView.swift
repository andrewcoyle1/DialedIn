//
//  ProgramRowView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct ProgramRowViewDelegate {
    let plan: TrainingPlan
    let isActive: Bool
    var onActivate: () -> Void = {}
    var onEdit: () -> Void = {}
    var onDelete: () -> Void = {}
}

struct ProgramRowView: View {
    @State var viewModel: ProgramRowViewModel

    let delegate: ProgramRowViewDelegate

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(delegate.plan.name)
                        .font(.headline)
                    
                    if let description = delegate.plan.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                if delegate.isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title3)
                }
            }
            
            // Stats
            HStack(spacing: 16) {
                if delegate.plan.endDate != nil {
                    StatLabel(
                        icon: "calendar",
                        text: "\(viewModel.programDuration) weeks"
                    )
                } else {
                    StatLabel(
                        icon: "calendar",
                        text: "Ongoing"
                    )
                }
                
                StatLabel(
                    icon: "figure.strengthtraining.traditional",
                    text: "\(viewModel.totalWorkouts(plan: delegate.plan)) workouts"
                )
                
                if delegate.plan.isActive {
                    StatLabel(
                        icon: "checkmark.circle",
                        text: "\(Int(delegate.plan.adherenceRate * 100))%"
                    )
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            
            // Dates
            HStack {
                Text("Started \(delegate.plan.startDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if let endDate = delegate.plan.endDate {
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text("Ends \(endDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Actions
            HStack(spacing: 12) {
                if !delegate.isActive {
                    Button {
                        delegate.onActivate()
                    } label: {
                        Label("Set Active", systemImage: "checkmark.circle")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                }
                
                Button {
                    delegate.onEdit()
                } label: {
                    Label("Edit", systemImage: "pencil")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                
                Button(role: .destructive) {
                    delegate.onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    List {
        builder.programRowView(
            delegate: ProgramRowViewDelegate(
                plan: .mock,
                isActive: false,
                onActivate: {

                }, onEdit: {

                }, onDelete: {

                }
            )
        )
    }
    .previewEnvironment()
}
