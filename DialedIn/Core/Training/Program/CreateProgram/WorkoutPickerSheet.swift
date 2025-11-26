//
//  WorkoutPickerSheet.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/10/2025.
//

import SwiftUI
import CustomRouting

struct WorkoutPickerSheetDelegate: GenericTemplateListViewDelegate {
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

typealias WorkoutPickerSheet = GenericTemplatePickerView<WorkoutTemplateModel>
typealias WorkoutPickerSheetViewModel = GenericTemplatePickerViewModel<WorkoutTemplateModel>

extension GenericTemplatePickerView where Template == WorkoutTemplateModel {
    init(
        interactor: CoreInteractor,
        router: CoreRouter,
        delegate: WorkoutPickerSheetDelegate
    ) {
        let viewModel = GenericTemplatePickerViewModel<WorkoutTemplateModel>(
            getAllLocalTemplates: { try interactor.getAllLocalWorkoutTemplates() },
            getTemplatesByName: { try await interactor.getWorkoutTemplatesByName(name: $0) },
            getTopTemplatesByClicks: { try await interactor.getTopWorkoutTemplatesByClicks(limitTo: $0) },
            getTemplatesForAuthor: { try await interactor.getWorkoutTemplatesForAuthor(authorId: $0) },
            getAuthId: { interactor.auth?.uid },
            configuration: .workout,
            onSelect: { template in
                delegate.onSelect(template)
            },
            onCancel: {
                delegate.onCancel()
            }
        )

        self.init(
            viewModel: viewModel,
            delegate: delegate
        )
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = WorkoutPickerSheetDelegate(
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
