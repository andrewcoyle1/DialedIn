//
//  WorkoutSessionDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle
//

import SwiftUI

struct WorkoutSessionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(WorkoutSessionManager.self) private var sessionManager
    @Environment(UserManager.self) private var userManager
    @Environment(ExerciseUnitPreferenceManager.self) private var unitPreferenceManager
    
    @State private var showDeleteConfirmation = false
    @State private var showAlert: AnyAppAlert?
    @State private var isDeleting = false
    @State private var isEditMode = false
    @State private var editedSession: WorkoutSessionModel
    @State private var isSaving = false
    @State private var showDiscardConfirmation = false
    @State private var showAddExerciseSheet = false
    @State private var selectedExerciseTemplates: [ExerciseTemplateModel] = []
    @State private var exerciseUnitPreferences: [String: (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit)] = [:]
    
    let session: WorkoutSessionModel
    
    init(session: WorkoutSessionModel) {
        self.session = session
        self._editedSession = State(initialValue: session)
    }
    
    var body: some View {
        List {
            // Header section
            if let endedAt = currentSession.endedAt {
                headerSection(endedAt: endedAt)
            }
            
            // Summary stats
            summarySection
            
            // Exercises
            exercisesSection
        }
        .navigationTitle(currentSession.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isEditMode {
                    Button("Save") {
                        Task { await saveChanges() }
                    }
                    .disabled(isSaving)
                    .fontWeight(.semibold)
                } else {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .disabled(isDeleting)
                }
            }
            
            ToolbarItem(placement: .topBarLeading) {
                if isEditMode {
                    Button("Cancel") {
                        if hasUnsavedChanges {
                            showDiscardConfirmation = true
                        } else {
                            cancelEditing()
                        }
                    }
                    .disabled(isSaving)
                } else {
                    Button("Edit") {
                        enterEditMode()
                    }
                }
            }
        }
        .alert("Delete Workout?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task { await deleteSession() }
            }
        } message: {
            Text("This workout session will be permanently deleted. This action cannot be undone.")
        }
        .alert("Discard Changes?", isPresented: $showDiscardConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Discard", role: .destructive) {
                cancelEditing()
            }
        } message: {
            Text("You have unsaved changes. Are you sure you want to discard them?")
        }
        .showModal(showModal: $isDeleting) {
            ProgressView()
                .tint(.white)
        }
        .showModal(showModal: $isSaving) {
            ProgressView()
                .tint(.white)
        }
        .sheet(isPresented: $showAddExerciseSheet, onDismiss: addSelectedExercises) {
            AddExerciseModal(selectedExercises: $selectedExerciseTemplates)
        }
        .showCustomAlert(alert: $showAlert)
        .onAppear {
            loadUnitPreferences()
        }
    }
    
    // MARK: - Computed Properties
    
    private var currentSession: WorkoutSessionModel {
        isEditMode ? editedSession : session
    }
    
    private var hasUnsavedChanges: Bool {
        editedSession != session
    }
    
    private func headerSection(endedAt: Date) -> some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(currentSession.dateCreated.formatted(date: .long, time: .shortened))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    let duration = endedAt.timeIntervalSince(currentSession.dateCreated)
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text("Duration: \(Date.formatDuration(duration))")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.green)
            }
            
            notesEditor()
            
        } header: {
            Text("Workout Summary")
        }
    }
    
    private var summarySection: some View {
        Section {
            HStack(spacing: 12) {
                SummaryStatCard(
                    value: "\(currentSession.exercises.count)",
                    label: "Exercises",
                    icon: "list.bullet",
                    color: .blue
                )
                
                SummaryStatCard(
                    value: "\(totalSets)",
                    label: "Sets",
                    icon: "square.stack.3d.up",
                    color: .purple
                )
                
                SummaryStatCard(
                    value: volumeFormatted,
                    label: "Volume",
                    icon: "scalemass",
                    color: .orange
                )
            }
        } header: {
            Text("Stats")
        }
    }
    
    private var exercisesSection: some View {
        Section {
            if isEditMode {
                ForEach(editedSession.exercises.indices, id: \.self) { index in
                    let exercise = editedSession.exercises[index]
                    let preference = getUnitPreference(for: exercise.templateId)
                    
                    EditableExerciseCardWrapper(
                        exercise: exercise,
                        index: index + 1,
                        weightUnit: preference.weightUnit,
                        distanceUnit: preference.distanceUnit,
                        onExerciseUpdate: { updated in updateExercise(at: index, with: updated) },
                        onAddSet: { addSet(to: exercise.id) },
                        onDeleteSet: { setId in deleteSet(setId, from: exercise.id) },
                        onWeightUnitChange: { unit in updateWeightUnit(unit, for: exercise.templateId) },
                        onDistanceUnitChange: { unit in updateDistanceUnit(unit, for: exercise.templateId) }
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteExercise(id: exercise.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                
                // Add Exercise button
                Button {
                    showAddExerciseSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Exercise")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                }
            } else {
                ForEach(Array(currentSession.exercises.enumerated()), id: \.element.id) { index, exercise in
                    ExerciseDetailCard(exercise: exercise, index: index + 1)
                }
            }
        } header: {
            Text("Exercises")
        }
    }
    
    @ViewBuilder
    private func notesEditor() -> some View {
        // Notes editor (editable in edit mode)
        if isEditMode {
            VStack(alignment: .leading, spacing: 4) {
                Text("Workout Notes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                ZStack(alignment: .topLeading) {
                    if editedSession.notes?.isEmpty ?? true {
                        Text("Add notes here...")
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                            .padding(.leading, 6)
                    }
                    TextEditor(text: Binding(
                        get: { editedSession.notes ?? "" },
                        set: { editedSession.notes = $0.isEmpty ? nil : $0 }
                    ))
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 80)
                    .textInputAutocapitalization(.sentences)
                }
                .padding(8)
                .background(.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        } else if let notes = currentSession.notes, !notes.isEmpty {
            Text(notes)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private var totalSets: Int {
        currentSession.exercises.flatMap { $0.sets }.filter { !$0.isWarmup }.count
    }
    
    private var totalVolume: Double {
        currentSession.exercises.flatMap { $0.sets }
            .filter { !$0.isWarmup }
            .compactMap { set -> Double? in
                guard let weight = set.weightKg, let reps = set.reps else { return nil }
                return weight * Double(reps)
            }.reduce(0.0, +)
    }
    
    private var volumeFormatted: String {
        if totalVolume > 0 {
            return String(format: "%.0f kg", totalVolume)
        } else {
            return "—"
        }
    }
    
    // MARK: - Edit Mode Actions
    
    private func enterEditMode() {
        editedSession = session
        isEditMode = true
        loadUnitPreferences()
    }
    
    private func cancelEditing() {
        editedSession = session
        isEditMode = false
        showDiscardConfirmation = false
    }
    
    private func saveChanges() async {
        isSaving = true
        defer { isSaving = false }
        
        do {
            // Update dateModified using the model's method
            var sessionToSave = editedSession
            sessionToSave.updateExercises(sessionToSave.exercises)
            
            // Save to local first
            try sessionManager.updateLocalWorkoutSession(session: sessionToSave)
            
            // Save to Firebase
            try await sessionManager.updateWorkoutSession(session: sessionToSave)
            
            isEditMode = false
            
            // Dismiss to refresh parent view
            dismiss()
        } catch {
            showAlert = AnyAppAlert(
                title: "Save Failed",
                subtitle: "Unable to save changes. Please try again."
            )
        }
    }
    
    // MARK: - Exercise Updates
    
    private func updateExercise(at index: Int, with updated: WorkoutExerciseModel) {
        var updatedExercises = editedSession.exercises
        updatedExercises[index] = updated
        editedSession.updateExercises(updatedExercises)
    }
    
    // MARK: - Set Management
    
    private func addSet(to exerciseId: String) {
        guard let exerciseIndex = editedSession.exercises.firstIndex(where: { $0.id == exerciseId }),
              let userId = userManager.currentUser?.userId else {
            return
        }
        
        var updatedExercises = editedSession.exercises
        let exercise = updatedExercises[exerciseIndex]
        let newIndex = exercise.sets.count + 1
        
        // Create new set based on the last set's values or default
        let lastSet = exercise.sets.last
        let newSet = WorkoutSetModel(
            id: UUID().uuidString,
            authorId: userId,
            index: newIndex,
            reps: lastSet?.reps,
            weightKg: lastSet?.weightKg,
            durationSec: lastSet?.durationSec,
            distanceMeters: lastSet?.distanceMeters,
            rpe: lastSet?.rpe,
            isWarmup: false,
            completedAt: Date(),
            dateCreated: Date()
        )
        
        updatedExercises[exerciseIndex].sets.append(newSet)
        editedSession.updateExercises(updatedExercises)
    }
    
    private func deleteSet(_ setId: String, from exerciseId: String) {
        guard let exerciseIndex = editedSession.exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }
        
        var updatedExercises = editedSession.exercises
        updatedExercises[exerciseIndex].sets.removeAll { $0.id == setId }
        
        // Reindex remaining sets
        for index in updatedExercises[exerciseIndex].sets.indices {
            updatedExercises[exerciseIndex].sets[index].index = index + 1
        }
        
        editedSession.updateExercises(updatedExercises)
    }
    
    // MARK: - Exercise Management
    
    private func deleteExercise(id: String) {
        var updatedExercises = editedSession.exercises
        updatedExercises.removeAll { $0.id == id }
        
        // Reindex remaining exercises
        for index in updatedExercises.indices {
            updatedExercises[index].index = index + 1
        }
        
        editedSession.updateExercises(updatedExercises)
    }
    
    private func addSelectedExercises() {
        guard !selectedExerciseTemplates.isEmpty, let userId = userManager.currentUser?.userId else {
            return
        }
        
        var updated = editedSession.exercises
        let startIndex = updated.count
        
        for (offset, template) in selectedExerciseTemplates.enumerated() {
            let index = startIndex + offset + 1
            let mode = WorkoutSessionModel.trackingMode(for: template.type)
            let defaultSets = WorkoutSessionModel.defaultSets(trackingMode: mode, authorId: userId)
            let imageName = Constants.exerciseImageName(for: template.name)
            
            let newExercise = WorkoutExerciseModel(
                id: UUID().uuidString,
                authorId: userId,
                templateId: template.id,
                name: template.name,
                trackingMode: mode,
                index: index,
                notes: nil,
                imageName: imageName,
                sets: defaultSets
            )
            updated.append(newExercise)
        }
        
        editedSession.updateExercises(updated)
        selectedExerciseTemplates.removeAll()
    }
    
    // MARK: - Unit Preferences
    
    private func loadUnitPreferences() {
        for exercise in editedSession.exercises {
            let preference = unitPreferenceManager.getPreference(for: exercise.templateId)
            exerciseUnitPreferences[exercise.templateId] = (
                weightUnit: preference.weightUnit,
                distanceUnit: preference.distanceUnit
            )
        }
    }
    
    private func getUnitPreference(for templateId: String) -> (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit) {
        if let cached = exerciseUnitPreferences[templateId] {
            return cached
        }
        let preference = unitPreferenceManager.getPreference(for: templateId)
        let result = (weightUnit: preference.weightUnit, distanceUnit: preference.distanceUnit)
        exerciseUnitPreferences[templateId] = result
        return result
    }
    
    private func updateWeightUnit(_ unit: ExerciseWeightUnit, for templateId: String) {
        var current = getUnitPreference(for: templateId)
        current.weightUnit = unit
        exerciseUnitPreferences[templateId] = current
        unitPreferenceManager.setPreference(weightUnit: unit, distanceUnit: current.distanceUnit, for: templateId)
    }
    
    private func updateDistanceUnit(_ unit: ExerciseDistanceUnit, for templateId: String) {
        var current = getUnitPreference(for: templateId)
        current.distanceUnit = unit
        exerciseUnitPreferences[templateId] = current
        unitPreferenceManager.setPreference(weightUnit: current.weightUnit, distanceUnit: unit, for: templateId)
    }
    
    // MARK: - Delete Session
    
    private func deleteSession() async {
        isDeleting = true
        defer { isDeleting = false }
        
        do {
            // Delete from local first for instant feedback
            try sessionManager.deleteLocalWorkoutSession(id: session.id)
            
            // Delete from remote in background
            try await sessionManager.deleteWorkoutSession(id: session.id)
            
            // Dismiss view after successful deletion
            dismiss()
        } catch {
            showAlert = AnyAppAlert(
                title: "Delete Failed",
                subtitle: "Unable to delete workout session. Please try again.",
                buttons: {
                    AnyView(
                        HStack {
                            Button("Cancel") { }
                            Button("Try Again") {
                                Task { await deleteSession() }
                            }
                        }
                    )
                }
            )
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutSessionDetailView(session: .mock)
    }
    .previewEnvironment()
}
