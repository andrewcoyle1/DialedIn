//
//  WorkoutPickerDelegate.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/12/2025.
//

struct WorkoutPickerDelegate: GenericTemplateListDelegate {
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
