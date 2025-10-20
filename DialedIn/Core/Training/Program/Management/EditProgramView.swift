//
//  EditProgramView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct EditProgramView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TrainingPlanManager.self) private var trainingPlanManager
    @Environment(ProgramTemplateManager.self) private var programTemplateManager
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager
    
    let plan: TrainingPlan
    
    @State private var name: String
    @State private var description: String
    @State private var startDate: Date
    @State private var endDate: Date?
    @State private var hasEndDate: Bool
    @State private var isSaving = false
    @State private var showDateChangeAlert = false
    @State private var showDeleteActiveAlert = false
    @State private var pendingStartDate: Date?
    
    private let originalStartDate: Date
    
    init(plan: TrainingPlan) {
        self.plan = plan
        self.originalStartDate = plan.startDate
        _name = State(initialValue: plan.name)
        _description = State(initialValue: plan.description ?? "")
        _startDate = State(initialValue: plan.startDate)
        _endDate = State(initialValue: plan.endDate)
        _hasEndDate = State(initialValue: plan.endDate != nil)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Program Name", text: $name)
                    
                    TextField("Description (Optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Basic Information")
                }
                
                Section {
                    DatePicker("Start Date", selection: Binding(
                        get: { startDate },
                        set: { newDate in
                            if !plan.weeks.flatMap({ $0.scheduledWorkouts }).isEmpty && newDate != originalStartDate {
                                pendingStartDate = newDate
                                showDateChangeAlert = true
                            } else {
                                startDate = newDate
                            }
                        }
                    ), displayedComponents: .date)
                    
                    Toggle("Set End Date", isOn: $hasEndDate)
                    
                    if hasEndDate {
                        DatePicker("End Date", selection: Binding(
                            get: { endDate ?? startDate },
                            set: { endDate = $0 }
                        ), displayedComponents: .date)
                    }
                } header: {
                    Text("Schedule")
                } footer: {
                    VStack(alignment: .leading, spacing: 4) {
                        if !hasEndDate {
                            Text("Program will continue indefinitely")
                        }
                        if startDate != originalStartDate {
                            Text("Changing the start date will automatically reschedule all workouts")
                                .foregroundStyle(.orange)
                        }
                    }
                }
                
                Section {
                    HStack {
                        Text("Duration")
                        Spacer()
                        if hasEndDate, let end = endDate {
                            Text("\(calculateWeeks(from: startDate, to: end)) weeks")
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Ongoing")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Scheduled Weeks")
                        Spacer()
                        Text("\(plan.weeks.count)")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Total Workouts")
                        Spacer()
                        Text("\(totalWorkouts)")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Completed")
                        Spacer()
                        Text("\(completedWorkouts)")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Statistics")
                } footer: {
                    if hasEndDate, let end = endDate, startDate != originalStartDate || end != plan.endDate {
                        Text("Program duration will be adjusted based on new dates")
                            .foregroundStyle(.blue)
                    }
                }
                
                Section {
                    NavigationLink {
                        ProgramGoalsView(plan: plan)
                    } label: {
                        HStack {
                            Label("Manage Goals", systemImage: "target")
                            Spacer()
                            Text("\(plan.goals.count)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    NavigationLink {
                        ProgramScheduleView(plan: plan)
                    } label: {
                        Label("View Schedule", systemImage: "calendar")
                    }
                } header: {
                    Text("Details")
                }
                
                if plan.isActive {
                    Section {
                        Button(role: .destructive) {
                            showDeleteActiveAlert = true
                        } label: {
                            Label("Delete Program", systemImage: "trash")
                        }
                    } footer: {
                        Text("This is your active program. Deleting it will remove all scheduled workouts and progress tracking.")
                    }
                }
            }
            .navigationTitle("Edit Program")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await savePlan()
                        }
                    }
                    .disabled(name.isEmpty || isSaving)
                }
            }
            .overlay {
                if isSaving {
                    ProgressView()
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .alert("Reschedule Workouts", isPresented: $showDateChangeAlert) {
                Button("Cancel", role: .cancel) {
                    pendingStartDate = nil
                }
                Button("Reschedule") {
                    if let newDate = pendingStartDate {
                        startDate = newDate
                        pendingStartDate = nil
                    }
                }
            } message: {
                Text("This program has scheduled workouts. Changing the start date will automatically reschedule all workouts. Do you want to continue?")
            }
            .alert("Delete Active Program", isPresented: $showDeleteActiveAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await deleteActivePlan()
                    }
                }
            } message: {
                Text("Are you sure you want to delete your active program '\(plan.name)'? This will remove all scheduled workouts and you'll need to create or select a new program.")
            }
        }
    }
    
    private var totalWorkouts: Int {
        plan.weeks.flatMap { $0.scheduledWorkouts }.count
    }
    
    private var completedWorkouts: Int {
        plan.weeks.flatMap { $0.scheduledWorkouts }.filter { $0.isCompleted }.count
    }
    
    private func calculateWeeks(from startDate: Date, to endDate: Date) -> Int {
        let calendar = Calendar.current
        let weeks = calendar.dateComponents([.weekOfYear], from: startDate, to: endDate).weekOfYear ?? 0
        return max(weeks, 0)
    }
    
    private func deleteActivePlan() async {
        isSaving = true
        defer { isSaving = false }
        
        do {
            try await trainingPlanManager.deletePlan(id: plan.planId)
            dismiss()
        } catch {
            print("Error deleting active plan: \(error)")
        }
    }
    
    private func savePlan() async {
        isSaving = true
        defer { isSaving = false }
        
        // Check if start date changed and we need to reschedule workouts
        var updatedWeeks = plan.weeks
        if startDate != originalStartDate {
            updatedWeeks = rescheduleWorkouts(weeks: plan.weeks, oldStartDate: originalStartDate, newStartDate: startDate)
        }
        
        // Handle end date changes
        let originalEndDate = plan.endDate
        let newEndDate = hasEndDate ? endDate : nil
        
        // Adjust end date if start date changed (maintain duration)
        var adjustedEndDate = newEndDate
        if hasEndDate, let currentEndDate = endDate, startDate != originalStartDate {
            let calendar = Calendar.current
            let daysDifference = calendar.dateComponents([.day], from: originalStartDate, to: startDate).day ?? 0
            adjustedEndDate = calendar.date(byAdding: .day, value: daysDifference, to: currentEndDate)
        }
        
        // Handle end date extension/shortening
        if adjustedEndDate != originalEndDate {
            if let newEnd = adjustedEndDate {
                // Check if extending or shortening
                if let oldEnd = originalEndDate, newEnd > oldEnd {
                    // Extending: Add more workouts from template if available
                    do {
                        updatedWeeks = try await extendProgramSchedule(
                            weeks: updatedWeeks,
                            startDate: startDate,
                            oldEndDate: oldEnd,
                            newEndDate: newEnd,
                            programTemplateId: plan.programTemplateId
                        )
                    } catch {
                        print("Error extending program schedule: \(error)")
                    }
                } else {
                    // Shortening or setting for first time: Filter out future workouts
                    updatedWeeks = filterWorkoutsByEndDate(weeks: updatedWeeks, endDate: newEnd)
                }
            }
            // If newEndDate is nil, keep all workouts (no end date = indefinite)
        }
        
        let updatedPlan = TrainingPlan(
            planId: plan.planId,
            userId: plan.userId,
            name: name,
            description: description.isEmpty ? nil : description,
            startDate: startDate,
            endDate: adjustedEndDate,
            isActive: plan.isActive,
            programTemplateId: plan.programTemplateId,
            weeks: updatedWeeks,
            goals: plan.goals,
            createdAt: plan.createdAt,
            modifiedAt: .now
        )
        
        do {
            try await trainingPlanManager.updatePlan(updatedPlan)
            dismiss()
        } catch {
            print("Error updating plan: \(error)")
        }
    }
    
    private func rescheduleWorkouts(weeks: [TrainingWeek], oldStartDate: Date, newStartDate: Date) -> [TrainingWeek] {
        let calendar = Calendar.current
        let daysDifference = calendar.dateComponents([.day], from: oldStartDate, to: newStartDate).day ?? 0
        
        return weeks.map { week in
            let updatedWorkouts = week.scheduledWorkouts.map { workout in
                var updatedWorkout = workout
                if let oldDate = workout.scheduledDate,
                   let newDate = calendar.date(byAdding: .day, value: daysDifference, to: oldDate) {
                    updatedWorkout = ScheduledWorkout(
                        id: workout.id,
                        workoutTemplateId: workout.workoutTemplateId,
                        workoutName: workout.workoutName,
                        dayOfWeek: calendar.component(.weekday, from: newDate),
                        scheduledDate: newDate,
                        completedSessionId: workout.completedSessionId,
                        isCompleted: workout.isCompleted,
                        notes: workout.notes
                    )
                }
                return updatedWorkout
            }
            
            return TrainingWeek(
                weekNumber: week.weekNumber,
                scheduledWorkouts: updatedWorkouts,
                notes: week.notes
            )
        }
    }
    
    private func filterWorkoutsByEndDate(weeks: [TrainingWeek], endDate: Date) -> [TrainingWeek] {
        return weeks.map { week in
            let filteredWorkouts = week.scheduledWorkouts.filter { workout in
                // Keep completed workouts regardless of date
                if workout.isCompleted {
                    return true
                }
                // Filter future workouts by end date
                guard let scheduledDate = workout.scheduledDate else {
                    return true
                }
                return scheduledDate <= endDate
            }
            
            return TrainingWeek(
                weekNumber: week.weekNumber,
                scheduledWorkouts: filteredWorkouts,
                notes: week.notes
            )
        }.filter { !$0.scheduledWorkouts.isEmpty || $0.notes != nil }
    }
    
    private func extendProgramSchedule(
        weeks: [TrainingWeek],
        startDate: Date,
        oldEndDate: Date,
        newEndDate: Date,
        programTemplateId: String?
    ) async throws -> [TrainingWeek] {
        // If no template, can't auto-extend
        guard let templateId = programTemplateId,
              let template = programTemplateManager.get(id: templateId) else {
            return weeks
        }
        
        // Find the highest week number currently scheduled
        let maxScheduledWeek = weeks.map { $0.weekNumber }.max() ?? 0
        
        // Get weeks from template that haven't been scheduled yet
        let additionalWeeks = template.weekTemplates.filter { $0.weekNumber > maxScheduledWeek }
        
        var updatedWeeks = weeks
        
        // Schedule additional weeks that fall within the new date range
        for weekTemplate in additionalWeeks {
            let scheduledWorkouts: [ScheduledWorkout] = weekTemplate.workoutSchedule.compactMap { mapping -> ScheduledWorkout? in
                let weekOffset = weekTemplate.weekNumber - 1
                let scheduledDate = calculateScheduleDate(
                    startDate: startDate,
                    weekOffset: weekOffset,
                    dayOfWeek: mapping.dayOfWeek
                )
                
                // Only schedule if within new end date
                guard scheduledDate <= newEndDate else {
                    return nil
                }
                
                // Fetch workout name
                let workoutName: String? = mapping.workoutName ?? {
                    if let template = try? workoutTemplateManager.getLocalWorkoutTemplate(id: mapping.workoutTemplateId) {
                        return template.name
                    }
                    return nil
                }()
                
                return ScheduledWorkout(
                    workoutTemplateId: mapping.workoutTemplateId,
                    workoutName: workoutName,
                    dayOfWeek: mapping.dayOfWeek,
                    scheduledDate: scheduledDate
                )
            }
            
            // Only add week if it has workouts
            if !scheduledWorkouts.isEmpty {
                updatedWeeks.append(TrainingWeek(
                    weekNumber: weekTemplate.weekNumber,
                    scheduledWorkouts: scheduledWorkouts,
                    notes: weekTemplate.notes
                ))
            }
        }
        
        return updatedWeeks.sorted { $0.weekNumber < $1.weekNumber }
    }
    
    private func calculateScheduleDate(startDate: Date, weekOffset: Int, dayOfWeek: Int) -> Date {
        let calendar = Calendar.current
        
        // For week 1, find the first occurrence of this day of week on or after start date
        if weekOffset == 0 {
            return findNextDayOfWeek(dayOfWeek, onOrAfter: startDate)
        }
        
        // For subsequent weeks, calculate from the first week's anchor
        let week1Date = findNextDayOfWeek(dayOfWeek, onOrAfter: startDate)
        guard let targetDate = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: week1Date) else {
            return startDate
        }
        
        return targetDate
    }
    
    private func findNextDayOfWeek(_ targetDayOfWeek: Int, onOrAfter date: Date) -> Date {
        let calendar = Calendar.current
        let currentDayOfWeek = calendar.component(.weekday, from: date)
        
        if currentDayOfWeek == targetDayOfWeek {
            return date
        }
        
        var daysToAdd = targetDayOfWeek - currentDayOfWeek
        if daysToAdd < 0 {
            daysToAdd += 7
        }
        
        guard let targetDate = calendar.date(byAdding: .day, value: daysToAdd, to: date) else {
            return date
        }
        
        return targetDate
    }
}

#Preview {
    EditProgramView(plan: TrainingPlan.mock)
        .previewEnvironment()
}
