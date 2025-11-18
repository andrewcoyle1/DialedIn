//
//  SetTrackerRowView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/09/2025.
//

import SwiftUI

struct SetTrackerRowViewDelegate {
    var set: WorkoutSetModel
    let trackingMode: TrackingMode
    var weightUnit: ExerciseWeightUnit = .kilograms
    var distanceUnit: ExerciseDistanceUnit = .meters
    var previousSet: WorkoutSetModel?
    var restBeforeSec: Int?
    let onRestBeforeChange: (Int?) -> Void
    var onRequestRestPicker: (String, Int?) -> Void = { _, _ in }
    let onUpdate: (WorkoutSetModel) -> Void
}

struct SetTrackerRowView: View {
    @State var viewModel: SetTrackerRowViewModel

    var delegate: SetTrackerRowViewDelegate

    private var cellHeight: CGFloat = 35

    init(viewModel: SetTrackerRowViewModel, delegate: SetTrackerRowViewDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
    }

    var body: some View {
        VStack {
            HStack {
                // Set number
                setNumber
                Spacer()
                // Previous values placeholder
                previousValues
                Spacer()
                // Inputs vary by tracking mode
                inputFields
                Spacer()
                // RPE
                rpeField
                Spacer()
                // Complete button
                completeButton
            }
            .frame(maxWidth: .infinity)
            
            // Rest selector (applies after completing this set)
            restSelector
        }
        .padding(.vertical, 4)
        .showCustomAlert(alert: $viewModel.showAlert)
        .sheet(isPresented: $viewModel.showWarmupHelp) {
            CustomModalView(
                title: "Warmup Sets",
                subtitle: "Warmup sets are lighter weight sets performed before your working sets to prepare your muscles and joints. They don't count toward your total volume or personal records.",
                primaryButtonTitle: "Got it",
                primaryButtonAction: {
                    viewModel.showWarmupHelp = false
                },
                secondaryButtonTitle: "",
                secondaryButtonAction: {}
            )
            .presentationDetents([.medium])
        }
    }
    
    private var setNumber: some View {
        VStack(alignment: .leading) {
            if delegate.set.index == 1 {
                Text("Set")
                    .font(.caption2)
            }
            Menu {
                
                Button {
                    updateSet { $0.isWarmup.toggle() }
                } label: {
                    Label("Warmup Set", systemImage: delegate.set.isWarmup ? "checkmark" : "")
                }
                
                Button {
                    viewModel.showWarmupHelp = true
                } label: {
                    Label("What's a warmup set?", systemImage: "info.circle")
                }
            } label: {
                Text("\(delegate.set.index)")
                    .font(.subheadline)
                    .frame(height: cellHeight)
                    .frame(width: 28, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(delegate.set.isWarmup ? Color.orange.opacity(0.2) : .secondary.opacity(0.05))
                    )
            }
        }
        .foregroundColor(.secondary)
    }
    
