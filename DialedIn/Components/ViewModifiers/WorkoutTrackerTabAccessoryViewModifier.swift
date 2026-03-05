//
//  WorkoutTrackerTabAccessoryViewModifier.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/12/2025.
//

import SwiftUI

struct WorkoutTrackerTabAccessoryViewModifier<TrackerView: View>: ViewModifier {

    @State private var didAppear: Bool = false
    let active: WorkoutSessionModel?
    let trainingAccessoryView: (TrainingAccessoryDelegate) -> TrackerView
    
    func body(content: Content) -> some View {
        if let session = active {
            content
                .tabViewBottomAccessory {
                    trainingAccessoryView(TrainingAccessoryDelegate(active: session))
                }
        } else {
            content
        }
    }
}

extension View {
    func workoutTabAccessory(active: WorkoutSessionModel?, trainingAccessoryView: @escaping (TrainingAccessoryDelegate) -> some View) -> some View {
        modifier(WorkoutTrackerTabAccessoryViewModifier(active: active, trainingAccessoryView: trainingAccessoryView))
    }
}
