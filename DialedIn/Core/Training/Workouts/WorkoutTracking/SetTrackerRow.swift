//
//  SetTrackerRow.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/09/2025.
//

import SwiftUI

struct SetTrackerRow: View {
    @State private var set: WorkoutSetModel
    let trackingMode: TrackingMode
    let weightUnit: ExerciseWeightUnit
    let distanceUnit: ExerciseDistanceUnit
    let previousSet: WorkoutSetModel?
    let restBeforeSec: Int?
    let onRestBeforeChange: (Int?) -> Void
    let onRequestRestPicker: (String, Int?) -> Void
    let onUpdate: (WorkoutSetModel) -> Void
    
    // Validation state
    @State private var showAlert: AnyAppAlert?
    @State private var showWarmupHelp = false
    // Local rest UI is delegated upward; keep no local modal/sheet state
    
    init(
        set: WorkoutSetModel,
        trackingMode: TrackingMode,
        weightUnit: ExerciseWeightUnit = .kilograms,
        distanceUnit: ExerciseDistanceUnit = .meters,
        previousSet: WorkoutSetModel? = nil,
        restBeforeSec: Int?,
        onRestBeforeChange: @escaping (Int?) -> Void,
        onRequestRestPicker: @escaping (String, Int?) -> Void = { _, _ in },
        onUpdate: @escaping (WorkoutSetModel) -> Void
    ) {
        self._set = State(initialValue: set)
        self.trackingMode = trackingMode
        self.weightUnit = weightUnit
        self.distanceUnit = distanceUnit
        self.previousSet = previousSet
        self.restBeforeSec = restBeforeSec
        self.onRestBeforeChange = onRestBeforeChange
        self.onRequestRestPicker = onRequestRestPicker
        self.onUpdate = onUpdate
    }
    
