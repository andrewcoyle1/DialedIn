//
//  WorkoutTrackerView.swift
//  DialedIn
//
//  Created by AI Assistant on 23/09/2025.
//

import SwiftUI

struct WorkoutTrackerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var exercises: [WorkoutExercise]
    @State private var restSecondsRemaining: Int = 0
    @State private var isResting: Bool = false
    
    private let restDefaultSeconds: Int = 90
    
    init(exercise: WorkoutExercise) {
        _exercises = State(initialValue: [exercise])
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach($exercises) { $exercise in
                    exerciseSection(exercise: $exercise)
                }
            }
            .navigationTitle("Workout Name")
            .navigationSubtitle("Elapsed Time")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: { Image(systemName: "xmark") }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: { Image(systemName: "checkmark") }
                        .buttonStyle(.glassProminent)
                }
                ToolbarItem(placement: .bottomBar) {
                    restBar
                }
            }
        }
    }
    
    @ViewBuilder
    private func exerciseSection(exercise: Binding<WorkoutExercise>) -> some View {
        let setsBinding = Binding<[WorkoutSet]>(
            get: { exercise.wrappedValue.sets },
            set: { exercise.wrappedValue.sets = $0 }
        )
        Section {
            WorkoutSetHeaderView(trackingMode: exercise.wrappedValue.trackingMode)
            ForEach(setsBinding) { $set in
                WorkoutSetRowView(
                    set: $set,
                    trackingMode: exercise.wrappedValue.trackingMode
                )
            }
            .onDelete { offsets in
                onDelete(exercise: exercise, at: offsets)
            }
            
            Button {
                addSet(exercise: exercise)
            } label: {
                Label("Add Set", systemImage: "plus")
            }
        } header: {
            Text(exercise.wrappedValue.name)
        }
        
        if let notes = exercise.wrappedValue.notes {
            Section(header: Text("Notes")) {
                Text(notes)
            }
        }
    }
    
    private func onDelete(exercise: Binding<WorkoutExercise>, at offsets: IndexSet) {
        exercise.wrappedValue.sets.remove(atOffsets: offsets)
        for iterator in exercise.wrappedValue.sets.indices {
            exercise.wrappedValue.sets[iterator].index = iterator + 1
        }
    }
    
    private func addSet(exercise: Binding<WorkoutExercise>) {
        let nextIndex = exercise.wrappedValue.sets.count + 1
        let last = exercise.wrappedValue.sets.last
        var newSet = WorkoutSet(
            id: UUID().uuidString,
            authorId: "mock",
            index: nextIndex,
            reps: nil,
            weightKg: nil,
            durationSec: nil,
            distanceMeters: nil,
            rpe: nil,
            isWarmup: false,
            completedAt: nil,
            dateCreated: Date()
        )
        // Simple autofill from last set when applicable
        if exercise.wrappedValue.trackingMode == .weightReps {
            newSet.reps = last?.reps ?? 8
            newSet.weightKg = last?.weightKg ?? 20
        } else if exercise.wrappedValue.trackingMode == .repsOnly {
            newSet.reps = last?.reps ?? 12
        } else if exercise.wrappedValue.trackingMode == .timeOnly {
            newSet.durationSec = last?.durationSec ?? 60
        } else if exercise.wrappedValue.trackingMode == .distanceTime {
            newSet.durationSec = last?.durationSec ?? 120
            newSet.distanceMeters = last?.distanceMeters ?? 400
        }
        exercise.wrappedValue.sets.append(newSet)
    }

    private var restBar: some View {
        HStack(spacing: 12) {
            Button {
                if isResting { stopRest() } else { startRest() }
            } label: {
                Label(isResting ? "Stop Rest" : "Start Rest", systemImage: isResting ? "stop.circle" : "timer")
            }
            .buttonStyle(.bordered)
            
            if isResting {
                Text(timeString(restSecondsRemaining))
                    .monospacedDigit()
                    .padding(.horizontal, 8)
            }
            Spacer()
        }
    }
    
    private func startRest() {
        restSecondsRemaining = restDefaultSeconds
        isResting = true
        Task { await tickRestTimer() }
    }
    
    private func stopRest() {
        isResting = false
        restSecondsRemaining = 0
    }
    
    private func tickRestTimer() async {
        while isResting && restSecondsRemaining > 0 {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if !isResting { break }
            restSecondsRemaining -= 1
        }
        if restSecondsRemaining <= 0 {
            isResting = false
        }
    }
    
    private func timeString(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

private struct WorkoutSetRowView: View {
    @Binding var set: WorkoutSet
    let trackingMode: TrackingMode
    
    var body: some View {
        VStack {
  
            HStack(alignment: .center) {
                // Set number
                    Text("\(set.index)")
                        .fontWeight(.semibold)
                .frame(width: 60, alignment: .center)
                
                    Text("\(0)")
                .frame(width: 60, alignment: .center)
                
                // Reps input
                    TextField(
                        "",
                        text: Binding(
                            get: { set.reps.map { String($0) } ?? "" },
                            set: { set.reps = Int($0) }
                        )
                    )
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .frame(width: 60)
                
                // Weight input
                     TextField(
                        "",
                        text: Binding(
                            get: { set.weightKg.map { String(format: "%.1f", $0) } ?? "" },
                            set: { set.weightKg = Double($0) }
                        )
                    )
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .frame(width: 60)
                
                    Toggle(isOn: Binding(
                        get: { set.completedAt != nil },
                        set: { isOn in set.completedAt = isOn ? Date() : nil }
                    )) {
                        Text("Completed")
                    }
                    .toggleStyle(.switch)
                    .labelsHidden()
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 4)
    }
}

private struct WorkoutSetHeaderView: View {
    let trackingMode: TrackingMode

    private var columns: [HeaderColumn] {
        var cols: [HeaderColumn] = [
            .init(title: "Set", width: 60),
            .init(title: "Previous", width: 60)
        ]
        switch trackingMode {
        case .weightReps:
            cols.append(.init(title: "Weight", width: 60))
            cols.append(.init(title: "Reps", width: 60))
        case .distanceTime:
            cols.append(.init(title: "Distance", width: 60))
            cols.append(.init(title: "Time", width: 60))
        case .repsOnly:
            cols.append(.init(title: "Reps", width: 128))
        case .timeOnly:
            cols.append(.init(title: "Time", width: 128))
        }
        cols.append(.init(title: "Complete", width: 60))
        return cols
    }

    var body: some View {
        HStack {
            ForEach(columns, id: \.title) { column in
                Text(column.title)
                    .font(.caption)
                    .frame(width: column.width)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private struct HeaderColumn {
        let title: String
        let width: CGFloat
    }
}

#Preview {
    NavigationStack {
        WorkoutTrackerView(exercise: WorkoutExercise.mock)
    }
}

#Preview("Workout Set Header View") {
    NavigationStack {
        WorkoutSetHeaderView(trackingMode: .weightReps)
        WorkoutSetHeaderView(trackingMode: .repsOnly)
        WorkoutSetHeaderView(trackingMode: .timeOnly)
        WorkoutSetHeaderView(trackingMode: .distanceTime)
    }
}

#Preview("Workout Set Row View") {
    ScrollView {
        WorkoutSetHeaderView(trackingMode: .weightReps)
        WorkoutSetRowView(set: Binding.constant(.mocks[0]), trackingMode: .weightReps)
        WorkoutSetRowView(set: Binding.constant(.mocks[1]), trackingMode: .distanceTime)
        WorkoutSetRowView(set: Binding.constant(.mocks[2]), trackingMode: .repsOnly)
        WorkoutSetRowView(set: Binding.constant(.mocks[3]), trackingMode: .timeOnly)
        WorkoutSetRowView(set: Binding.constant(.mocks[4]), trackingMode: .weightReps)
            .background(Color.blue)

    }
}
