//
//  WorkoutPickerSheet.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/10/2025.
//

import SwiftUI

typealias WorkoutPickerSheet = GenericTemplatePickerView<WorkoutTemplateModel>
typealias WorkoutPickerSheetViewModel = GenericTemplatePickerViewModel<WorkoutTemplateModel>

extension GenericTemplatePickerView where Template == WorkoutTemplateModel {
    init(
        interactor: CoreInteractor,
        onSelect: @escaping (WorkoutTemplateModel) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.init(
            viewModel: GenericTemplatePickerViewModel(
                getAllLocalTemplates: { try interactor.getAllLocalWorkoutTemplates() },
                getTemplatesByName: { try await interactor.getWorkoutTemplatesByName(name: $0) },
                getTopTemplatesByClicks: { try await interactor.getTopWorkoutTemplatesByClicks(limitTo: $0) },
                getTemplatesForAuthor: { try await interactor.getWorkoutTemplatesForAuthor(authorId: $0) },
                getAuthId: { interactor.auth?.uid },
                configuration: .workout,
                onSelect: onSelect,
                onCancel: onCancel
            )
        )
    }
}

#Preview {
    WorkoutPickerSheet(
        interactor: CoreInteractor(
            container: DevPreview.shared.container
        ),
        onSelect: { template in
            print(template.name)
        },
        onCancel: {
            print("Cancel")
        }
    )
}
