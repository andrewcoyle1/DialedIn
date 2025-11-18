//
//  WorkoutSessionDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle
//

import SwiftUI

struct WorkoutSessionDetailViewDelegate {
    let workoutSession: WorkoutSessionModel
}

struct WorkoutSessionDetailView: View {

    @Environment(\.dismiss) private var dismiss

    @State var viewModel: WorkoutSessionDetailViewModel

    var delegate: WorkoutSessionDetailViewDelegate

    @ViewBuilder var addExerciseModalView: (AddExerciseModalViewDelegate) -> AnyView
    @ViewBuilder var editableExerciseCardWrapper: (EditableExerciseCardWrapperDelegate) -> AnyView
    var body: some View {
        List {
            let session = activeSession
            if let endedAt = session.endedAt {
                headerSection(session: session, endedAt: endedAt)
            }
            summarySection(session: session)
            exercisesSection(session: session)
        }
        .navigationTitle(activeSession.name)
        .navigationBarTitleDisplayMode(.large)
        .showCustomAlert(alert: $viewModel.showAlert)
        .showModal(showModal: Binding(get: { viewModel.isLoading }, set: { _ in })) {
            ProgressView()
                .tint(.white)
        }.scrollIndicators(.hidden)
        .toolbar {
            toolbarContent
        }
        .onAppear {
            viewModel.loadUnitPreferences(for: delegate.workoutSession)
        }
        .sheet(isPresented: $viewModel.showAddExerciseSheet, onDismiss: viewModel.addSelectedExercises) {
            addExerciseModalView(AddExerciseModalViewDelegate(selectedExercises: $viewModel.selectedExerciseTemplates))
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = WorkoutSessionDetailViewDelegate(workoutSession: .mock)
    NavigationStack {
        builder.workoutSessionDetailView(delegate: delegate)
    }
    .previewEnvironment()
}

extension WorkoutSessionDetailView {
    private var activeSession: WorkoutSessionModel {
        viewModel.currentSession(session: delegate.workoutSession)
    }
    
    private func headerSection(session: WorkoutSessionModel, endedAt: Date) -> some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.dateCreated.formatted(date: .long, time: .shortened))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    let duration = endedAt.timeIntervalSince(session.dateCreated)
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
    
    private func summarySection(session: WorkoutSessionModel) -> some View {
        Section {
            HStack(spacing: 12) {
                StatCard(
                    value: "\(session.exercises.count)",
                    label: "Exercises",
                    icon: "list.bullet",
                    color: .blue
                )
                
                StatCard(
                    value: "\(viewModel.totalSets(session: delegate.workoutSession))",
                    label: "Sets",
                    icon: "square.stack.3d.up",
                    color: .purple
                )
                
                StatCard(
                    value: viewModel.volumeFormatted(session: delegate.workoutSession),
                    label: "Volume",
                    icon: "scalemass",
                    color: .orange
                )
            }
        } header: {
            Text("Stats")
        }
    }
    
    private func exercisesSection(session: WorkoutSessionModel) -> some View {
        Section {
            if viewModel.isEditMode {
                if let editedSession = viewModel.editedSession {
                    ForEach(editedSession.exercises.indices, id: \.self) { index in
                        let exercise = editedSession.exercises[index]
                        let preference = viewModel.getUnitPreference(for: exercise.templateId)
                        editableExerciseCardWrapper(
                            EditableExerciseCardWrapperDelegate(
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
                ForEach(Array(session.exercises.enumerated()), id: \.element.id) { index, exercise in
                    ExerciseDetailCard(exercise: exercise, index: index + 1)
                }
            }
        } header: {
            Text("Exercises")
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
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
                    viewModel.onDeletePressed(
                        session: delegate.workoutSession,
                        onDismiss: {
                            dismiss()
                        }
                    )
                } label: {
                    Image(systemName: "trash")
                }
                .disabled(viewModel.isDeleting)
            }
        }
        
        ToolbarItem(placement: .topBarLeading) {
            if viewModel.isEditMode {
                Button("Cancel") {
                    if viewModel.hasUnsavedChanges(session: delegate.workoutSession) {
                        viewModel.showDiscardChangesAlert(session: delegate.workoutSession)
                    } else {
                        viewModel.cancelEditing(session: delegate.workoutSession)
                    }
                }
                .disabled(viewModel.isSaving)
            } else {
                Button("Edit") {
                    viewModel.enterEditMode(session: delegate.workoutSession)
                }
            }
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
                    let notesValue = viewModel.editedSession?.notes ?? ""
                    if notesValue.isEmpty {
                        Text("Add notes here...")
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                            .padding(.leading, 6)
                    }
                    TextEditor(text: Binding(
                        get: { viewModel.editedSession?.notes ?? "" },
                        set: { newValue in
                            guard var editedSession = viewModel.editedSession else { return }
                            editedSession.notes = newValue.isEmpty ? nil : newValue
                            viewModel.editedSession = editedSession
                        }
                    ))
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 80)
                    .textInputAutocapitalization(.sentences)
                }
                .padding(8)
                .background(.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        } else if let notes = activeSession.notes, !notes.isEmpty {
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
