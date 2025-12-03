//
//  TabViewAccessoryView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI
import CustomRouting

struct TabViewAccessoryView: View {
    
    @State var presenter: TabViewAccessoryPresenter
    
    let delegate: TabViewAccessoryDelegate
    
    var body: some View {
        HStack {
            iconSection
            workoutDescriptionSection
        }
        .frame(maxWidth: .infinity)
    }
    
    private var iconSection: some View {
        // Icon
        Image(systemName: presenter.isRestActive ? "timer" : "figure.strengthtraining.traditional")
            .foregroundStyle(presenter.isRestActive ? .orange : .accent)
    }
    
    private var workoutDescriptionSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                workoutName
                Spacer()
                timeSection(workoutSession: delegate.active)
            }
            ProgressView(value: presenter.progress)
        }
        .padding(.bottom, 6)
    }
    
    private var workoutName: some View {
        Text(delegate.active.name)
            .font(.subheadline)
            .fontWeight(.semibold)
            .lineLimit(1)
            .padding(.trailing)
    }

    private func timeSection(workoutSession active: WorkoutSessionModel) -> some View {
        Group {
            if let restEndTime = presenter.restEndTime {
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
    @Previewable @State var isPresented: Bool = false
    let builder = CoreBuilder(container: DevPreview.shared.container)
    TabView {
        Tab {
            Text("Tab")
        } label: {
            Text("Tab")
        }
    }
    .tabViewBottomAccessory {
        builder.tabViewAccessoryView(
            delegate: TabViewAccessoryDelegate(active: .mock)
        )
        .onTapGesture {
            isPresented = true
        }
    }
    .fullScreenCover(isPresented: $isPresented) {
        
    }
    .previewEnvironment()
}
