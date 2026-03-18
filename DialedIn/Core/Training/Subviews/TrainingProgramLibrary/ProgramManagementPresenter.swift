//
//  TrainingProgramLibraryPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class TrainingProgramLibraryPresenter {
    private let interactor: TrainingProgramLibraryInteractor
    private let router: TrainingProgramLibraryRouter
    
    var activeTrainingProgram: TrainingProgram? {
        interactor.activeTrainingProgram
    }
    
    var nonActiveTrainingPrograms: [TrainingProgram] {
        savedPrograms.filter { $0.id != activeTrainingProgram?.id }
    }
    
    var savedPrograms: [TrainingProgram] {
        interactor.trainingPrograms
    }
    
    init(
        interactor: TrainingProgramLibraryInteractor,
        router: TrainingProgramLibraryRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func showDeleteAlert(program: TrainingProgram) {
        router.showAlert(
            title: "Delete Program",
            subtitle: "Are you sure you want to delete your active program '\(program.name)'? This will remove all scheduled workouts and you'll need to create or select a new program.",
            buttons: {
                AnyView(
                    Group {
                        Button("Cancel", role: .cancel) { }
                        Button("Delete", role: .destructive) {
                            Task {
                                await self.deleteProgram(program)
                            }
                        }
                    }
                )
            }
        )
    }

    func onSavedProgramPressed(_ program: TrainingProgram) {
        router.showEditTrainingProgramView(delegate: EditTrainingProgramDelegate(program: program))
    }
    
    func deleteProgram(_ program: TrainingProgram) async {
        interactor.trackEvent(event: Event.deleteProgramStart)
        do {
            try await interactor.deleteTrainingProgram(programId: program.id)
            interactor.trackEvent(event: Event.deleteProgramSuccess)
        } catch {
            interactor.trackEvent(event: Event.deleteProgramFail(error: error))
        }
    }
        
    func onCreateProgramPressed() {
        router.showCreateProgramView(delegate: CreateProgramDelegate())
    }

#if DEV || MOCK
func onDevSettingsPressed() {
    router.showDevSettingsView()
}
#endif

    func dismissScreen() {
        router.dismissScreen()
    }
}

extension TrainingProgramLibraryPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        case deleteProgramStart
        case deleteProgramSuccess
        case deleteProgramFail(error: Error)

        var eventName: String {
            switch self {
            case .onAppear:             return "TrainingProgramLibraryView_Appear"
            case .onDisappear:          return "TrainingProgramLibraryView_Disappear"
            case .deleteProgramStart:   return "TrainingProgramLibraryView_Start"
            case .deleteProgramSuccess: return "TrainingProgramLibraryView_Success"
            case .deleteProgramFail:    return "TrainingProgramLibraryView_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .deleteProgramFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .deleteProgramFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
