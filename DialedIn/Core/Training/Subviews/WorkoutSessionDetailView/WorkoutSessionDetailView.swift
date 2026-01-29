//
//  WorkoutSessionDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle
//

import SwiftUI
import SwiftfulRouting

struct WorkoutSessionDetailView: View {

    @State var presenter: WorkoutSessionDetailPresenter

    var delegate: WorkoutSessionDetailDelegate

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
        .showModal(showModal: Binding(get: { presenter.isLoading }, set: { _ in })) {
            ProgressView()
                .tint(.white)
        }.scrollIndicators(.hidden)
        .toolbar {
            toolbarContent
        }
        .onAppear {
            presenter.loadUnitPreferences(for: delegate.workoutSession)
        }
    }

    private var activeSession: WorkoutSessionModel {
        presenter.currentSession(session: delegate.workoutSession)
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
                    value: "\(presenter.totalSets(session: delegate.workoutSession))",
                    label: "Sets",
                    icon: "square.stack.3d.up",
                    color: .purple
                )
                
                StatCard(
                    value: presenter.volumeFormatted(session: delegate.workoutSession),
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
            if presenter.isEditMode {
                if let editedSession = presenter.editedSession {
                    ForEach(editedSession.exercises.indices, id: \.self) { index in
                        let exercise = editedSession.exercises[index]
                        let preference = presenter.getUnitPreference(for: exercise.templateId)
                        editableExerciseCardWrapper(
                            EditableExerciseCardWrapperDelegate(
                                exercise: exercise,
                                index: index + 1,
                                weightUnit: preference.weightUnit,
                                distanceUnit: preference.distanceUnit,
                                onExerciseUpdate: { updated in presenter.updateExercise(at: index, with: updated) },
                                onAddSet: { presenter.addSet(to: exercise.id) },
                                onDeleteSet: { setId in presenter.deleteSet(setId, from: exercise.id) },
                                onWeightUnitChange: { unit in presenter.updateWeightUnit(unit, for: exercise.templateId) },
                                onDistanceUnitChange: { unit in presenter.updateDistanceUnit(unit, for: exercise.templateId) }
                            )
                        )
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                presenter.deleteExercise(id: exercise.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                
                // Add Exercise button
                Button {
                    presenter.onAddExercisePressed()
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
            if presenter.isEditMode {
                Button("Save") {
                    Task { await presenter.saveChanges() }
                }
                .disabled(presenter.isSaving)
                .fontWeight(.semibold)
            } else {
                Button(role: .destructive) {
                    presenter.onDeletePressed(
                        session: delegate.workoutSession
                    )
                } label: {
                    Image(systemName: "trash")
                }
                .disabled(presenter.isDeleting)
            }
        }
        
        ToolbarItem(placement: .topBarLeading) {
            if presenter.isEditMode {
                Button("Cancel") {
                    if presenter.hasUnsavedChanges(session: delegate.workoutSession) {
                        presenter.showDiscardChangesAlert(session: delegate.workoutSession)
                    } else {
                        presenter.cancelEditing(session: delegate.workoutSession)
                    }
                }
                .disabled(presenter.isSaving)
            } else {
                Button("Edit") {
                    presenter.enterEditMode(session: delegate.workoutSession)
                }
            }
        }
    }
    
    @ViewBuilder
    private func notesEditor() -> some View {
        // Notes editor (editable in edit mode)
        if presenter.isEditMode {
            VStack(alignment: .leading, spacing: 4) {
                Text("Workout Notes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                ZStack(alignment: .topLeading) {
                    let notesValue = presenter.editedSession?.notes ?? ""
                    if notesValue.isEmpty {
                        Text("Add notes here...")
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                            .padding(.leading, 6)
                    }
                    TextEditor(text: Binding(
                        get: { presenter.editedSession?.notes ?? "" },
                        set: { newValue in
                            guard var editedSession = presenter.editedSession else { return }
                            editedSession.notes = newValue.isEmpty ? nil : newValue
                            presenter.editedSession = editedSession
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

extension CoreBuilder {
    func workoutSessionDetailView(router: AnyRouter, delegate: WorkoutSessionDetailDelegate) -> some View {
        WorkoutSessionDetailView(
            presenter: WorkoutSessionDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
            editableExerciseCardWrapper: { delegate in
                self.editableExerciseCardWrapper(delegate: delegate)
                    .any()
            }
        )
    }
}

extension CoreRouter {
    func showWorkoutSessionDetailView(delegate: WorkoutSessionDetailDelegate) {
        router.showScreen(.sheet) { router in
            builder.workoutSessionDetailView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    let delegate = WorkoutSessionDetailDelegate(workoutSession: .mock)
    RouterView { router in
        builder.workoutSessionDetailView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
