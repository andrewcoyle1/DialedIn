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

@Observable
@MainActor
class ProgramTemplatePickerViewModel {
    private let interactor: ProgramTemplatePickerInteractor
    
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
    
    init(interactor: ProgramTemplatePickerInteractor) {
        self.interactor = interactor
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

    func navToCustomProgramBuilderView(path: Binding<[TabBarPathOption]>) {
        interactor.trackEvent(event: Event.navigate(destination: .customProgramBuilderView))
        path.wrappedValue.append(.customProgramBuilderView)
    }

    enum Event: LoggableEvent {
        case navigate(destination: TabBarPathOption)

        var eventName: String {
            switch self {
            case .navigate: return "ProgramTemplatePicker_Navigate"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .navigate(destination: let destination):
                return destination.eventParameters
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