    private var cellHeight: CGFloat = 35
    
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
        .onChange(of: set) { _, newValue in
            onUpdate(newValue)
        }
        .showCustomAlert(alert: $showAlert)
        .sheet(isPresented: $showWarmupHelp) {
            CustomModalView(
                title: "Warmup Sets",
                subtitle: "Warmup sets are lighter weight sets performed before your working sets to prepare your muscles and joints. They don't count toward your total volume or personal records.",
                primaryButtonTitle: "Got it",
                primaryButtonAction: {
                    showWarmupHelp = false
                },
                secondaryButtonTitle: "",
                secondaryButtonAction: {}
            )
            .presentationDetents([.medium])
        }
    }
    
    private var setNumber: some View {
        VStack(alignment: .leading) {
            if set.index == 1 {
                Text("Set")
                    .font(.caption2)
            }
            Menu {
                
                Button {
                    set.isWarmup.toggle()
                } label: {
                    Label("Warmup Set", systemImage: set.isWarmup ? "checkmark" : "")
                }
                
                Button {
                    showWarmupHelp = true
                } label: {
                    Label("What's a warmup set?", systemImage: "info.circle")
                }
            } label: {
                Text("\(set.index)")
                    .font(.subheadline)
                    .frame(height: cellHeight)
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
    private var previousValues: some View {
        VStack(alignment: .leading) {
            if set.index == 1 {
                Text("Prev")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if let prev = previousSet {
                switch trackingMode {
                case .weightReps:
                    if let weight = prev.weightKg, let reps = prev.reps {
                        let displayWeight = UnitConversion.formatWeight(weight, unit: weightUnit)
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
                        let displayDistance = UnitConversion.formatDistance(distance, unit: distanceUnit)
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
        switch trackingMode {
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
                if set.index == 1 {
                    Text("Weight (\(weightUnit.abbreviation))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                TextField("0", value: Binding(
                    get: {
                        guard let kilograms = set.weightKg else { return nil }
                        return UnitConversion.convertWeight(kilograms, to: weightUnit)
                    },
                    set: { newValue in
                        guard let value = newValue else {
                            set.weightKg = nil
                            return
                        }
                        set.weightKg = UnitConversion.convertWeightToKg(value, from: weightUnit)
                    }
                ), format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .frame(height: cellHeight)
            }
            .frame(width: 70)
            
            VStack(alignment: .leading) {
                if set.index == 1 {
                    Text("Reps")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                TextField("0", value: $set.reps, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .frame(height: cellHeight)
            }
            .frame(width: 50)
        }
    }
    
    private var repsOnlyFields: some View {
        VStack(alignment: .leading) {
            if set.index == 1 {
                Text("Reps")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            TextField("0", value: $set.reps, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .frame(height: cellHeight)
        }
        .frame(width: 60)
    }
    
    private var timeOnlyFields: some View {
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
                            set.durationSec = minutes * 60 + seconds
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
                            set.durationSec = minutes * 60 + seconds
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
                if set.index == 1 {
                    Text("Distance (\(distanceUnit.abbreviation))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                TextField("0", value: Binding(
                    get: {
                        guard let meters = set.distanceMeters else { return nil }
                        return UnitConversion.convertDistance(meters, to: distanceUnit)
                    },
                    set: { newValue in
                        guard let value = newValue else {
                            set.distanceMeters = nil
                            return
                        }
                        set.distanceMeters = UnitConversion.convertDistanceToMeters(value, from: distanceUnit)
                    }
                ), format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .frame(height: cellHeight)
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
                                set.durationSec = minutes * 60 + seconds
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
                                set.durationSec = minutes * 60 + seconds
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
            if set.index == 1 {
                Text("RPE")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            TextField("0", value: $set.rpe, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .frame(height: cellHeight)
        }
        .frame(width: 45, alignment: .leading)
    }
    
    // MARK: - Action Buttons
    private var completeButton: some View {
        Button {
            if set.completedAt == nil {
                // Validate before completing
                if validateSetData() {
                    set.completedAt = Date()
                }
            } else {
                set.completedAt = nil
            }
        } label: {
            VStack(alignment: .trailing) {
                if set.index == 1 {
                    Text("Done")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Image(systemName: set.completedAt != nil ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(buttonColor)
                    .frame(height: cellHeight)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 32, alignment: .trailing)
    }
    
    // MARK: - Rest Selector
    private var restSelector: some View {
        Button {
            onRequestRestPicker(set.id, restBeforeSec)
        } label: {
            HStack {
                Capsule()
                    .frame(maxWidth: .infinity)
                    .frame(height: 2)
                Image(systemName: "timer")
                Text(restBeforeSec.map { "\($0)s" } ?? "Rest")
                    .fontWeight(.medium)
                Capsule()
                    .frame(maxWidth: .infinity)
                    .frame(height: 2)
            }
        }
    }
    
    private var buttonColor: Color {
        if set.completedAt != nil {
            return .green
        } else if canComplete {
            return .secondary
        } else {
            return .red.opacity(0.6)
        }
    }
    
    private var canComplete: Bool {
        switch trackingMode {
        case .weightReps:
            let hasValidWeight = set.weightKg == nil || set.weightKg! >= 0
            let hasValidReps = set.reps != nil && set.reps! > 0
            return hasValidWeight && hasValidReps
            
        case .repsOnly:
            return set.reps != nil && set.reps! > 0
            
        case .timeOnly:
            return set.durationSec != nil && set.durationSec! > 0
            
        case .distanceTime:
            let hasValidDistance = set.distanceMeters != nil && set.distanceMeters! > 0
            let hasValidTime = set.durationSec != nil && set.durationSec! > 0
            return hasValidDistance && hasValidTime
        }
    }
    
    // MARK: - Validation
    
    private func validateSetData() -> Bool {
        switch trackingMode {
        case .weightReps:
            return validateWeightReps()
        case .repsOnly:
            return validateRepsOnly()
        case .timeOnly:
            return validateTimeOnly()
        case .distanceTime:
            return validateDistanceTime()
        }
    }
    
    private func validateWeightReps() -> Bool {
        // Weight must be non-negative (including 0 for bodyweight exercises)
        if let weight = set.weightKg, weight < 0 {
            showAlert = AnyAppAlert(title: "Invalid Set Data", subtitle: "Weight must be a non-negative number")
            return false
        }
        
        // Reps must be positive
        guard let reps = set.reps, reps > 0 else {
            showAlert = AnyAppAlert(title: "Invalid Set Data", subtitle: "Reps must be a positive number")
            return false
        }
        
        return true
    }
    
    private func validateRepsOnly() -> Bool {
        // Reps must be positive
        guard let reps = set.reps, reps > 0 else {
            showAlert = AnyAppAlert(title: "Invalid Set Data", subtitle: "Reps must be a positive number")
            return false
        }
        
        return true
    }
    
    private func validateTimeOnly() -> Bool {
        // Time must be positive
        guard let duration = set.durationSec, duration > 0 else {
            showAlert = AnyAppAlert(title: "Invalid Set Data", subtitle: "Duration must be a positive time")
            return false
        }
        
        return true
    }
    
    private func validateDistanceTime() -> Bool {
        // Distance must be positive
        guard let distance = set.distanceMeters, distance > 0 else {
            showAlert = AnyAppAlert(title: "Invalid Set Data", subtitle: "Distance must be a positive number")
            return false
        }
        
        // Time must be positive
        guard let duration = set.durationSec, duration > 0 else {
            showAlert = AnyAppAlert(title: "Invalid Set Data", subtitle: "Duration must be a positive time")
            return false
        }
        
        return true
    }
    
}

#Preview("Weight & Reps - Incomplete") {
    SetTrackerRow(
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
    .padding()
}

#Preview("Weight & Reps - Complete") {
    SetTrackerRow(
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
}

#Preview("Duration - Incomplete") {
    SetTrackerRow(
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
}

#Preview("Duration - Complete") {
    SetTrackerRow(
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
}

#Preview("Distance - Incomplete") {
    SetTrackerRow(
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
}

#Preview("Distance - Complete") {
    SetTrackerRow(
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
}

#Preview("Warmup Set") {
    SetTrackerRow(
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
}

#Preview("All Fields Populated") {
    SetTrackerRow(
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
}

#Preview("Edge: No Data") {
    SetTrackerRow(
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
}
