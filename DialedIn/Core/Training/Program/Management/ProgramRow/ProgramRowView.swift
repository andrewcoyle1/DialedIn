//
//  ProgramRowView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct ProgramRowView: View {
    @State var viewModel: ProgramRowViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.plan.name)
                        .font(.headline)
                    
                    if let description = viewModel.plan.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                if viewModel.isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title3)
                }
            }
            
            // Stats
            HStack(spacing: 16) {
                if viewModel.plan.endDate != nil {
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
                    text: "\(viewModel.totalWorkouts) workouts"
                )
                
                if viewModel.plan.isActive {
                    StatLabel(
                        icon: "checkmark.circle",
                        text: "\(Int(viewModel.plan.adherenceRate * 100))%"
                    )
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            
            // Dates
            HStack {
                Text("Started \(viewModel.plan.startDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if let endDate = viewModel.plan.endDate {
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text("Ends \(endDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Actions
            HStack(spacing: 12) {
                if !viewModel.isActive {
                    Button {
                        viewModel.onActivate()
                    } label: {
                        Label("Set Active", systemImage: "checkmark.circle")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                }
                
                Button {
                    viewModel.onEdit()
                } label: {
                    Label("Edit", systemImage: "pencil")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                
                Button(role: .destructive) {
                    viewModel.onDelete()
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
    List {
        ProgramRowView(
            viewModel: ProgramRowViewModel(
                interactor: CoreInteractor(container: DevPreview.shared.container),
                plan: TrainingPlan.mock,
                isActive: false
            ) {
                
            } onEdit: {
                
            } onDelete: {
                
            }
        )
    }
    .previewEnvironment()
}
