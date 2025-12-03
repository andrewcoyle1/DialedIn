//
//  WorkoutsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
import CustomRouting

struct WorkoutsView<WorkoutList: View>: View {

    @State var presenter: WorkoutsPresenter

    @ViewBuilder var workoutListViewBuilder: (WorkoutListDelegateBuilder) -> WorkoutList
    
    var body: some View {
        let delegate = WorkoutListDelegateBuilder(onWorkoutSelectionChanged: presenter.onWorkoutPressed)
        workoutListViewBuilder(delegate)
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.workoutsView(router: router)
    }
    .previewEnvironment()
}
