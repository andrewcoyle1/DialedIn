//
//  ProgramTemplatePickerPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProgramTemplatePickerPresenter {
    private let interactor: ProgramTemplatePickerInteractor
    private let router: ProgramTemplatePickerRouter

    private(set) var startDate = Date()
    var customPlanName = ""
    var isCreatingPlan = false

    var uid: String? {
        interactor.auth?.uid
    }
    
    var builtInTemplates: [ProgramTemplateModel] {
        interactor.getBuiltInTemplates()
    }
    
    func userTemplates(for userId: String) -> [ProgramTemplateModel] {
        interactor.getUserTemplates(userId: userId)
    }
    
    func isBuiltIn(_ template: ProgramTemplateModel) -> Bool {
        interactor.isBuiltIn(template)
    }
    
    init(
        interactor: ProgramTemplatePickerInteractor,
        router: ProgramTemplatePickerRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    private func createPlanFromTemplate(_ template: ProgramTemplateModel, startDate: Date, endDate: Date?, customName: String?) async {
        guard let userId = interactor.auth?.uid else { return }
        
        isCreatingPlan = true
        
        do {
            _ = try await interactor.createPlanFromTemplate(
                template,
                startDate: startDate,
                endDate: endDate,
                userId: userId,
                planName: customName
            )
            self.dismissScreen()
        } catch {
            router.showAlert(error: error)
        }
        
        isCreatingPlan = false
    }

    func navToCustomProgramBuilderView() {
        interactor.trackEvent(event: Event.navigate)
        router.showCreateProgramView(delegate: CreateProgramDelegate())
//        router.showCustomProgramBuilderView()
    }

    func onProgramStartConfigPressed(template: ProgramTemplateModel) {
        let delegate = ProgramStartConfigDelegate(
            template: template,
            onStart: { startDate, endDate, customName in
                Task {
                    await self.createPlanFromTemplate(
                        template,
                        startDate: startDate,
                        endDate: endDate,
                        customName: customName
                    )
                }
            }
        )
        router.showProgramStartConfigView(delegate: delegate)
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    func dismissScreen() {
        router.dismissScreen()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "ProgramTemplatePicker_Navigate"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .navigate:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .navigate:
                return .info
            }
        }
    }
}
