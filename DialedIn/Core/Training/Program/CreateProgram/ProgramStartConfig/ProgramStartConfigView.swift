//
//  ProgramStartConfigView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct ProgramStartConfigView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss
    
    @State var viewModel: ProgramStartConfigViewModel

    @Binding var path: [TabBarPathOption]

    let template: ProgramTemplateModel
    let onStart: (Date, Date?, String?) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                programSection
                configurationSection
                previewSection
            }
            .navigationTitle("Start Program")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .onAppear {
                // Initialize end date to default value based on template duration
                viewModel.endDate = viewModel.calculateDefaultEndDate(template: template, from: viewModel.startDate)
            }
        }
    }
    
    private var programSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text(template.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(template.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)
        } header: {
            Text("Program")
        }
    }
    
    private var configurationSection: some View {
        Section {
            DatePicker("Start Date", selection: $viewModel.startDate, displayedComponents: .date)
                .onChange(of: viewModel.startDate) { _, newValue in
                    // Update end date to maintain duration when start date changes
                    if !viewModel.hasEndDate {
                        viewModel.endDate = viewModel.calculateDefaultEndDate(template: template, from: newValue)
                    }
                }
            
            Toggle("Set End Date", isOn: $viewModel.hasEndDate)
            
            if viewModel.hasEndDate {
                DatePicker("End Date", selection: $viewModel.endDate, in: viewModel.startDate..., displayedComponents: .date)
            }
            
            Toggle("Custom Name", isOn: $viewModel.useCustomName)
            
            if viewModel.useCustomName {
                TextField("Program Name", text: $viewModel.customName)
            }
        } header: {
            Text("Configuration")
        } footer: {
            if viewModel.hasEndDate {
                let weeks = viewModel.calculateWeeks(from: viewModel.startDate, to: viewModel.endDate)
                Text("Custom duration: \(weeks) week\(weeks == 1 ? "" : "s"). Only workouts within this range will be scheduled.")
            } else {
                Text("This program will run for \(template.duration) weeks from your start date.")
            }
        }
    }
    
    private var previewSection: some View {
        Section {
            ForEach(template.weekTemplates.prefix(1), id: \.weekNumber) { week in
                VStack(alignment: .leading, spacing: 8) {
                    Text("Week 1 Schedule")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    ForEach(week.workoutSchedule) { mapping in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(viewModel.dayName(for: mapping.dayOfWeek))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(viewModel.calculatedDate(for: mapping.dayOfWeek).formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption2)
                                    .foregroundStyle(.blue)
                            }
                            Spacer()
                            Text("Workout")
                                .font(.caption)
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            
            Button {
                viewModel.navToProgramPreviewView(path: $path, template: template)
            } label: {
                Label("View Full Schedule", systemImage: "calendar")
                    .font(.subheadline)
            }
        } header: {
            Text("Preview")
        } footer: {
            Text("Workouts will be scheduled on or after your start date on the specified days of the week.")
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                dismiss()
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button("Start") {
                let name = viewModel.useCustomName && !viewModel.customName.isEmpty ? viewModel.customName : nil
                let finalEndDate = viewModel.hasEndDate ? viewModel.endDate : nil
                onStart(viewModel.startDate, finalEndDate, name)
            }
        }
    }
}

#Preview {
    @Previewable @State var path: [TabBarPathOption] = []
    NavigationStack {
        ProgramStartConfigView(
            viewModel: ProgramStartConfigViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            ),
            path: $path,
            template: ProgramTemplateModel.mock,
            onStart: { _, _, _ in

            }
        )
    }
    .previewEnvironment()
}
