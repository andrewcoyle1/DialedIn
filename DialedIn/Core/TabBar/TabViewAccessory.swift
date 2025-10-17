//
//  TabViewAccessory.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI

struct TabViewAccessory: View {
    @Environment(WorkoutSessionManager.self) private var workoutSessionManager
    let active: WorkoutSessionModel
    
    var body: some View {
        Button {
            workoutSessionManager.reopenActiveSession()
        } label: {
            HStack {
                iconSection
                workoutDescriptionSection
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var iconSection: some View {
        // Icon
        Image(systemName: isRestActive ? "timer" : "figure.strengthtraining.traditional")
            .foregroundStyle(isRestActive ? .orange : .accent)
    }
    
    private var workoutDescriptionSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                workoutName
                Spacer()
                timeSection(workoutSession: active)
            }
            ProgressView(value: progress)
        }
        .padding(.bottom, 6)
    }
    
    private var workoutName: some View {
        Text(active.name)
            .font(.subheadline)
            .fontWeight(.semibold)
            .lineLimit(1)
            .padding(.trailing)
    }

    private func timeSection(workoutSession active: WorkoutSessionModel) -> some View {
        Group {
            if let restEndTime = workoutSessionManager.restEndTime {
                let now = Date()
                if now < restEndTime {
                    // Rest timer
                    HStack(alignment: .bottom, spacing: 4) {
                        Text("Rest: ")
                        Text(timerInterval: now...restEndTime)
                            .monospacedDigit()
                            .foregroundStyle(.orange)
                    }
                } else {
                    HStack(alignment: .bottom, spacing: 4) {
                        Text("Rest: ")
                        Text("00:00")
                            .monospacedDigit()
                            .foregroundStyle(.orange)
                    }
                }
            } else {
                // Elapsed time
                HStack(spacing: 4) {
                    Text("Elapsed: ")
                    Text(active.dateCreated, style: .timer)
                        .monospacedDigit()
                }
            }
        }
        .foregroundStyle(.secondary)
        .font(.subheadline)
        .multilineTextAlignment(.trailing)
        .fixedSize(horizontal: true, vertical: true)
    }
    
    private var progress: Double {
        guard let active = workoutSessionManager.activeSession else { return 0 }
        return Double(completedSetsCount(active)) / Double(totalSetsCount(active))
    }

    private var progressLabel: String {
        guard let active = workoutSessionManager.activeSession else { return "" }
        return "\(completedSetsCount(active))/\(totalSetsCount(active)) sets"
    }
    private var isRestActive: Bool {
        guard let end = workoutSessionManager.restEndTime else { return false }
        return Date() < end
    }

    private func completedSetsCount(_ session: WorkoutSessionModel) -> Int {
        session.exercises.flatMap(\.sets).filter { $0.completedAt != nil }.count
    }

    private func totalSetsCount(_ session: WorkoutSessionModel) -> Int {
        session.exercises.flatMap(\.sets).count
    }

    private func totalVolume(_ session: WorkoutSessionModel) -> Double {
        session.exercises.flatMap(\.sets)
            .compactMap { set -> Double? in
                guard let weight = set.weightKg, let reps = set.reps else { return nil }
                return weight * Double(reps)
            }
            .reduce(0.0, +)
    }
    
}

#Preview {
    TabView {
        Tab {
            Text("Tab")
        } label: {
            Text("Tab")
        }
    }
    .tabViewBottomAccessory {
        TabViewAccessory(active: .mock)
    }
    .previewEnvironment()
}
