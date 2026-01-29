//
//  WorkoutsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
import SwiftfulRouting

struct WorkoutsView<WorkoutList: View>: View {

    @State var presenter: WorkoutsPresenter

    @ViewBuilder var workoutListViewBuilder: (WorkoutListDelegateBuilder) -> WorkoutList
    
    var body: some View {
        let delegate = WorkoutListDelegateBuilder(onWorkoutSelectionChanged: presenter.onWorkoutPressed)
        workoutListViewBuilder(delegate)
    }
}

extension CoreBuilder {
    func workoutsView(router: AnyRouter) -> some View {
        WorkoutsView(
            presenter: WorkoutsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            workoutListViewBuilder: { delegate in
                self.workoutListViewBuilder(router: router, delegate: delegate)
            }
        )
    }
}

extension CoreRouter {
    func showWorkoutsView() {
        router.showScreen(.push) { router in
            builder.workoutsView(router: router)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.workoutsView(router: router)
    }
    .previewEnvironment()
}
