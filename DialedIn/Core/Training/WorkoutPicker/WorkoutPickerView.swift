//
//  WorkoutPickerSheet.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct WorkoutPickerView<WorkoutListView: View>: View {
    
    @State var presenter: WorkoutPickerPresenter
    
    let delegate: WorkoutPickerDelegate
    
    @ViewBuilder var workoutListBuilderView: (WorkoutListDelegateBuilder) -> WorkoutListView
    
    var body: some View {
        let delegate = WorkoutListDelegateBuilder(
            onWorkoutSelectionChanged: { template in
                presenter.onWorkoutPressed(
                    template: template,
                    onSelect: self.delegate.onSelectWorkout
                )
            }
        )
        workoutListBuilderView(delegate)
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = WorkoutPickerDelegate(
        onSelect: { template in
            print(template.name)
        },
        onCancel: {
            print("Cancel")
        }
    )
    RouterView { router in
        builder.workoutPickerSheet(router: router, delegate: delegate)
    }
}
