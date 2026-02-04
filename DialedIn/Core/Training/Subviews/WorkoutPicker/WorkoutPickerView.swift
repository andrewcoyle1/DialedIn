//
//  WorkoutPickerSheet.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct WorkoutPickerDelegate {
    /// Strongly-typed callbacks used by calling code
    let onSelectWorkout: (WorkoutTemplateModel) -> Void
    let onCancelWorkout: () -> Void

    /// Protocol requirements (type-erased to `any TemplateModel`)
    var onSelect: (any TemplateModel) -> Void {
        { template in
            guard let workout = template as? WorkoutTemplateModel else { return }
            self.onSelectWorkout(workout)
        }
    }

    var onCancel: () -> Void {
        onCancelWorkout
    }

    init(
        onSelect: @escaping (WorkoutTemplateModel) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.onSelectWorkout = onSelect
        self.onCancelWorkout = onCancel
    }
}

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

extension CoreBuilder {
    func workoutPickerSheet(router: AnyRouter, delegate: WorkoutPickerDelegate) -> some View {
        WorkoutPickerView(
            presenter: WorkoutPickerPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate,
            workoutListBuilderView: { delegate in
                self.workoutListViewBuilder(router: router, delegate: delegate)
            }
        )
    }
}

extension CoreRouter {
    func showWorkoutPickerView(delegate: WorkoutPickerDelegate) {
        router.showScreen(.sheet) { router in
            builder.workoutPickerSheet(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
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
