//
//  EditProgramView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

@Observable
@MainActor
class EditProgramViewModel {
    private let workoutTemplateManager: WorkoutTemplateManager
    private let trainingPlanManager: TrainingPlanManager
    private let programTemplateManager: ProgramTemplateManager
    
    var name: String = ""
    var description: String = ""
    var startDate: Date = .now
    var endDate: Date?
    var hasEndDate: Bool = false
    private(set) var isSaving = false
    var showDateChangeAlert = false
    var showDeleteActiveAlert = false
    var pendingStartDate: Date?
    
    var originalStartDate: Date = .now
    
    init(
        container: DependencyContainer
    ) {
        self.workoutTemplateManager = container.resolve(WorkoutTemplateManager.self)!
        self.trainingPlanManager = container.resolve(TrainingPlanManager.self)!
        self.programTemplateManager = container.resolve(ProgramTemplateManager.self)!
        
        // Initialize with default values - will be set by the view
        self.name = ""
        self.description = ""
        self.startDate = .now
        self.endDate = nil
        self.hasEndDate = false
        self.originalStartDate = .now
    }
    
    func totalWorkouts(for plan: TrainingPlan) -> Int {
        plan.weeks.flatMap { $0.scheduledWorkouts }.count
    }
    
    func completedWorkouts(for plan: TrainingPlan) -> Int {
        plan.weeks.flatMap { $0.scheduledWorkouts }.filter { $0.isCompleted }.count
    }
    
    func calculateWeeks(from startDate: Date, to endDate: Date) -> Int {
        let calendar = Calendar.current
        let weeks = calendar.dateComponents([.weekOfYear], from: startDate, to: endDate).weekOfYear ?? 0
        return max(weeks, 0)
    }
    
    func deleteActivePlan(plan: TrainingPlan, onDismiss: @escaping @MainActor () -> Void) async {
        isSaving = true
        defer { isSaving = false }
        
        do {
            try await trainingPlanManager.deletePlan(id: plan.planId)
            onDismiss()
        } catch {
            print("Error deleting active plan: \(error)")
        }
    }
    
    func savePlan(plan: TrainingPlan, onDismiss: @escaping @MainActor () -> Void) async {
        isSaving = true
        defer { isSaving = false }
        
        var updatedWeeks = plan.weeks
        if startDate != originalStartDate {
            updatedWeeks = rescheduleWorkouts(weeks: plan.weeks, oldStartDate: originalStartDate, newStartDate: startDate)
        }
        
        let adjustedEndDate = calculateAdjustedEndDate(originalEndDate: plan.endDate)
        updatedWeeks = await handleEndDateChanges(
            weeks: updatedWeeks,
            originalEndDate: plan.endDate,
            adjustedEndDate: adjustedEndDate,
            programTemplateId: plan.programTemplateId
        )
        
        let updatedPlan = createUpdatedPlan(from: plan, weeks: updatedWeeks, adjustedEndDate: adjustedEndDate)
        await sendUpdatedPlan(updatedPlan: updatedPlan, onDismiss: onDismiss)
    }
    
    private func calculateAdjustedEndDate(originalEndDate: Date?) -> Date? {
        let newEndDate = hasEndDate ? endDate : nil
        var adjustedEndDate = newEndDate
        
        if hasEndDate, let currentEndDate = endDate, startDate != originalStartDate {
            let calendar = Calendar.current
            let daysDifference = calendar.dateComponents([.day], from: originalStartDate, to: startDate).day ?? 0
            adjustedEndDate = calendar.date(byAdding: .day, value: daysDifference, to: currentEndDate)
        }
        
        return adjustedEndDate
    }
    
    private func handleEndDateChanges(
        weeks: [TrainingWeek],
        originalEndDate: Date?,
        adjustedEndDate: Date?,
        programTemplateId: String?
    ) async -> [TrainingWeek] {
        var updatedWeeks = weeks
        
        if adjustedEndDate != originalEndDate {
            if let newEnd = adjustedEndDate {
                if let oldEnd = originalEndDate, newEnd > oldEnd {
                    do {
                        updatedWeeks = try await extendProgramSchedule(
                            weeks: updatedWeeks,
                            startDate: startDate,
                            oldEndDate: oldEnd,
                            newEndDate: newEnd,
                            programTemplateId: programTemplateId
                        )
                    } catch {
                        print("Error extending program schedule: \(error)")
                    }
                } else {
                    updatedWeeks = filterWorkoutsByEndDate(weeks: updatedWeeks, endDate: newEnd)
                }
            }
        }
        
        return updatedWeeks
    }
    
    private func createUpdatedPlan(from plan: TrainingPlan, weeks: [TrainingWeek], adjustedEndDate: Date?) -> TrainingPlan {
        TrainingPlan(
            planId: plan.planId,
            userId: plan.userId,
            name: name,
            description: description.isEmpty ? nil : description,
            startDate: startDate,
            endDate: adjustedEndDate,
            isActive: plan.isActive,
            programTemplateId: plan.programTemplateId,
            weeks: weeks,
            goals: plan.goals,
            createdAt: plan.createdAt,
            modifiedAt: .now
        )
    }
    
