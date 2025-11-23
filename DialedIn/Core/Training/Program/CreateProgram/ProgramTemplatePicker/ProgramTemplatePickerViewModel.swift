//
//  ProgramTemplatePickerViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol ProgramTemplatePickerInteractor {
    var auth: UserAuthInfo? { get }
    func getBuiltInTemplates() -> [ProgramTemplateModel]
    func isBuiltIn(_ template: ProgramTemplateModel) -> Bool
    func createPlanFromTemplate(
        _ template: ProgramTemplateModel,
        startDate: Date,
        endDate: Date?,
        userId: String,
        planName: String?
    ) async throws -> TrainingPlan
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ProgramTemplatePickerInteractor { }

@MainActor
protocol ProgramTemplatePickerRouter {
    func showDevSettingsView()
    func dismissScreen()
    func showProgramStartConfigView(delegate: ProgramStartConfigViewDelegate)
    func showCustomProgramBuilderView()
}

extension CoreRouter: ProgramTemplatePickerRouter { }

@Observable
@MainActor
class ProgramTemplatePickerViewModel {
    private let interactor: ProgramTemplatePickerInteractor
    private let router: ProgramTemplatePickerRouter

    var selectedTemplate: ProgramTemplateModel?
    private(set) var showStartDate = false
    private(set) var startDate = Date()
    var customPlanName = ""
    var isCreatingPlan = false
    var showAlert: AnyAppAlert?
    
    var uid: String? {
        interactor.auth?.uid
    }
    
    var programTemplates: [ProgramTemplateModel] {
        interactor.getBuiltInTemplates()
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
    
    func createPlanFromTemplate(_ template: ProgramTemplateModel, startDate: Date, endDate: Date?, customName: String?, onDismiss: () -> Void) async {
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
            onDismiss()
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
        
        isCreatingPlan = false
    }

    func navToCustomProgramBuilderView() {
        interactor.trackEvent(event: Event.navigate)
        router.showCustomProgramBuilderView()
    }

    func onProgramStartConfigPressed(template: ProgramTemplateModel) {
        let delegate = ProgramStartConfigViewDelegate(
            template: template,
            onStart: { startDate, endDate, customName in
                Task {
                    await self.createPlanFromTemplate(
                        template,
                        startDate: startDate,
                        endDate: endDate,
                        customName: customName,
                        onDismiss: {
                            self.dismissScreen()
                        }
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
