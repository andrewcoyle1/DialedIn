//
//  WorkoutTrackerView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
import HealthKit
import SwiftfulRouting
import Combine

struct WorkoutTrackerDelegate {
    let workoutSessionId: String
}

struct WorkoutTrackerView: View {

    @Environment(\.scenePhase) private var scenePhase
    
    @State var presenter: WorkoutTrackerPresenter
    let delegate: WorkoutTrackerDelegate

    var body: some View {
        List {
            workoutOverviewCard
                .listSectionMargins(.top, 0)
            exerciseSection
        }
        .navigationTitle(presenter.workoutSession.name)
        .toolbarTitleDisplayMode(.inlineLarge)
        .scrollIndicators(.hidden)
        .environment(\.editMode, $presenter.editMode)
        .toolbar {
            toolbarContent
        }
        .safeAreaInset(edge: .bottom) {
            timerHeaderView()
        }
        .task(id: delegate.workoutSessionId) {
            await presenter.loadWorkoutSession(delegate.workoutSessionId)
            await presenter.onAppear()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            print("🌗 WorkoutTrackerView.scenePhase changed \(oldPhase) -> \(newPhase) for session id=\(delegate.workoutSessionId)")
            presenter.onScenePhaseChange(oldPhase: oldPhase, newPhase: newPhase)
        }
    }

    // MARK: - UI Components
    
