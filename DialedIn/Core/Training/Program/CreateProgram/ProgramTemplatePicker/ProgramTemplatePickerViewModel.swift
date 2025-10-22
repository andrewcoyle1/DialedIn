//
//  ProgramTemplatePickerViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProgramTemplatePickerViewModel {
    private let authManager: AuthManager
    private let workoutTemplateManager: WorkoutTemplateManager
    private let trainingPlanManager: TrainingPlanManager
    private let programTemplateManager: ProgramTemplateManager
    
    var selectedTemplate: ProgramTemplateModel?
    private(set) var showStartDate = false
    private(set) var startDate = Date()
    var customPlanName = ""
    var isCreatingPlan = false
    var showAlert: AnyAppAlert?
    
    var uid: String? {
        authManager.auth?.uid
    }
    
    var programTemplates: [ProgramTemplateModel] {
        programTemplateManager.getBuiltInTemplates()
    }
    
    func isBuiltIn(_ template: ProgramTemplateModel) -> Bool {
        programTemplateManager.isBuiltIn(template)
    }
    
    init(
        container: DependencyContainer
    ) {
        self.authManager = container.resolve(AuthManager.self)!
        self.workoutTemplateManager = container.resolve(WorkoutTemplateManager.self)!
        self.trainingPlanManager = container.resolve(TrainingPlanManager.self)!
        self.programTemplateManager = container.resolve(ProgramTemplateManager.self)!
    }
    
    func createPlanFromTemplate(_ template: ProgramTemplateModel, startDate: Date, endDate: Date?, customName: String?, onDismiss: () -> Void) async {
        guard let userId = authManager.auth?.uid else { return }
        
        isCreatingPlan = true
        
        do {
            _ = try await trainingPlanManager.createPlanFromTemplate(
                template,
                startDate: startDate,
                endDate: endDate,
                userId: userId,
                planName: customName,
                workoutTemplateManager: workoutTemplateManager
            )
            onDismiss()
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
        
        isCreatingPlan = false
    }
}
