//
//  WorkoutSessionDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle
//

import SwiftUI

struct WorkoutSessionDetailView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: WorkoutSessionDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(session: WorkoutSessionModel, container: DependencyContainer) {
        self.viewModel = WorkoutSessionDetailViewModel(container: container, session: session)
    }
    
    var body: some View {
        List {
            // Header section
            if let endedAt = viewModel.currentSession.endedAt {
                headerSection(endedAt: endedAt)
            }
            
            // Summary stats
            summarySection
            
            // Exercises
            exercisesSection
        }
        .navigationTitle(viewModel.currentSession.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.isEditMode {
                    Button("Save") {
                        Task { await viewModel.saveChanges(onDismiss: {
                            dismiss()
                        }) }
                    }
                    .disabled(viewModel.isSaving)
                    .fontWeight(.semibold)
                } else {
                    Button(role: .destructive) {
                        viewModel.showDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .disabled(viewModel.isDeleting)
                }
            }
            
            ToolbarItem(placement: .topBarLeading) {
                if viewModel.isEditMode {
                    Button("Cancel") {
                        if viewModel.hasUnsavedChanges {
                            viewModel.showDiscardConfirmation = true
                        } else {
                            viewModel.cancelEditing()
                        }
                    }
                    .disabled(viewModel.isSaving)
                } else {
                    Button("Edit") {
                        viewModel.enterEditMode()
                    }
                }
            }
        }
        .alert("Delete Workout?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task { await viewModel.deleteSession(session: viewModel.session, onDismiss: {
                    dismiss()
                }) }
            }
        } message: {
            Text("This workout session will be permanently deleted. This action cannot be undone.")
        }
        .alert("Discard Changes?", isPresented: $viewModel.showDiscardConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Discard", role: .destructive) {
                viewModel.cancelEditing()
            }
        } message: {
            Text("You have unsaved changes. Are you sure you want to discard them?")
        }
        .showModal(showModal: $viewModel.isDeleting) {
            ProgressView()
                .tint(.white)
        }
        .showModal(showModal: $viewModel.isSaving) {
            ProgressView()
                .tint(.white)
        }
        .sheet(isPresented: $viewModel.showAddExerciseSheet, onDismiss: viewModel.addSelectedExercises) {
            AddExerciseModalView(
                viewModel: AddExerciseModalViewModel(
                    container: container,
                    selectedExercises: $viewModel.selectedExerciseTemplates
                )
            )
        }
        .showCustomAlert(alert: $viewModel.showAlert)
        .onAppear {
            viewModel.loadUnitPreferences()
        }
    }
    
    private func headerSection(endedAt: Date) -> some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.currentSession.dateCreated.formatted(date: .long, time: .shortened))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    let duration = endedAt.timeIntervalSince(viewModel.currentSession.dateCreated)
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
                    value: "\(viewModel.currentSession.exercises.count)",
                    label: "Exercises",
                    icon: "list.bullet",
                    color: .blue
                )
                
                SummaryStatCard(
                    value: "\(viewModel.totalSets)",
                    label: "Sets",
                    icon: "square.stack.3d.up",
                    color: .purple
                )
                
                SummaryStatCard(
                    value: viewModel.volumeFormatted,
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
            if viewModel.isEditMode {
                ForEach(viewModel.editedSession.exercises.indices, id: \.self) { index in
                    let exercise = viewModel.editedSession.exercises[index]
                    let preference = viewModel.getUnitPreference(for: exercise.templateId)
                    EditableExerciseCardWrapper(
                        viewModel: EditableExerciseCardWrapperViewModel(
                            container: container,
                        exercise: exercise,
                        index: index + 1,
                        weightUnit: preference.weightUnit,
                        distanceUnit: preference.distanceUnit,
                        onExerciseUpdate: { updated in viewModel.updateExercise(at: index, with: updated) },
                        onAddSet: { viewModel.addSet(to: exercise.id) },
                        onDeleteSet: { setId in viewModel.deleteSet(setId, from: exercise.id) },
                        onWeightUnitChange: { unit in viewModel.updateWeightUnit(unit, for: exercise.templateId) },
                        onDistanceUnitChange: { unit in viewModel.updateDistanceUnit(unit, for: exercise.templateId) }
                        )
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            viewModel.deleteExercise(id: exercise.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                
                // Add Exercise button
                Button {
                    viewModel.showAddExerciseSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Exercise")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                }
            } else {
                ForEach(Array(viewModel.currentSession.exercises.enumerated()), id: \.element.id) { index, exercise in
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
        if viewModel.isEditMode {
            VStack(alignment: .leading, spacing: 4) {
                Text("Workout Notes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                ZStack(alignment: .topLeading) {
                    if viewModel.editedSession.notes?.isEmpty ?? true {
                        Text("Add notes here...")
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                            .padding(.leading, 6)
                    }
                    TextEditor(text: Binding(
                        get: { viewModel.editedSession.notes ?? "" },
                        set: { viewModel.editedSession.notes = $0.isEmpty ? nil : $0 }
                    ))
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 80)
                    .textInputAutocapitalization(.sentences)
                }
                .padding(8)
                .background(.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        } else if let notes = viewModel.currentSession.notes, !notes.isEmpty {
            Text(notes)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutSessionDetailView(session: .mock, container: DevPreview.shared.container)
    }
    .previewEnvironment()
}
