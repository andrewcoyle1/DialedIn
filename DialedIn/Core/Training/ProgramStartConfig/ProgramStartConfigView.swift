//
//  ProgramStartConfigView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct ProgramStartConfigView: View {
    
    @State var presenter: ProgramStartConfigPresenter

    var delegate: ProgramStartConfigDelegate

    var body: some View {
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
            presenter.endDate = presenter.calculateDefaultEndDate(template: delegate.template, from: presenter.startDate)
        }
    }
    
    private var programSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text(delegate.template.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(delegate.template.description)
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
            DatePicker("Start Date", selection: $presenter.startDate, displayedComponents: .date)
                .onChange(of: presenter.startDate) { _, newValue in
                    // Update end date to maintain duration when start date changes
                    if !presenter.hasEndDate {
                        presenter.endDate = presenter.calculateDefaultEndDate(template: delegate.template, from: newValue)
                    }
                }
            
            Toggle("Set End Date", isOn: $presenter.hasEndDate)
            
            if presenter.hasEndDate {
                DatePicker("End Date", selection: $presenter.endDate, in: presenter.startDate..., displayedComponents: .date)
            }
            
            Toggle("Custom Name", isOn: $presenter.useCustomName)
            
            if presenter.useCustomName {
                TextField("Program Name", text: $presenter.customName)
            }
        } header: {
            Text("Configuration")
        } footer: {
            if presenter.hasEndDate {
                let weeks = presenter.calculateWeeks(from: presenter.startDate, to: presenter.endDate)
                Text("Custom duration: \(weeks) week\(weeks == 1 ? "" : "s"). Only workouts within this range will be scheduled.")
            } else {
                Text("This program will run for \(delegate.template.duration) weeks from your start date.")
            }
        }
    }
    
    private var previewSection: some View {
        Section {
            ForEach(delegate.template.weekTemplates.prefix(1), id: \.weekNumber) { week in
                VStack(alignment: .leading, spacing: 8) {
                    Text("Week 1 Schedule")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    ForEach(week.workoutSchedule) { mapping in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(presenter.dayName(for: mapping.dayOfWeek))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(presenter.calculatedDate(for: mapping.dayOfWeek).formatted(date: .abbreviated, time: .omitted))
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
                presenter.navToProgramPreviewView(template: delegate.template)
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
                presenter.onDismissPressed()
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button("Start") {
                presenter.onStart(onStart: delegate.onStart)
            }
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.programStartConfigView(
            router: router, 
            delegate: ProgramStartConfigDelegate(
                template: ProgramTemplateModel.mock,
                onStart: { _, _, _ in
                    
                }
            )
        )
        .previewEnvironment()
    }
}