    // MARK: Previous Values
    private var previousValues: some View {
        VStack(alignment: .leading) {
            if delegate.set.index == 1 {
                Text("Prev")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if let prev = delegate.previousSet {
                switch delegate.trackingMode {
                case .weightReps:
                    if let weight = prev.weightKg, let reps = prev.reps {
                        let displayWeight = UnitConversion.formatWeight(weight, unit: delegate.weightUnit)
                        Text("\(displayWeight) × \(reps)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(height: cellHeight)
                    } else {
                        Text("—")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(height: cellHeight)
                    }
                    
                case .repsOnly:
                    if let reps = prev.reps {
                        Text("\(reps)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(height: cellHeight)
                    } else {
                        Text("—")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(height: cellHeight)
                    }
                    
                case .timeOnly:
                    if let duration = prev.durationSec {
                        let minutes = duration / 60
                        let seconds = duration % 60
                        Text("\(minutes):\(String(format: "%02d", seconds))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(height: cellHeight)
                    } else {
                        Text("—")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(height: cellHeight)
                    }
                    
                case .distanceTime:
                    if let distance = prev.distanceMeters, let duration = prev.durationSec {
                        let displayDistance = UnitConversion.formatDistance(distance, unit: delegate.distanceUnit)
                        let minutes = duration / 60
                        let seconds = duration % 60
                        Text("\(displayDistance) \(minutes):\(String(format: "%02d", seconds))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(height: cellHeight)
                            .lineLimit(2)
                    } else {
                        Text("—")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(height: cellHeight)
                    }
                }
            } else {
                Text("—")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(height: cellHeight)
            }
        }
        .frame(width: 60, alignment: .leading)
    }
    
    // MARK: - Input Fields
    
    @ViewBuilder
    private var inputFields: some View {
        switch delegate.trackingMode {
        case .weightReps:
            weightRepsFields
        case .repsOnly:
            repsOnlyFields
        case .timeOnly:
            timeOnlyFields
        case .distanceTime:
            distanceTimeFields
        }
    }
    
    private var weightRepsFields: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading) {
                if delegate.set.index == 1 {
                    Text("Weight (\(delegate.weightUnit.abbreviation))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                TextField("0", value: Binding(
                    get: {
                        guard let kilograms = delegate.set.weightKg else { return nil }
                        return UnitConversion.convertWeight(kilograms, to: delegate.weightUnit)
                    },
                    set: { newValue in
                        guard let value = newValue else {
                            updateSet { $0.weightKg = nil }
                            return
                        }
                        let kilos = UnitConversion.convertWeightToKg(value, from: delegate.weightUnit)
                        updateSet { $0.weightKg = kilos }
                    }
                ), format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .frame(height: cellHeight)
            }
            .frame(width: 70)
            
            VStack(alignment: .leading) {
                if delegate.set.index == 1 {
                    Text("Reps")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                TextField("0", value: Binding(
                    get: { delegate.set.reps },
                    set: { newValue in
                        updateSet { $0.reps = newValue }
                    }
                ), format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .frame(height: cellHeight)
            }
            .frame(width: 50)
        }
    }
    
    private var repsOnlyFields: some View {
        VStack(alignment: .leading) {
            if delegate.set.index == 1 {
                Text("Reps")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            TextField("0", value: Binding(
                get: { delegate.set.reps },
                set: { newValue in
                    updateSet { $0.reps = newValue }
                }
            ), format: .number)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.numberPad)
            .frame(height: cellHeight)
        }
        .frame(width: 60)
    }
    
    private var timeOnlyFields: some View {
        VStack(alignment: .leading, spacing: 2) {
            if delegate.set.index == 1 {
                Text("Duration")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            HStack(spacing: 4) {
                TextField("0", value: Binding(
                    get: { delegate.set.durationSec.map { $0 / 60 } },
                    set: { newMinutes in
                        if let minutes = newMinutes {
                            let seconds = (delegate.set.durationSec ?? 0) % 60
                            let newDuration = minutes * 60 + seconds
                            updateSet { $0.durationSec = newDuration }
                        }
                    }
                ), format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .frame(width: 40)
                
                Text(":")
                    .font(.caption)
                
                TextField("00", value: Binding(
                    get: { delegate.set.durationSec.map { $0 % 60 } },
                    set: { newSeconds in
                        if let seconds = newSeconds {
                            let minutes = (delegate.set.durationSec ?? 0) / 60
                            let newDuration = minutes * 60 + seconds
                            updateSet { $0.durationSec = newDuration }
                        }
                    }
                ), format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .frame(width: 40)
            }
            .frame(width: 90)
            .frame(height: cellHeight)
        }
    }
    
    private var distanceTimeFields: some View {
        HStack(spacing: 8) {
            // Distance input
            VStack(alignment: .leading, spacing: 2) {
                if delegate.set.index == 1 {
                    Text("Distance (\(delegate.distanceUnit.abbreviation))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                TextField("0", value: Binding(
                    get: {
                        guard let meters = delegate.set.distanceMeters else { return nil }
                        return UnitConversion.convertDistance(meters, to: delegate.distanceUnit)
                    },
                    set: { newValue in
                        guard let value = newValue else {
                            updateSet { $0.distanceMeters = nil }
                            return
                        }
                        let meters = UnitConversion.convertDistanceToMeters(value, from: delegate.distanceUnit)
                        updateSet { $0.distanceMeters = meters }
                    }
                ), format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .frame(height: cellHeight)
            }
            .frame(width: 70)
            
            // Time input
            VStack(alignment: .leading, spacing: 2) {
                if delegate.set.index == 1 {
                    Text("Time")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 2) {
                    TextField("0", value: Binding(
                        get: { delegate.set.durationSec.map { $0 / 60 } },
                        set: { newMinutes in
                            if let minutes = newMinutes {
                                let seconds = (delegate.set.durationSec ?? 0) % 60
                                let newDuration = minutes * 60 + seconds
                                updateSet { $0.durationSec = newDuration }
                            }
                        }
                    ), format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .frame(width: 35)
                    
                    Text(":")
                        .font(.caption2)
                    
                    TextField("00", value: Binding(
                        get: { delegate.set.durationSec.map { $0 % 60 } },
                        set: { newSeconds in
                            if let seconds = newSeconds {
                                let minutes = (delegate.set.durationSec ?? 0) / 60
                                let newDuration = minutes * 60 + seconds
                                updateSet { $0.durationSec = newDuration }
                            }
                        }
                    ), format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .frame(width: 35)
                }
                .frame(height: cellHeight)
            }
            .frame(width: 80)
        }
    }
    
    // MARK: - RPE Field
    private var rpeField: some View {
        VStack(alignment: .leading) {
            if delegate.set.index == 1 {
                Text("RPE")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            TextField("0", value: Binding(
                get: { delegate.set.rpe },
                set: { newValue in
                    updateSet { $0.rpe = newValue }
                }
            ), format: .number)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.decimalPad)
            .frame(height: cellHeight)
        }
        .frame(width: 45, alignment: .leading)
    }
    
    // MARK: - Action Buttons
    private var completeButton: some View {
        Button {
            if delegate.set.completedAt == nil {
                // Validate before completing
                if viewModel.validateSetData(trackingMode: delegate.trackingMode, set: delegate.set) {
                    updateSet { $0.completedAt = Date() }
                }
            } else {
                updateSet { $0.completedAt = nil }
            }
        } label: {
            VStack(alignment: .trailing) {
                if delegate.set.index == 1 {
                    Text("Done")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Image(systemName: delegate.set.completedAt != nil ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(viewModel.buttonColor(set: delegate.set, canComplete: viewModel.canComplete(trackingMode: delegate.trackingMode, set: delegate.set)))
                    .frame(height: cellHeight)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 32, alignment: .trailing)
    }
    
    // MARK: - Rest Selector
    private var restSelector: some View {
        Button {
            delegate.onRequestRestPicker(delegate.set.id, delegate.restBeforeSec)
        } label: {
            HStack {
                Capsule()
                    .frame(maxWidth: .infinity)
                    .frame(height: 2)
                Image(systemName: "timer")
                Text(delegate.restBeforeSec.map { "\($0)s" } ?? "Rest")
                    .fontWeight(.medium)
                Capsule()
                    .frame(maxWidth: .infinity)
                    .frame(height: 2)
            }
        }
    }
}

extension SetTrackerRowView {
    /// Helper to emit an updated copy of the set back to the parent.
    private func updateSet(_ update: (inout WorkoutSetModel) -> Void) {
        var updated = delegate.set
        update(&updated)
        delegate.onUpdate(updated)
    }
}
#Preview("Weight & Reps - Incomplete") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = SetTrackerRowViewDelegate(
        set: WorkoutSetModel(
            id: "1",
            authorId: "user1",
            index: 1,
            reps: 8,
            weightKg: 60.0,
            durationSec: nil,
            distanceMeters: nil,
            rpe: nil,
            isWarmup: false,
            completedAt: nil,
            dateCreated: Date()
        ),
        trackingMode: .weightReps,
        restBeforeSec: nil,
        onRestBeforeChange: { _ in },
        onUpdate: { _ in }
    )
    builder.setTrackerRowView(delegate: delegate)
    .padding()
}

#Preview("Weight & Reps - Complete") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = SetTrackerRowViewDelegate(
        set: WorkoutSetModel(
            id: "2",
            authorId: "user1",
            index: 2,
            reps: 10,
            weightKg: 80.0,
            durationSec: nil,
            distanceMeters: nil,
            rpe: 8.5,
            isWarmup: false,
            completedAt: Date(),
            dateCreated: Date()
        ),
        trackingMode: .weightReps,
        restBeforeSec: nil,
        onRestBeforeChange: { _ in },
        onUpdate: { _ in }
    )
    builder.setTrackerRowView(delegate: delegate)
}
#Preview("Duration - Incomplete") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = SetTrackerRowViewDelegate(
        set: WorkoutSetModel(
            id: "3",
            authorId: "user2",
            index: 1,
            reps: nil,
            weightKg: nil,
            durationSec: 90,
            distanceMeters: nil,
            rpe: nil,
            isWarmup: false,
            completedAt: nil,
            dateCreated: Date()
        ),
        trackingMode: .timeOnly,
        restBeforeSec: nil,
        onRestBeforeChange: { _ in },
        onUpdate: { _ in }
    )
    builder.setTrackerRowView(delegate: delegate)
}

#Preview("Duration - Complete") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = SetTrackerRowViewDelegate(
        set: WorkoutSetModel(
            id: "4",
            authorId: "user2",
            index: 2,
            reps: nil,
            weightKg: nil,
            durationSec: 120,
            distanceMeters: nil,
            rpe: 7.0,
            isWarmup: false,
            completedAt: Date(),
            dateCreated: Date()
        ),
        trackingMode: .timeOnly,
        restBeforeSec: nil,
        onRestBeforeChange: { _ in },
        onUpdate: { _ in }
    )
    builder.setTrackerRowView(delegate: delegate)
}

#Preview("Distance - Incomplete") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = SetTrackerRowViewDelegate(
        set: WorkoutSetModel(
            id: "5",
            authorId: "user3",
            index: 1,
            reps: nil,
            weightKg: nil,
            durationSec: 8*60,
            distanceMeters: 1500,
            rpe: nil,
            isWarmup: false,
            completedAt: nil,
            dateCreated: Date()
        ),
        trackingMode: .distanceTime,
        restBeforeSec: nil,
        onRestBeforeChange: { _ in },
        onUpdate: { _ in }
    )
    builder.setTrackerRowView(delegate: delegate)
}

#Preview("Distance - Complete") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = SetTrackerRowViewDelegate(
        set: WorkoutSetModel(
            id: "6",
            authorId: "user3",
            index: 2,
            reps: nil,
            weightKg: nil,
            durationSec: 60*25,
            distanceMeters: 5000,
            rpe: 9.0,
            isWarmup: false,
            completedAt: Date(),
            dateCreated: Date()
        ),
        trackingMode: .distanceTime,
        restBeforeSec: nil,
        onRestBeforeChange: { _ in },
        onUpdate: { _ in }
    )
    builder.setTrackerRowView(delegate: delegate)
}

#Preview("Warmup Set") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = SetTrackerRowViewDelegate(
        set: WorkoutSetModel(
            id: "7",
            authorId: "user4",
            index: 0,
            reps: 5,
            weightKg: 20.0,
            durationSec: nil,
            distanceMeters: nil,
            rpe: nil,
            isWarmup: true,
            completedAt: nil,
            dateCreated: Date()
        ),
        trackingMode: .weightReps,
        restBeforeSec: nil,
        onRestBeforeChange: { _ in },
        onUpdate: { _ in }
    )
    builder.setTrackerRowView(delegate: delegate)
}

#Preview("All Fields Populated") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = SetTrackerRowViewDelegate(
        set: WorkoutSetModel(
            id: "8",
            authorId: "user5",
            index: 3,
            reps: 12,
            weightKg: 100.0,
            durationSec: 60,
            distanceMeters: 400,
            rpe: 10.0,
            isWarmup: false,
            completedAt: Date(),
            dateCreated: Date()
        ),
        trackingMode: .weightReps,
        restBeforeSec: nil,
        onRestBeforeChange: { _ in },
        onUpdate: { _ in }
    )
    builder.setTrackerRowView(delegate: delegate)
}

#Preview("Edge: No Data") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = SetTrackerRowViewDelegate(
        set: WorkoutSetModel(
            id: "9",
            authorId: "user6",
            index: 1,
            reps: nil,
            weightKg: nil,
            durationSec: nil,
            distanceMeters: nil,
            rpe: nil,
            isWarmup: false,
            completedAt: nil,
            dateCreated: Date()
        ),
        trackingMode: .weightReps,
        restBeforeSec: nil,
        onRestBeforeChange: { _ in },
        onUpdate: { _ in }
    )
    builder.setTrackerRowView(delegate: delegate)
}
