//
//  WorkoutPickerPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/12/2025.
//

import SwiftUI

@Observable
@MainActor
class WorkoutPickerPresenter {
    private let interactor: WorkoutPickerInteractor
    private let router: WorkoutPickerRouter
    
    private(set) var isLoading: Bool = false
    private(set) var templates: [WorkoutTemplateModel] = []

    init(
        interactor: WorkoutPickerInteractor,
        router: WorkoutPickerRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
        
    func loadLocalWorkouts() async {
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        interactor.trackEvent(event: Event.loadLocalWorkoutsStart)
        do {
            let templates = try interactor.getAllLocalWorkoutTemplates()
            interactor.trackEvent(event: Event.loadLocalWorkoutsSuccess(count: templates.count))
        } catch {
            interactor.trackEvent(event: Event.loadLocalWorkoutsFail(error: error))
        }
    }
    
    func onWorkoutPressed(template: WorkoutTemplateModel, onSelect: (WorkoutTemplateModel) -> Void) {
        defer {
            self.onDismissPressed()
        }
        onSelect(template)
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
    
    enum Event: LoggableEvent {
        case loadLocalWorkoutsStart
        case loadLocalWorkoutsSuccess(count: Int)
        case loadLocalWorkoutsFail(error: Error)

        var eventName: String {
            switch self {
            case .loadLocalWorkoutsStart:   return "WorkoutsView_Search_Start"
            case .loadLocalWorkoutsSuccess: return "WorkoutsView_Search_Success"
            case .loadLocalWorkoutsFail:    return "WorkoutsView_Search_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .loadLocalWorkoutsSuccess(count: let count):
                return ["count": count]
            case .loadLocalWorkoutsFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .loadLocalWorkoutsFail:
                return .severe
            default:
                return .analytic

            }
        }
    }
}
