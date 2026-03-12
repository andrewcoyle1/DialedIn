//
//  WorkoutTemplateDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI

struct WorkoutTemplateDetailDelegate {
    let workoutTemplate: WorkoutTemplateModel
    let trainingProgramId: String?
    let onStartWorkoutPressed: (@Sendable () -> Void)?
    var isDeloadCycle: Bool = false
    var periodisationPhase: PeriodisationPhase?
}

struct WorkoutTemplateDetailView: View {

    @State var presenter: WorkoutTemplateDetailPresenter
    
    let delegate: WorkoutTemplateDetailDelegate

    private var isAuthor: Bool {
        presenter.currentUser?.userId == delegate.workoutTemplate.authorId
    }
    
    var body: some View {
        List {
            targetMusclesSection
            exercisesSection
        }
        .navigationTitle(delegate.workoutTemplate.name)
        .navigationSubtitle(delegate.workoutTemplate.description ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        #if DEBUG || MOCK
        .toolbar {
            toolbarContent
        }
        #endif
.safeAreaInset(edge: .bottom) {
            Button {
                presenter.onStartWorkoutPressed(
                    onStartWorkout: delegate.onStartWorkoutPressed,
                    workoutTemplate: delegate.workoutTemplate,
                    trainingProgramId: delegate.trainingProgramId,
                    isDeloadCycle: delegate.isDeloadCycle
                )
            } label: {
                Text("Start Workout")
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .padding()
        }
    }

#if DEBUG || MOCK
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // Show edit button when not in edit mode
//        if isAuthor {
//            ToolbarItem(placement: .topBarLeading) {
//                Button {
//                    presenter.onEditWorkoutPressed(template: delegate.workoutTemplate)
//                } label: {
//                    Image(systemName: "pencil")
//                }
//            }
//        }
//
//        // Show delete button only in edit mode
//        if isAuthor {
//            ToolbarItem(placement: .topBarLeading) {
//                Button(role: .destructive) {
//                    presenter.showDeleteConfirmation(workoutTemplate: delegate.workoutTemplate)
//                } label: {
//                    if presenter.isDeleting {
//                        ProgressView()
//                    } else {
//                        Image(systemName: "trash")
//                    }
//                }
//                .disabled(presenter.isDeleting)
//            }
//        }

        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
    }
    #endif
    
    private var targetMusclesSection: some View {
        Section {
            if presenter.targetMuscleSummaries(exercises: delegate.workoutTemplate.exercises).isEmpty {
                HStack {
                    Image(systemName: "figure.wave")
                        .font(.system(size: 32))
                        .frame(width: 40)
                    Text("You haven't added any exercises yet. Once you add an exercise, target muscles will appear here.")
                }
            } else {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(presenter.targetMuscleSummaries(exercises: delegate.workoutTemplate.exercises)) { summary in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(summary.muscle.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                
                                Text("\(presenter.formattedSetCount(summary.weightedTargetSets)) target sets")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                
                                Text("\(summary.exerciseCount) \(summary.exerciseCount == 1 ? "exercise" : "exercises")")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            .padding(10)
                            .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.vertical, 4)
                }
                .removeListRowFormatting()
                .scrollIndicators(.hidden)
            }
        } header: {
            Text("Target Muscles")
        }
    }
    
    private var exercisesSection: some View {
        Section {
            ForEach(delegate.workoutTemplate.exercises) { exercise in
                HStack {
                    ImageLoaderView(urlString: exercise.exercise.imageURL ?? Constants.randomImage, resizingMode: .fit)
                        .frame(width: 60, height: 60)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(exercise.exercise.name)
                            .fontWeight(.semibold)
                        LazyHGrid(rows: [GridItem(), GridItem()]) {
                            ForEach(exercise.setTargets) { target in
                                setTarget(target)
                            }
                        }
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(
                                    exercise.exercise.muscleGroups.sorted { $0.key.name < $1.key.name },
                                    id: \.key
                                ) { key, value in
                                    Text(key.name)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                        .padding(4)
                                        .padding(.horizontal, 4)
                                        .background(value ? Color.secondary.opacity(0.2) : Color.secondary.opacity(0.4), in: Capsule())
                                }
                            }
                        }
                    }
                }
                .anyButton(.highlight) {
//                    presenter.onExercisePressed(exercise: exercise)
                }
            }
        } header: {
            HStack {
                VStack {
                    Text("\(delegate.workoutTemplate.exercises.count) Exercises")
                }
                Spacer()
                Button {
//                    presenter.onAddExercisePressed()
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    private func setTarget(_ target: SetTarget) -> some View {
        
        var descriptionString: String = "No target set"
        if let maxReps = target.maxReps {
            if let minReps = target.minReps {
                descriptionString = "\(minReps)-\(maxReps) reps"
            } else {
                descriptionString = "1-\(maxReps) reps"
            }
        } else if let minReps = target.minReps,
                  target.maxReps == nil {
            descriptionString = "\(minReps)+ reps"
        }
           
        return HStack {
            Circle()
                .frame(width: 12, height: 12)
                .foregroundStyle(.secondary)
                .overlay {
                    Text("\(target.setNumber)")
                }
            Text(descriptionString)
        }
        .font(.caption)
    }

}

extension CoreBuilder {
    func workoutTemplateDetailView(router: AnyRouter, delegate: WorkoutTemplateDetailDelegate) -> some View {
        WorkoutTemplateDetailView(
            presenter: WorkoutTemplateDetailPresenter(
                interactor: interactor,
                router: CoreRouter(
                    router: router,
                    builder: self
                )
            ),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showWorkoutTemplateDetailView(delegate: WorkoutTemplateDetailDelegate) {
        router.showScreen(.push) { router in
            builder.workoutTemplateDetailView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    RouterView { router in
        builder.workoutTemplateDetailView(
            router: router,
            delegate: WorkoutTemplateDetailDelegate(
                workoutTemplate: WorkoutTemplateModel.mock,
                trainingProgramId: nil,
                onStartWorkoutPressed: {
                    
                }
            )
        )
    }
    
}
