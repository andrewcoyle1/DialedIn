//
//  ProgramStartConfigView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct ProgramStartConfigView: View {
    @Environment(\.dismiss) private var dismiss
    let template: ProgramTemplateModel
    let onStart: (Date, String?) -> Void
    
    @State private var startDate = Date()
    @State private var useCustomName = false
    @State private var customName = ""
    
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
            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
            
            Toggle("Custom Name", isOn: $useCustomName)
            
            if useCustomName {
                TextField("Program Name", text: $customName)
            }
        } header: {
            Text("Configuration")
        } footer: {
            Text("This program will run for \(template.duration) weeks from your start date.")
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
                                Text(dayName(for: mapping.dayOfWeek))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(calculatedDate(for: mapping.dayOfWeek).formatted(date: .abbreviated, time: .omitted))
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
            
            NavigationLink {
                ProgramPreviewView(template: template, startDate: startDate)
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
                let name = useCustomName && !customName.isEmpty ? customName : nil
                onStart(startDate, name)
            }
        }
    }
    
    private func dayName(for dayOfWeek: Int) -> String {
        let calendar = Calendar.current
        let weekdaySymbols = calendar.weekdaySymbols
        let index = (dayOfWeek - 1) % 7
        return weekdaySymbols[index]
    }
    
    private func calculatedDate(for dayOfWeek: Int) -> Date {
        let calendar = Calendar.current
        let currentDayOfWeek = calendar.component(.weekday, from: startDate)
        
        // If start date is the target day, return start date
        if currentDayOfWeek == dayOfWeek {
            return startDate
        }
        
        // Calculate days to add
        var daysToAdd = dayOfWeek - currentDayOfWeek
        if daysToAdd < 0 {
            daysToAdd += 7 // Move to next week
        }
        
        return calendar.date(byAdding: .day, value: daysToAdd, to: startDate) ?? startDate
    }
}

#Preview {
    NavigationStack {
        ProgramStartConfigView(
            template: ProgramTemplateModel.mock, onStart: { _, _ in
                
            }
        )
    }
    .previewEnvironment()
}
