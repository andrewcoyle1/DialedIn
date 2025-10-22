//
//  TabViewAccessoryView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI

struct TabViewAccessoryView: View {
    @State var viewModel: TabViewAccessoryViewModel
    let active: WorkoutSessionModel
    
    var body: some View {
        Button {
            viewModel.reopenActiveSession()
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
        Image(systemName: viewModel.isRestActive ? "timer" : "figure.strengthtraining.traditional")
            .foregroundStyle(viewModel.isRestActive ? .orange : .accent)
    }
    
    private var workoutDescriptionSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                workoutName
                Spacer()
                timeSection(workoutSession: active)
            }
            ProgressView(value: viewModel.progress)
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
            if let restEndTime = viewModel.restEndTime {
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
        TabViewAccessoryView(viewModel: TabViewAccessoryViewModel(container: DevPreview.shared.container), active: .mock)
    }
    .previewEnvironment()
}
