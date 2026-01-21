import SwiftUI

@Observable
@MainActor
class AddTrainingPresenter {
    
    private let interactor: AddTrainingInteractor
    private let router: AddTrainingRouter
    private let delegate: AddTrainingDelegate
    
    init(interactor: AddTrainingInteractor, router: AddTrainingRouter, delegate: AddTrainingDelegate) {
        self.interactor = interactor
        self.router = router
        self.delegate = delegate
    }
    
    func onNewProgramPressed() {
        router.dismissScreen()
        delegate.onSelectProgram?()
    }
    
    func onNewEmptyWorkoutPressed() {
        router.dismissScreen()
        delegate.onSelectWorkout?()
    }
    
    func dismissScreen() {
        router.dismissScreen()
    }
}
