//
//  CoreBuilder.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/11/2025.
//

import SwiftUI
import SwiftfulRouting

private struct WorkoutStartMiddleContent: View {
    let template: WorkoutTemplateModel
    
    var body: some View {
        let minutes = template.exercises.count * 4
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        let exerciseCount: String = hours > 0
            ? "\(hours)h \(remainingMinutes)m"
            : "\(remainingMinutes)m"
        
        let categories = template.exercises.map { $0.exercise.type }
        let categoryFrequency = Dictionary(grouping: categories, by: { $0 })
            .mapValues { $0.count }
        
        let mostCommon = categoryFrequency.max(by: { $0.value < $1.value })?.key?.name ?? "Mixed"
        
        HStack(alignment: .firstTextBaseline) {
            StatCard(
                value: "\(template.exercises.count)",
                label: "Exercises"
            )
            StatCard(
                value: exerciseCount,
                label: "Est. Time"
            )
            StatCard(
                value: mostCommon,
                label: "Focus"
            )
        }
    }
}

@MainActor
struct CoreBuilder: Builder {

    let interactor: CoreInteractor
    
    init(interactor: CoreInteractor) {
        self.interactor = interactor
    }
    
    init(container: DependencyContainer) {
        self.interactor = CoreInteractor(container: container)
    }
    
    func build() -> AnyView {
        RouterView(id: "tabbar", addNavigationStack: false, addModuleSupport: true) { router in
            adaptiveMainView(router: router)
        }
        .any()
    }
    
    func workoutStartModal(delegate: WorkoutStartDelegate) -> some View {
        CustomModalView(
            title: delegate.template.name,
            subtitle: nil,
            primaryButtonTitle: "Start",
            primaryButtonAction: {
                delegate.onStartWorkoutPressed?()
            },
            secondaryButtonTitle: "Dismiss",
            secondaryButtonAction: { delegate.onCancelPressed?() },
            middleContent: AnyView(
                WorkoutStartMiddleContent(template: delegate.template)
            )
        )
    }

}
