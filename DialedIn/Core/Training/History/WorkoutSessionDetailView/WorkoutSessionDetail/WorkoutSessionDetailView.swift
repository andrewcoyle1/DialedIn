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
    
    var body: some View {
        List {
            if let endedAt = viewModel.currentSession.endedAt {
                headerSection(endedAt: endedAt)
            }
            summarySection
            exercisesSection
        }
        .navigationTitle(viewModel.currentSession.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }
        .onAppear {
            viewModel.loadUnitPreferences()
        }
        .showCustomAlert(alert: $viewModel.showAlert)
        .showModal(showModal: Binding(get: { viewModel.isLoading }, set: { _ in })) {
            ProgressView()
                .tint(.white)
        }
        .sheet(isPresented: $viewModel.showAddExerciseSheet, onDismiss: viewModel.addSelectedExercises) {
            AddExerciseModalView(
                viewModel: AddExerciseModalViewModel(
                    interactor: CoreInteractor(
                    container: container),
                    selectedExercises: $viewModel.selectedExerciseTemplates
                )
            )
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
                StatCard(
                    value: "\(viewModel.currentSession.exercises.count)",
                    label: "Exercises",
                    icon: "list.bullet",
                    color: .blue
                )
                
                StatCard(
                    value: "\(viewModel.totalSets)",
                    label: "Sets",
                    icon: "square.stack.3d.up",
                    color: .purple
                )
                
                StatCard(
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
                            interactor: CoreInteractor(container: container),
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
                    if viewModel.hasUnsavedChanges {
                        viewModel.showDiscardChangesAlert()
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
        WorkoutSessionDetailView(
            viewModel: WorkoutSessionDetailViewModel(
                interactor: CoreInteractor(container: DevPreview.shared.container),
                session: .mock
            )
        )
    }
    .previewEnvironment()
}
