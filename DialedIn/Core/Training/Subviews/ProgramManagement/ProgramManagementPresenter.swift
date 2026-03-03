//
//  ProgramManagementPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProgramManagementPresenter {
    private let interactor: ProgramManagementInteractor
    private let router: ProgramManagementRouter
    
    var savedPrograms: [TrainingProgram] {
        interactor.trainingPrograms
    }
    
    init(
        interactor: ProgramManagementInteractor,
        router: ProgramManagementRouter
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

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    func dismissScreen() {
        router.dismissScreen()
    }
}

extension ProgramManagementPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        case deleteProgramStart
        case deleteProgramSuccess
        case deleteProgramFail(error: Error)

        var eventName: String {
            switch self {
            case .onAppear:             return "ProgramManagementView_Appear"
            case .onDisappear:          return "ProgramManagementView_Disappear"
            case .deleteProgramStart:   return "ProgramManagementView_Start"
            case .deleteProgramSuccess: return "ProgramManagementView_Success"
            case .deleteProgramFail:    return "ProgramManagementView_Fail"
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
