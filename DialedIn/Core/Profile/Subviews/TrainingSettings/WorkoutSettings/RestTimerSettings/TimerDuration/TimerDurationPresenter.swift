import SwiftUI

@Observable
@MainActor
class TimerDurationPresenter {

    private let interactor: TimerDurationInteractor
    private let router: TimerDurationRouter

    private var settings: WorkoutSettings

    // Sensible defaults per exercise type (seconds)
    static let defaultDurations: [ExerciseType: Int] = [
        .compoundUpper: 180,
        .compoundLower: 180,
        .isolationUpper: 90,
        .isolationLower: 90,
        .core: 60
    ]

    // MARK: - Edit Sheet State

    var editingType: ExerciseType?

    var isEditingType: Bool {
        get { editingType != nil }
        set { if !newValue { editingType = nil } }
    }

    var editMinutes: Int = 1
    var editSeconds: Int = 30

    init(interactor: TimerDurationInteractor, router: TimerDurationRouter) {
        self.interactor = interactor
        self.router = router
        self.settings = interactor.workoutSettings
    }

    // MARK: - Duration Access

    func duration(for type: ExerciseType) -> Int {
        settings.restDurationsByExerciseType[type.rawValue] ?? Self.defaultDurations[type] ?? 90
    }

    func formattedDuration(for type: ExerciseType) -> String {
        let seconds = duration(for: type)
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    // MARK: - Actions

    func onEditPressed(type: ExerciseType) {
        let current = duration(for: type)
        editMinutes = current / 60
        editSeconds = current % 60
        editingType = type
    }

    func saveEdit() {
        guard let type = editingType else { return }
        let total = editMinutes * 60 + editSeconds
        settings.restDurationsByExerciseType[type.rawValue] = total
        Task {
            try? await save()
        }
        editingType = nil
    }

    func resetDefaults() {
        settings.restDurationsByExerciseType = [:]
        Task {
            try? await save()
        }
    }

    // MARK: - Lifecycle

    func onViewAppear(delegate: TimerDurationDelegate) {
        settings = interactor.workoutSettings
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }

    func onViewDisappear(delegate: TimerDurationDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }

    // MARK: - Private

    private func save() async throws {
        try await interactor.saveWorkoutSettings(settings)
    }
}

extension TimerDurationPresenter {

    enum Event: LoggableEvent {
        case onAppear(delegate: TimerDurationDelegate)
        case onDisappear(delegate: TimerDurationDelegate)

        var eventName: String {
            switch self {
            case .onAppear:    return "TimerDurationView_Appear"
            case .onDisappear: return "TimerDurationView_Disappear"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
            }
        }

        var type: LogType {
            .analytic
        }
    }
}
