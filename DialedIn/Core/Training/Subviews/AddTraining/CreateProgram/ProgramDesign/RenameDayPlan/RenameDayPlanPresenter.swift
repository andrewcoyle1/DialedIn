import SwiftUI

@Observable
@MainActor
class RenameDayPlanPresenter {
    private let interactor: RenameDayPlanInteractor
    private let router: RenameDayPlanRouter

    var nameText: String

    var canSave: Bool {
        !nameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(
        interactor: RenameDayPlanInteractor,
        router: RenameDayPlanRouter,
        initialName: String
    ) {
        self.interactor = interactor
        self.router = router
        self.nameText = initialName
    }

    func onCancelPressed() {
        router.dismissScreen()
    }

    func onSavePressed(onSave: (String) -> Void) {
        let trimmedName = nameText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        onSave(trimmedName)
        router.dismissScreen()
    }
}
