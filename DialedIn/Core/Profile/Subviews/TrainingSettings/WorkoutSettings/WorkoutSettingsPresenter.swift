import SwiftUI

@Observable
@MainActor
class WorkoutSettingsPresenter {

    private let interactor: WorkoutSettingsInteractor
    private let router: WorkoutSettingsRouter

    private var settings: WorkoutSettings

    init(interactor: WorkoutSettingsInteractor, router: WorkoutSettingsRouter) {
        self.interactor = interactor
        self.router = router
        self.settings = interactor.workoutSettings
    }

    func onViewAppear(delegate: WorkoutSettingsDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }

    func onViewDisappear(delegate: WorkoutSettingsDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
    
    func onRestTimerSettingsPressed() {
        router.showRestTimerSettingsView(delegate: RestTimerSettingsDelegate())
    }

    func onSmartProgressionSettingsPressed() {
        router.showSmartProgressionSettingsView(delegate: SmartProgressionSettingsDelegate())
    }
    
    func onPreviousReferenceSettingsPressed() {
        router.showPreviousWorkoutReferenceSettingsView(delegate: PreviousWorkoutReferenceSettingsDelegate())
    }
    
    func onExerciseAssessmentPressed() {
        router.showExerciseAssessmentView(delegate: ExerciseAssessmentDelegate())
    }
    
    // MARK: - General Settings

    var propagateChanges: Bool {
        get { settings.propagateChanges }
        set { settings.propagateChanges = newValue; save() }
    }

    var rirTracking: Bool {
        get { settings.rirTracking }
        set { settings.rirTracking = newValue; save() }
    }

    var supersetAutoScroll: Bool {
        get { settings.supersetAutoScroll }
        set { settings.supersetAutoScroll = newValue; save() }
    }

    var exerciseAutoNext: Bool {
        get { settings.exerciseAutoNext }
        set { settings.exerciseAutoNext = newValue; save() }
    }

    // MARK: - Display Settings

    var keepAlive: Bool {
        get { settings.keepAlive }
        set { settings.keepAlive = newValue; save() }
    }

    var showWorkoutTimer: Bool {
        get { settings.showWorkoutTimer }
        set { settings.showWorkoutTimer = newValue; save() }
    }

    var showBodyweightContribution: Bool {
        get { settings.showBodyweightContribution }
        set { settings.showBodyweightContribution = newValue; save() }
    }

    // MARK: - Warm-Up Settings

    var addSmartWarmUps: Bool {
        get { settings.addSmartWarmUps }
        set { settings.addSmartWarmUps = newValue; save() }
    }

    // MARK: - Private

    private func save() {
        Task {
            try? await interactor.saveWorkoutSettings(settings)
        }
    }
}

extension WorkoutSettingsPresenter {

    enum Event: LoggableEvent {
        case onAppear(delegate: WorkoutSettingsDelegate)
        case onDisappear(delegate: WorkoutSettingsDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "WorkoutSettingsView_Appear"
            case .onDisappear:              return "WorkoutSettingsView_Disappear"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
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
