import SwiftUI

@Observable
@MainActor
class NameProgramPresenter {
    
    private let interactor: NameProgramInteractor
    private let router: NameProgramRouter
    
    var programName: String
    
    var canSave: Bool { !programName.isEmpty }
    
    init(interactor: NameProgramInteractor, router: NameProgramRouter) {
        self.interactor = interactor
        self.router = router
        
        self.programName = Date.now.formattedDate
    }
    
    func onNextPressed() {
        router.showProgramIconView(delegate: ProgramIconDelegate(name: programName))
    }
}
