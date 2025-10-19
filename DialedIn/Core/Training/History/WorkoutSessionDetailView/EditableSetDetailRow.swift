//
//  EditableSetDetailRow.swift
//  DialedIn
//
//  Created by AI Assistant
//

import SwiftUI

struct EditableSetDetailRow: View {
    @Binding var set: WorkoutSetModel
    let trackingMode: TrackingMode
    let weightUnit: ExerciseWeightUnit
    let distanceUnit: ExerciseDistanceUnit
    
    @State private var showWarmupHelp = false
    @State private var showAlert: AnyAppAlert?
    
    private var cellHeight: CGFloat = 35
    
    init(
        set: Binding<WorkoutSetModel>,
        trackingMode: TrackingMode,
        weightUnit: ExerciseWeightUnit,
        distanceUnit: ExerciseDistanceUnit
    ) {
        self._set = set
        self.trackingMode = trackingMode
        self.weightUnit = weightUnit
        self.distanceUnit = distanceUnit
    }
    
    var body: some View {
        HStack {
            // Set number with warmup menu
            setNumber
            
            Spacer()
            
            // Input fields based on tracking mode
            inputFields
            
            Spacer()
            
            // RPE field
            rpeField
        }
        .padding(.vertical, 4)
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
    
    // MARK: - Set Number with Menu
    
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
}

#Preview("Weight & Reps") {
    EditableSetDetailRow(
        set: .constant(WorkoutSetModel(
            id: "1",
            authorId: "user1",
            index: 1,
            reps: 8,
            weightKg: 60.0,
            durationSec: nil,
            distanceMeters: nil,
            rpe: 8.5,
            isWarmup: false,
            completedAt: Date(),
            dateCreated: Date()
        )),
        trackingMode: .weightReps,
        weightUnit: .kilograms,
        distanceUnit: .meters
    )
    .padding()
}

#Preview("Warmup Set") {
    EditableSetDetailRow(
        set: .constant(WorkoutSetModel(
            id: "2",
            authorId: "user1",
            index: 1,
            reps: 5,
            weightKg: 20.0,
            durationSec: nil,
            distanceMeters: nil,
            rpe: nil,
            isWarmup: true,
            completedAt: Date(),
            dateCreated: Date()
        )),
        trackingMode: .weightReps,
        weightUnit: .kilograms,
        distanceUnit: .meters
    )
    .padding()
}