    func sendUpdatedPlan(updatedPlan: TrainingPlan, onDismiss: @escaping @MainActor () -> Void) async {
        do {
            try await trainingPlanManager.updatePlan(updatedPlan)
            onDismiss()
        } catch {
            print("Error updating plan: \(error)")
        }
    }
    
    func rescheduleWorkouts(weeks: [TrainingWeek], oldStartDate: Date, newStartDate: Date) -> [TrainingWeek] {
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
    
    func filterWorkoutsByEndDate(weeks: [TrainingWeek], endDate: Date) -> [TrainingWeek] {
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
    
    func extendProgramSchedule(
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
    
    func calculateScheduleDate(startDate: Date, weekOffset: Int, dayOfWeek: Int) -> Date {
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
    
    func findNextDayOfWeek(_ targetDayOfWeek: Int, onOrAfter date: Date) -> Date {
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

struct EditProgramView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var viewModel: EditProgramViewModel
    
    let plan: TrainingPlan
    
    init(viewModel: EditProgramViewModel, plan: TrainingPlan) {
        self.viewModel = viewModel
        self.plan = plan
        self.viewModel.originalStartDate = plan.startDate
        self.viewModel.name = plan.name
        self.viewModel.description = plan.description ?? ""
        self.viewModel.startDate = plan.startDate
        self.viewModel.endDate = plan.endDate
        self.viewModel.hasEndDate = plan.endDate != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Program Name", text: $viewModel.name)
                    
                    TextField("Description (Optional)", text: $viewModel.description, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Basic Information")
                }
                
                Section {
                    DatePicker("Start Date", selection: Binding(
                        get: { viewModel.startDate },
                        set: { newDate in
                            if !plan.weeks.flatMap({ $0.scheduledWorkouts }).isEmpty && newDate != viewModel.originalStartDate {
                                viewModel.pendingStartDate = newDate
                                viewModel.showDateChangeAlert = true
                            } else {
                                viewModel.startDate = newDate
                            }
                        }
                    ), displayedComponents: .date)
                    
                    Toggle("Set End Date", isOn: $viewModel.hasEndDate)
                    
                    if viewModel.hasEndDate {
                        DatePicker("End Date", selection: Binding(
                            get: { viewModel.endDate ?? viewModel.startDate },
                            set: { viewModel.endDate = $0 }
                        ), displayedComponents: .date)
                    }
                } header: {
                    Text("Schedule")
                } footer: {
                    VStack(alignment: .leading, spacing: 4) {
                        if !viewModel.hasEndDate {
                            Text("Program will continue indefinitely")
                        }
                        if viewModel.startDate != viewModel.originalStartDate {
                            Text("Changing the start date will automatically reschedule all workouts")
                                .foregroundStyle(.orange)
                        }
                    }
                }
                
                Section {
                    HStack {
                        Text("Duration")
                        Spacer()
                        if viewModel.hasEndDate, let end = viewModel.endDate {
                            Text("\(viewModel.calculateWeeks(from: viewModel.startDate, to: end)) weeks")
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
                        Text("\(viewModel.totalWorkouts(for: plan))")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Completed")
                        Spacer()
                        Text("\(viewModel.completedWorkouts(for: plan))")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Statistics")
                } footer: {
                    if viewModel.hasEndDate, let end = viewModel.endDate, viewModel.startDate != viewModel.originalStartDate || end != plan.endDate {
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
                            viewModel.showDeleteActiveAlert = true
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
                            await viewModel.savePlan(plan: plan, onDismiss: {
                                dismiss()
                            })
                        }
                    }
                    .disabled(viewModel.name.isEmpty || viewModel.isSaving)
                }
            }
            .overlay {
                if viewModel.isSaving {
                    ProgressView()
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .alert("Reschedule Workouts", isPresented: $viewModel.showDateChangeAlert) {
                Button("Cancel", role: .cancel) {
                    viewModel.pendingStartDate = nil
                }
                Button("Reschedule") {
                    if let newDate = viewModel.pendingStartDate {
                        viewModel.startDate = newDate
                        viewModel.pendingStartDate = nil
                    }
                }
            } message: {
                Text("This program has scheduled workouts. Changing the start date will automatically reschedule all workouts. Do you want to continue?")
            }
            .alert("Delete Active Program", isPresented: $viewModel.showDeleteActiveAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteActivePlan(plan: plan, onDismiss: {
                            dismiss()
                        })
                    }
                }
            } message: {
                Text("Are you sure you want to delete your active program '\(plan.name)'? This will remove all scheduled workouts and you'll need to create or select a new program.")
            }
        }
    }
}

#Preview {
    EditProgramView(viewModel: EditProgramViewModel(container: DevPreview.shared.container), plan: TrainingPlan.mock)
        .previewEnvironment()
}
