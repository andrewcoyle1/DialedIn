//
//  WorkoutSessionDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle
//

import SwiftUI

struct WorkoutSessionDetailDelegate {
    let initialSession: WorkoutSessionModel

    init(workoutSession: WorkoutSessionModel) {
        self.initialSession = workoutSession
    }
}

struct WorkoutSessionDetailView<AuthorHeader: View>: View {

    @State var presenter: WorkoutSessionDetailPresenter
    @State private var session: WorkoutSessionModel

    let delegate: WorkoutSessionDetailDelegate

    @ViewBuilder var authorHeader: (AuthorHeaderDelegate) -> AuthorHeader
    @ViewBuilder var editableExerciseCardWrapper: (EditableExerciseCardWrapperDelegate) -> AnyView

    init(
        presenter: WorkoutSessionDetailPresenter,
        delegate: WorkoutSessionDetailDelegate,
        authorHeader: @escaping (AuthorHeaderDelegate) -> AuthorHeader,
        editableExerciseCardWrapper: @escaping (EditableExerciseCardWrapperDelegate) -> AnyView
    ) {
        self._presenter = State(initialValue: presenter)
        self._session = State(initialValue: delegate.initialSession)
        self.delegate = delegate
        self.authorHeader = authorHeader
        self.editableExerciseCardWrapper = editableExerciseCardWrapper
    }
    
    var body: some View {
        List {
            Section {
                authorHeader(AuthorHeaderDelegate(author: .mock, date: session.dateCreated))
            }
            .listSectionMargins(.top, 0)
            headerSection(session: session, endedAt: session.endedAt)
            exercisesSection
            deleteSection
        }
        .navigationTitle(session.name)
        .navigationSubtitle(session.dateCreated.formatted(date: .long, time: .shortened))
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .toolbar {
            toolbarContent
        }
        .onAppear {
            presenter.loadUnitPreferences(for: session)
        }
    }

    private func headerSection(session: WorkoutSessionModel, endedAt: Date?) -> some View {
        Section {
                        
            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                StatCard(
                    value: "\(session.exercises.count)",
                    label: "Exercises",
                    icon: "list.bullet",
                    color: .blue,
                    alignment: .center
                )
                
                StatCard(
                    value: "\(presenter.totalSets(session: session))",
                    label: "Sets",
                    icon: "square.stack.3d.up",
                    color: .purple,
                    alignment: .center
                )

                StatCard(
                    value: presenter.volumeFormatted(session: session),
                    label: "Volume",
                    icon: "scalemass",
                    color: .orange,
                    alignment: .center
                )
            }

            notesEditor()

        } header: {
            HStack {
                Text("Workout Summary")
                Spacer()
                if let duration = endedAt?.timeIntervalSince(session.dateCreated) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text("Duration: \(Date.formatDuration(duration))")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.secondary)
                }

            }
        }
    }
        
    private var exercisesSection: some View {
        Section {
            if presenter.isEditMode {
                ForEach(0..<session.exercises.count, id: \.self) { index in
                    let exercise = session.exercises[index]
                    let preference = presenter.getUnitPreference(for: exercise.templateId)
                    editableExerciseCardWrapper(
                        EditableExerciseCardWrapperDelegate(
                            exercise: exercise,
                            index: index + 1,
                            weightUnit: preference.weightUnit,
                            distanceUnit: preference.distanceUnit,
                            onExerciseUpdate: { updated in
                                presenter.updateExercise(session: $session, at: index, with: updated)
                            },
                            onAddSet: {
                                presenter.addSet(session: $session, to: exercise.id)
                            },
                            onDeleteSet: { setId in
                                presenter.deleteSet(session: $session, setId, from: exercise.id)
                            },
                            onWeightUnitChange: { unit in
                                presenter.updateWeightUnit(unit, for: exercise.templateId)
                            },
                            onDistanceUnitChange: { unit in
                                presenter.updateDistanceUnit(unit, for: exercise.templateId)
                            }
                        )
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            presenter.deleteExercise(session: $session, id: exercise.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }

                Button {
                    presenter.onAddExercisePressed()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Exercise")
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.accentColor)
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
    
    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                presenter.onDeletePressed(session: session)
            }
            .foregroundStyle(.red)
            .disabled(presenter.isLoading)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        
        ToolbarItem(placement: .topBarLeading) {
            Button(role: .close) {
                if presenter.hasUnsavedChanges(session: delegate.initialSession, editedSession: session) {
                    presenter.showDiscardChangesAlert(session: session)
                } else {
                    presenter.onDismissPressed()
                }
            }
        }
        
        if presenter.isAuthor(sessionAuthorId: session.authorId) {
            ToolbarItem(placement: .topBarTrailing) {
                if presenter.isEditMode {
                    Button(role: .confirm) {
                        Task { await presenter.saveChanges(initialSession: delegate.initialSession, session: $session) }
                    }
                    .disabled(presenter.isLoading || !presenter.hasUnsavedChanges(session: delegate.initialSession, editedSession: session))
                    .fontWeight(.semibold)
                } else {
                    Button {
                        presenter.enterEditMode(session: session)
                    } label: {
                        Image(systemName: "pencil")
                    }
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
                    let notesValue = session.notes ?? ""
                    if notesValue.isEmpty {
                        Text("Add notes here...")
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                            .padding(.leading, 6)
                    }
                    TextEditor(
                        text: Binding(
                            get: { session.notes ?? "" },
                            set: { newValue in session.notes = newValue.isEmpty ? nil : newValue }
                        )
                    )
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 80)
                    .textInputAutocapitalization(.sentences)
                }
                .padding(8)
                .background(Color.accentColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        } else if let notes = session.notes, !notes.isEmpty {
            Text(notes)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.accentColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

extension CoreBuilder {
    func workoutSessionDetailView(router: AnyRouter, delegate: WorkoutSessionDetailDelegate) -> some View {
        WorkoutSessionDetailView(
            presenter: WorkoutSessionDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
            authorHeader: { delegate in
                self.authorHeaderView(router: router, delegate: delegate)
            },
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
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = WorkoutSessionDetailDelegate(workoutSession: .mock)
    RouterView { router in
        builder.workoutSessionDetailView(router: router, delegate: delegate)
    }
    
}
