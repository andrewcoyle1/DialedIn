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
    let onUpdate: (WorkoutSetModel) -> Void
    let onDelete: () -> Void
    
    // Validation state
    @State private var showAlert: AnyAppAlert?
    
    init(set: WorkoutSetModel, trackingMode: TrackingMode, onUpdate: @escaping (WorkoutSetModel) -> Void, onDelete: @escaping () -> Void) {
        self._set = State(initialValue: set)
        self.trackingMode = trackingMode
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Set number
            Text("\(set.index)")
                .font(.caption.bold())
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Spacer()
            // Input fields based on tracking mode
            inputFields
            
            // RPE input (optional for all tracking modes)
            rpeField
            
            // Complete button
            completeButton
            
            // Delete button
            deleteButton
        }
        .padding(.horizontal)
        .onChange(of: set) { _, newValue in
            onUpdate(newValue)
        }
        .showCustomAlert(alert: $showAlert)
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
            // Weight input
            VStack(alignment: .leading, spacing: 2) {
                Text("Weight")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                TextField("0", value: $set.weightKg, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
            }
            .frame(width: 60)

            // Reps input
            VStack(alignment: .leading, spacing: 2) {
                Text("Reps")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                TextField("0", value: $set.reps, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
            }
            .frame(width: 50)
        }
    }
    
    private var repsOnlyFields: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Reps")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            TextField("0", value: $set.reps, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
        }
        .frame(width: 60)
    }
    
    private var timeOnlyFields: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Duration")
                .font(.caption2)
                .foregroundColor(.secondary)
            
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

        }
    }
    
    private var distanceTimeFields: some View {
        HStack(spacing: 8) {
            // Distance input
            VStack(alignment: .leading, spacing: 2) {
                Text("Distance")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                TextField("0", value: $set.distanceMeters, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
            }
            .frame(width: 60)

            // Time input
            VStack(alignment: .leading, spacing: 2) {
                Text("Time")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
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
            }
            .frame(width: 80)
        }
    }
    
    // MARK: - RPE Field
    
    private var rpeField: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("RPE")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            TextField("0", value: $set.rpe, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
        }
        .frame(width: 45)
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
            Image(systemName: set.completedAt != nil ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundColor(buttonColor)
        }
        .buttonStyle(PlainButtonStyle())
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
    
    private var deleteButton: some View {
        Button {
            onDelete()
        } label: {
            Image(systemName: "minus.circle.fill")
                .font(.title3)
                .foregroundColor(.red)
        }
        .buttonStyle(PlainButtonStyle())
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
        onUpdate: { _ in },
        onDelete: {}
    )
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
        onUpdate: { _ in },
        onDelete: {}
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
        onUpdate: { _ in },
        onDelete: {}
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
        onUpdate: { _ in },
        onDelete: {}
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
        onUpdate: { _ in },
        onDelete: {}
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
        onUpdate: { _ in },
        onDelete: {}
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
        onUpdate: { _ in },
        onDelete: {}
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
        onUpdate: { _ in },
        onDelete: {}
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
        onUpdate: { _ in },
        onDelete: {}
    )
}
