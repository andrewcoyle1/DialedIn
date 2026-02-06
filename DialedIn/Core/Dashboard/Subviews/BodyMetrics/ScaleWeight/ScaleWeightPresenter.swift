import SwiftUI

@Observable
@MainActor
class ScaleWeightPresenter {
    
    private let interactor: ScaleWeightInteractor
    private let router: ScaleWeightRouter

    private(set) var cachedEntries: [BodyMeasurementEntry] = []
    private(set) var cachedTimeSeries: [TimeSeriesData.TimeSeries] = []
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    var weightHistory: [BodyMeasurementEntry] {
        interactor.measurementHistory
    }
    
    var timeSeries: [TimeSeriesData.TimeSeries] {
        cachedTimeSeries
    }
    
    init(interactor: ScaleWeightInteractor, router: ScaleWeightRouter) {
        self.interactor = interactor
        self.router = router
        rebuildCaches()
    }

    func loadLocalWeightEntries() {
        do {
            _ = try interactor.readAllLocalWeightEntries()
            rebuildCaches()
        } catch {
            // No-op: remote load will run on first task.
        }
    }
    
    func readAllRemoteWeightEntries() async {
        guard let userId = currentUser?.userId else { return }
        interactor.trackEvent(event: Event.loadRemoteEntriesStart)
        do {
            _ = try await interactor.readAllRemoteWeightEntries(userId: userId)
            rebuildCaches()
            interactor.trackEvent(event: Event.loadRemoteEntriesSuccess)
        } catch {
            interactor.trackEvent(event: Event.loadRemoteEntriesFail(error: error))
        }
    }
    
    func onAddWeightPressed() {
        router.showLogWeightView()
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
    
    func dedupeWeightEntries() async {
        guard let currentUser = interactor.currentUser else { return }
        do {
            try await interactor.dedupeWeightEntriesByDay(userId: currentUser.userId)
            rebuildCaches()
        } catch {
            interactor.trackEvent(event: Event.dedupeWeightEntriesFail(error: error))
        }
    }

    private func rebuildCaches() {
        let entries = interactor.measurementHistory.filter { $0.deletedAt == nil && $0.weightKg != nil }
        cachedEntries = entries
        cachedTimeSeries = [
            TimeSeriesData.TimeSeries(
                name: "Weight",
                data: entries.compactMap { entry in
                    guard let weightKg = entry.weightKg else { return nil }
                    return TimeSeriesDatapoint(id: entry.id, date: entry.date, value: weightKg)
                }
            )
        ]
    }
}

extension ScaleWeightPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = BodyMeasurementEntry

    var entries: [BodyMeasurementEntry] {
        cachedEntries
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Scale Weight",
            analyticsName: "ScaleWeightView",
            yAxisSuffix: " kg",
            seriesNames: ["Weight"],
            showsAddButton: true,
            sectionHeader: "Weight Entries",
            emptyStateMessage: "No weight entries",
            pageSize: 20
        )
    }

    func onAppear() async {
        loadLocalWeightEntries()
//        await readAllRemoteWeightEntries()
//        await dedupeWeightEntries()
    }

    func onAddPressed() {
        onAddWeightPressed()
    }

    func onDeleteEntry(_ entry: BodyMeasurementEntry) async {
        let updatedEntry = entry.withCleared(.weightKg)
        try? await interactor.updateWeightEntry(entry: updatedEntry)
        _ = try? interactor.readAllLocalWeightEntries()
        rebuildCaches()
    }
}

extension ScaleWeightPresenter {
    enum Event: LoggableEvent {
        case loadRemoteEntriesStart
        case loadRemoteEntriesSuccess
        case loadRemoteEntriesFail(error: Error)
        case dedupeWeightEntriesFail(error: Error)

        var eventName: String {
            switch self {
            case .loadRemoteEntriesStart:   return "ScaleWeightView_LoadRemoteEntries_Start"
            case .loadRemoteEntriesSuccess: return "ScaleWeightView_LoadRemoteEntries_Success"
            case .loadRemoteEntriesFail:    return "ScaleWeightView_LoadRemoteEntries_Fail"
            case .dedupeWeightEntriesFail:  return "ScaleWeightView_DedupeWeightEntries_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadRemoteEntriesFail(error: let error),
                 .dedupeWeightEntriesFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadRemoteEntriesFail,
                 .dedupeWeightEntriesFail:
                return .severe
            default:
                return .analytic
                
            }
        }
    }
}
