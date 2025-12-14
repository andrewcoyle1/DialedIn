//
//  WorkoutTrackerRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 09/12/2025.
//

import SwiftUI
import SwiftfulRouting

@MainActor
protocol WorkoutTrackerRouter: GlobalRouter {
    func showDevSettingsView()
    func showAddExercisesView(delegate: AddExerciseModalDelegate)
    func showWorkoutNotesView(delegate: WorkoutNotesDelegate)
        
    func showRestModal(primaryButtonAction: @escaping () -> Void, secondaryButtonAction: @escaping () -> Void, minutesSelection: Binding<Int>, secondsSelection: Binding<Int>)
}

extension CoreRouter: WorkoutTrackerRouter {
    func showRestModal(
        primaryButtonAction: @escaping () -> Void,
        secondaryButtonAction: @escaping () -> Void,
        minutesSelection: Binding<Int>,
        secondsSelection: Binding<Int>
    ) {
        router.showModal(
            transition: .opacity,
            backgroundColor: .black.opacity(0.3),
            destination: {
                CustomModalView(
                    title: "Set Rest",
                    subtitle: nil,
                    primaryButtonTitle: "Save",
                    primaryButtonAction: {
                        primaryButtonAction()
                    },
                    secondaryButtonTitle: "Cancel",
                    secondaryButtonAction: { secondaryButtonAction() },
                    middleContent: AnyView(
                        HStack(spacing: 16) {
                            Picker("Minutes", selection: minutesSelection) {
                                ForEach(0..<60, id: \.self) { minute in
                                    Text("\(minute) m").tag(minute)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            
                            Picker("Seconds", selection: secondsSelection) {
                                ForEach(0..<60, id: \.self) { second in
                                    Text("\(second) s").tag(second)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                        }
                            .frame(height: 180)
                    )
                )
            }
        )
    }
}