    // MARK: - Workout Overview Card
    private var workoutOverviewCard: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Workout")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(presenter.exercisesCount)
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Sets Completed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(presenter.completedSetsFraction)
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                }
                
                // Quick stats
                HStack(spacing: 20) {
                    StatCard(
                        value: presenter.exerciseFraction,
                        label: "Exercise",
                    )
                    StatCard(
                        value: presenter.formattedVolume,
                        label: "Volume"
                    )
                    StatCard(
                        value: presenter.workoutNotes.isEmpty ? "None" : "View",
                        label: "Notes"
                    )
                    .onTapGesture {
                        presenter.presentWorkoutNotes()
                    }
                }
            }
        } header: {
            Text("Workout Overview")
        }
    }

    // MARK: - Exercise Section Card

    private var exerciseSection: some View {
        // Exercise List
        Section {
            if presenter.workoutSession.exercises.isEmpty {
                ContentUnavailableView {
                    Text("No Exercises")
                } description: {
                    Text("Please add some exercises to get started.")
                }
                .removeListRowFormatting()
            } else {
                ForEach(Array(presenter.workoutSession.exercises.enumerated()), id: \.element.id) { index, exercise in
                    let isExpanded = Binding<Bool>(
                        get: {
                            presenter.expandedExerciseIds.contains(exercise.id)
                        },
                        set: { newValue in
                            if newValue {
                                presenter.expandedExerciseIds = []
                                presenter.expandedExerciseIds.insert(exercise.id)
                            } else {
                                presenter.expandedExerciseIds.remove(exercise.id)
                            }
                        }
                    )
                    
//                    let delegate = ExerciseTrackerCardDelegate(
//                        exercise: exercise,
//                        exerciseIndex: index,
//                        isCurrentExercise: presenter.currentExerciseIndex == index,
//                        isExpanded: isExpanded,
//                        restBeforeSetIdToSec: presenter.restBeforeSetIdToSec,
//                        onNotesChanged: { notes, exerciseId in
//                            presenter.updateExerciseNotes(notes, exerciseId: exerciseId)
//                        },
//                        onAddSet: { exerciseId in
//                            presenter.addSet(exerciseId: exerciseId)
//                        },
//                        onDeleteSet: { setId, exerciseId in
//                            presenter.deleteSet(setId: setId, exerciseId: exerciseId)
//                        },
//                        onUpdateSet: { updatedSet, exerciseId in
//                            presenter.updateSet(updatedSet, in: exerciseId)
//                        },
//                        onRestBeforeChange: { setId, seconds in
//                            presenter.updateRestBefore(setId: setId, seconds: seconds)
//                        }
//                    )
//                    
//                    exerciseTrackerCardView(delegate)
                    exerciseTracker(exercise)
                }
                .onMove { source, destination in
                    presenter.moveExercises(from: source, to: destination)
                }
            }
            
        } header: {
            Text("Exercises")
        }
    }
    
    // MARK: - Timer Header
    @ViewBuilder
    private func timerHeaderView() -> some View {
        if presenter.isRestActive {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(presenter.isRestActive ? "Rest Timer" : "Workout Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
                    if let end = presenter.restEndTime {
                        let now = Date()
                        if now < end {
                            Text(timerInterval: now...end)
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                        } else {
                            Text("00:00")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                        }
                    } else {
                        Text((presenter.workoutSession.dateCreated), style: .timer)
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                    }
                    #endif
                }
                
                Spacer()
            }
            .padding()
            .background(.bar)
        }
    }
    
    @ViewBuilder
    private func exerciseTracker(_ exercise: WorkoutExerciseModel) -> some View {
        DisclosureGroup {
            setsContent(exercise)
                .listRowSpacing(0)
        } label: {
            exerciseHeader(exercise)
        }

    }
    
    @ViewBuilder
    private func exerciseHeader(_ exercise: WorkoutExerciseModel) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Text("Set \(exercise.completedSetsCount)/\(exercise.sets.count)")
                    .font(.caption)
                    .foregroundColor(exercise.completedSetsCount == exercise.sets.count ? .green : .secondary)
            }
            Spacer()
            
            // Unit preference menu
            unitPreferenceMenu(exercise)
        }
        .tappableBackground()
        .listRowInsets(.vertical, .zero)
    }

    @ViewBuilder
    private func setsContent(_ exercise: WorkoutExerciseModel) -> some View {
        ForEach(exercise.sets) { set in
            VStack {
                HStack {
                    // Set number
                    setNumber(exercise: exercise, set: set)
                    Spacer()
                    // Previous values placeholder
                    previousValues(exercise: exercise, set: set)
                    Spacer()
                    // Inputs vary by tracking mode
                    inputFields(exercise: exercise, set: set)
                    Spacer()
                    // Complete button
                    completeButton(exercise: exercise, set: set)
                }
                .frame(maxWidth: .infinity)
                
                // Rest selector (applies after completing this set)
                restSelector(exercise: exercise, set: set)
            }
            .padding(.vertical, 4)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    presenter.deleteSet(setId: set.id, exerciseId: exercise.id)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            .moveDisabled(true)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(.vertical, 0)
        .listRowInsets(.leading, 0)
        
        // Add set button
        Button {
            presenter.addSet(exerciseId: exercise.id)
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add Set")
            }
            .font(.footnote.bold())
            .foregroundColor(.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.accent.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .listRowSeparator(.hidden)
        .listRowInsets(.vertical, 0)
        .listRowInsets(.leading, 0)

    }
    
    private func setNumber(exercise: WorkoutExerciseModel, set: WorkoutSetModel) -> some View {
        VStack(alignment: .center) {
            if set.index == 1 {
                Text("Set")
                    .font(.caption2)
            }
            Menu {
                
                Button {
                    updateSetValue(set, in: exercise.id) { $0.isWarmup.toggle() }
                } label: {
                    Label("Warmup Set", systemImage: set.isWarmup ? "checkmark" : "")
                }
                
                Button {
                    presenter.onWarmupSetHelpPressed()
                } label: {
                    Label("What's a warmup set?", systemImage: "info.circle")
                }
            } label: {
                Text("\(set.index)")
                    .font(.subheadline)
                    .frame(height: 35)
                    .frame(width: 28, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(set.isWarmup ? Color.orange.opacity(0.2) : .secondary.opacity(0.05))
                    )
            }
        }
        .foregroundColor(.secondary)
    }
    
    // MARK: Previous Values
    private func previousValues(exercise: WorkoutExerciseModel, set: WorkoutSetModel) -> some View {
        VStack(alignment: .center) {
            if set.index == 1 {
                Text("Prev")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            let unitPreference = presenter.getUnitPreference(for: exercise.templateId)
            let previousSet = presenter.buildPreviousLookup(for: exercise)[set.index]
            if let prev = previousSet {
                switch exercise.trackingMode {
                case .weightReps:
                    if let weight = prev.weightKg, let reps = prev.reps {
                        let displayWeight = UnitConversion.formatWeight(weight, unit: unitPreference.weightUnit)
                        Text("\(displayWeight) × \(reps)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(height: 35)
                    } else {
                        Text("—")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(height: 35)
                    }
                    
                case .repsOnly:
                    if let reps = prev.reps {
                        Text("\(reps)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(height: 35)
                    } else {
                        Text("—")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(height: 35)
                    }
                    
                case .timeOnly:
                    if let duration = prev.durationSec {
                        let minutes = duration / 60
                        let seconds = duration % 60
                        Text("\(minutes):\(String(format: "%02d", seconds))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(height: 35)
                    } else {
                        Text("—")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(height: 35)
                    }
                    
                case .distanceTime:
                    if let distance = prev.distanceMeters, let duration = prev.durationSec {
                        let displayDistance = UnitConversion.formatDistance(distance, unit: unitPreference.distanceUnit)
                        let minutes = duration / 60
                        let seconds = duration % 60
                        Text("\(displayDistance) \(minutes):\(String(format: "%02d", seconds))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(height: 35)
                            .lineLimit(2)
                    } else {
                        Text("—")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(height: 35)
                    }
                }
            } else {
                Text("—")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(height: 35)
            }
        }
        .frame(width: 60, alignment: .center)
    }
    
    // MARK: - Input Fields
    
    @ViewBuilder
    private func inputFields(exercise: WorkoutExerciseModel, set: WorkoutSetModel) -> some View {
        switch exercise.trackingMode {
        case .weightReps:
            weightRepsFields(exercise: exercise, set: set)
        case .repsOnly:
            repsOnlyFields(exercise: exercise, set: set)
        case .timeOnly:
            timeOnlyFields(exercise: exercise, set: set)
        case .distanceTime:
            distanceTimeFields(exercise: exercise, set: set)
        }
    }
    
    private func weightRepsFields(exercise: WorkoutExerciseModel, set: WorkoutSetModel) -> some View {
        
        let unitPreference = presenter.getUnitPreference(for: exercise.templateId)
        return HStack(spacing: 8) {
            VStack(alignment: .leading) {
                if set.index == 1 {
                    Text("Weight (\(unitPreference.weightUnit.abbreviation))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                TextField("0", value: Binding(
                    get: {
                        guard let kilograms = set.weightKg else { return nil }
                        return UnitConversion.convertWeight(kilograms, to: unitPreference.weightUnit)
                    },
                    set: { newValue in
                        updateSetValue(set, in: exercise.id) { updated in
                            guard let value = newValue else {
                                updated.weightKg = nil
                                return
                            }
                            let kilos = UnitConversion.convertWeightToKg(value, from: unitPreference.weightUnit)
                            updated.weightKg = kilos
                        }
                    }
                ), format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .frame(height: 35)
            }
            .frame(width: 70)
            
            VStack(alignment: .leading) {
                if set.index == 1 {
                    Text("Reps")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                TextField("0", value: Binding(
                    get: { set.reps },
                    set: { newValue in
                        updateSetValue(set, in: exercise.id) { $0.reps = newValue }
                    }
                ), format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .frame(height: 35)
            }
            .frame(width: 50)
        }
    }
    
    private func repsOnlyFields(exercise: WorkoutExerciseModel, set: WorkoutSetModel) -> some View {
        VStack(alignment: .leading) {
            if set.index == 1 {
                Text("Reps")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            TextField("0", value: Binding(
                get: { set.reps },
                set: { newValue in
                    updateSetValue(set, in: exercise.id) { $0.reps = newValue }
                }
            ), format: .number)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.numberPad)
            .frame(height: 35)
        }
        .frame(width: 60)
    }
    
    private func timeOnlyFields(exercise: WorkoutExerciseModel, set: WorkoutSetModel) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if set.index == 1 {
                Text("Duration")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            HStack(spacing: 4) {
                TextField("0", value: Binding(
                    get: { set.durationSec.map { $0 / 60 } },
                    set: { newMinutes in
                        if let minutes = newMinutes {
                            let seconds = (set.durationSec ?? 0) % 60
                            let newDuration = minutes * 60 + seconds
                            updateSetValue(set, in: exercise.id) { $0.durationSec = newDuration }
                        }
                    }
                ), format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .frame(width: 40)
                
                Text(":")
                    .font(.caption)
                
                TextField("00", value: Binding(
                    get: { set.durationSec.map { $0 % 60 } },
                    set: { newSeconds in
                        if let seconds = newSeconds {
                            let minutes = (set.durationSec ?? 0) / 60
                            let newDuration = minutes * 60 + seconds
                            updateSetValue(set, in: exercise.id) { $0.durationSec = newDuration }
                        }
                    }
                ), format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .frame(width: 40)
            }
            .frame(width: 90)
            .frame(height: 35)
        }
    }
    
    private func distanceTimeFields(exercise: WorkoutExerciseModel, set: WorkoutSetModel) -> some View {

        let unitPreference = presenter.getUnitPreference(for: exercise.templateId)
        return HStack(spacing: 8) {
            // Distance input
            VStack(alignment: .leading, spacing: 2) {
                if set.index == 1 {
                    Text("Distance (\(unitPreference.distanceUnit.abbreviation))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                TextField("0", value: Binding(
                    get: {
                        guard let meters = set.distanceMeters else { return nil }
                        return UnitConversion.convertDistance(meters, to: unitPreference.distanceUnit)
                    },
                    set: { newValue in
                        updateSetValue(set, in: exercise.id) { updated in
                            guard let value = newValue else {
                                updated.distanceMeters = nil
                                return
                            }
                            let meters = UnitConversion.convertDistanceToMeters(value, from: unitPreference.distanceUnit)
                            updated.distanceMeters = meters
                        }
                    }
                ), format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .frame(height: 35)
            }
            .frame(width: 70)
            
            // Time input
            VStack(alignment: .leading, spacing: 2) {
                if set.index == 1 {
                    Text("Time")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 2) {
                    TextField("0", value: Binding(
                        get: { set.durationSec.map { $0 / 60 } },
                        set: { newMinutes in
                            if let minutes = newMinutes {
                                let seconds = (set.durationSec ?? 0) % 60
                                let newDuration = minutes * 60 + seconds
                                updateSetValue(set, in: exercise.id) { $0.durationSec = newDuration }
                            }
                        }
                    ), format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .frame(width: 35)
                    
                    Text(":")
                        .font(.caption2)
                    
                    TextField("00", value: Binding(
                        get: { set.durationSec.map { $0 % 60 } },
                        set: { newSeconds in
                            if let seconds = newSeconds {
                                let minutes = (set.durationSec ?? 0) / 60
                                let newDuration = minutes * 60 + seconds
                                updateSetValue(set, in: exercise.id) { $0.durationSec = newDuration }
                            }
                        }
                    ), format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .frame(width: 35)
                }
                .frame(height: 35)
            }
            .frame(width: 80)
        }
    }
        
    // MARK: - Action Buttons
    private func completeButton(exercise: WorkoutExerciseModel, set: WorkoutSetModel) -> some View {
        Button {
            if set.completedAt == nil {
                // Validate before completing
                if presenter.validateSetData(trackingMode: exercise.trackingMode, set: set) {
                    updateSetValue(set, in: exercise.id) { $0.completedAt = Date() }
                }
            } else {
                updateSetValue(set, in: exercise.id) { $0.completedAt = nil }
            }
        } label: {
            VStack(alignment: .center) {
                if set.index == 1 {
                    Text("Done")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Image(systemName: set.completedAt != nil ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(presenter.buttonColor(set: set, canComplete: presenter.canComplete(trackingMode: exercise.trackingMode, set: set)))
                    .frame(height: 35)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 32, alignment: .center)
    }
    
    // MARK: - Rest Selector
    private func restSelector(exercise: WorkoutExerciseModel, set: WorkoutSetModel) -> some View {

        Button {
            presenter.onRestPickerRequested(setId: set.id)
        } label: {
            HStack {
                Capsule()
                    .frame(maxWidth: .infinity)
                    .frame(height: 2)
                Image(systemName: "timer")
                Text(presenter.restBeforeSetIdToSec[set.id].map { "\($0)s" } ?? "Rest")
                    .fontWeight(.medium)
                Capsule()
                    .frame(maxWidth: .infinity)
                    .frame(height: 2)
            }
        }
    }

    private func updateSetValue(
        _ set: WorkoutSetModel,
        in exerciseId: String,
        update: (inout WorkoutSetModel) -> Void
    ) {
        var updated = set
        update(&updated)
        presenter.updateSet(updated, in: exerciseId)
    }


    @ViewBuilder
    private func unitPreferenceMenu(_ exercise: WorkoutExerciseModel) -> some View {
        Menu {
            // Show weight options for exercises that track weight
            if exercise.trackingMode == .weightReps {
                Menu {
                    ForEach(ExerciseWeightUnit.allCases, id: \.self) { unit in
                        Button {
//                            presenter.updateWeightUnit(unit, for: exercise.id)
                        } label: {
                            HStack {
                                Text(unit.displayName)
//                                if unit == presenter.preference?.weightUnit {
                                    Image(systemName: "checkmark")
//                                }
                            }
                        }
                    }
                } label: {
                    Label("Weight Unit", systemImage: "scalemass")
                }
            }
            
            // Show distance options for exercises that track distance
            if exercise.trackingMode == .distanceTime {
                Menu {
                    ForEach(ExerciseDistanceUnit.allCases, id: \.self) { unit in
                        Button {
//                            presenter.updateDistanceUnit(unit, for: delegate.exercise.id)
                        } label: {
                            HStack {
                                Text(unit.displayName)
//                                if unit == presenter.preference?.distanceUnit {
                                    Image(systemName: "checkmark")
//                                }
                            }
                        }
                    }
                } label: {
                    Label("Distance Unit", systemImage: "ruler")
                }
            }
        } label: {
            Image(systemName: "slider.horizontal.3")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
        }
    }
        
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {

                } label: {
                    Label("Resume Workout", systemImage: "play")
                }
                Button {
                    presenter.minimizeSession()
                } label: {
                    Label("Minimise Tracker", systemImage: "xmark")
                }

                Button {
                    presenter.finishWorkout()
                } label: {
                    Label("Finish Workout", systemImage: "checkmark")
                }

                Button {
                    presenter.onWorkoutSettingsPressed()
                } label: {
                    Label("Workout Settings", systemImage: "gear")
                }

                Button {
                    presenter.onGymProfilePressed()
                } label: {
                    Label("Gym Settings", systemImage: "gear")
                }

                Button(role: .destructive) {
                    presenter.onDiscardWorkoutPressed()
                } label: {
                    Label("Delete Workout", systemImage: "trash")
                }
            } label: {
                Image(systemName: "line.3.horizontal")
            }
        }
    }
}

extension CoreBuilder {
    func workoutTrackerView(router: AnyRouter, delegate: WorkoutTrackerDelegate) -> some View {
        WorkoutTrackerView(
            presenter: WorkoutTrackerPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showWorkoutTrackerView(delegate: WorkoutTrackerDelegate) {
        router.showScreen(.fullScreenCover) { router in
            builder.workoutTrackerView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.workoutTrackerView(router: router, delegate: WorkoutTrackerDelegate(workoutSessionId: WorkoutSessionModel.mock.id))
    }
    .previewEnvironment()
}
