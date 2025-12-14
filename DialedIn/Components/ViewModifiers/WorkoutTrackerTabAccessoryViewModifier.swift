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
    let tabViewAccessoryView: (TabViewAccessoryDelegate) -> TrackerView
    
    func body(content: Content) -> some View {
        if let session = active {
            content
                .tabViewBottomAccessory {
                    tabViewAccessoryView(TabViewAccessoryDelegate(active: session))
                }
        } else {
            content
        }
    }
}

extension View {
    func workoutTabAccessory(active: WorkoutSessionModel?, tabViewAccessoryView: @escaping (TabViewAccessoryDelegate) -> some View) -> some View {
        modifier(WorkoutTrackerTabAccessoryViewModifier(active: active, tabViewAccessoryView: tabViewAccessoryView))
    }
}
