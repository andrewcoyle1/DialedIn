import SwiftUI

@Observable
@MainActor
class ExpenditureSettingsPresenter {
    
    private let interactor: ExpenditureSettingsInteractor
    private let router: ExpenditureSettingsRouter
    
    private var settings: NutritionStrategySettings

    /// Presents the calculation start date picker.
    var isChoosingStartDate: Bool = false

    init(interactor: ExpenditureSettingsInteractor, router: ExpenditureSettingsRouter) {
        self.interactor = interactor
        self.router = router
        self.settings = interactor.nutritionStrategySettings
    }

    let estimationMethods = ExpenditureEstimationMethod.allCases
    let bmrEquations = BMREquation.allCases
    let calculationModes = ExpenditureCalculationMode.allCases
    let algorithmVersions = ExpenditureAlgorithmVersion.allCases

    var stepInformedUpdates: Bool {
        get { settings.stepInformedUpdates }
        set { settings.stepInformedUpdates = newValue; save() }
    }

    var predictiveGoalAdjustments: Bool {
        get { settings.predictiveGoalAdjustments }
        set { settings.predictiveGoalAdjustments = newValue; save() }
    }

    var estimationMethod: ExpenditureEstimationMethod {
        get { settings.estimationMethod }
        set { settings.estimationMethod = newValue; save() }
    }

    var bmrEquation: BMREquation {
        get { settings.bmrEquation }
        set { settings.bmrEquation = newValue; save() }
    }

    var calculationMode: ExpenditureCalculationMode {
        get { settings.calculationMode }
        set { settings.calculationMode = newValue; save() }
    }

    var algorithmVersion: ExpenditureAlgorithmVersion {
        get { settings.algorithmVersion }
        set { settings.algorithmVersion = newValue; save() }
    }

    /// Unset means "since you started logging", which is how the estimate already behaves.
    var calculationStartDate: Date {
        get { settings.calculationStartDate ?? Date() }
        set { settings.calculationStartDate = newValue; save() }
    }

    var calculationStartDateLabel: String {
        guard let date = settings.calculationStartDate else { return "Default" }
        return date.formatted(date: .abbreviated, time: .omitted)
    }

    func onEditStartDatePressed() {
        isChoosingStartDate = true
    }

    func onClearStartDatePressed() {
        settings.calculationStartDate = nil
        isChoosingStartDate = false
        save()
    }

    private func save() {
        Task { try? await interactor.saveNutritionStrategySettings(settings) }
    }
    
    /// Re-read rather than trusting the snapshot taken at init: `save()` writes the whole
    /// `NutritionStrategySettings` document, which the Strategy screen edits too, so a stale copy
    /// would revert whatever was saved over there.
    func onViewAppear() {
        settings = interactor.nutritionStrategySettings
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }
    
}

extension ExpenditureSettingsPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        
        var eventName: String {
            switch self {
            case .onAppear: return "ExpenditureSettingsView_Appear"
            case .onDisappear: return "ExpenditureSettingsView_Disappear"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}
