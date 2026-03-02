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
        interactor.bodyMeasurements
    }
    
    var timeSeries: [TimeSeriesData.TimeSeries] {
        cachedTimeSeries
    }
    
    init(interactor: ScaleWeightInteractor, router: ScaleWeightRouter) {
        self.interactor = interactor
        self.router = router
        rebuildCaches()
    }
        
    func onAddWeightPressed() {
        router.showLogWeightView()
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
    
    private func rebuildCaches() {
        let entries = interactor.bodyMeasurements.filter { $0.deletedAt == nil && $0.weightKg != nil }
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

    /// Scale weight uses the history chart (time series), not the contribution chart.
    var contributionChartData: [Double]? { nil }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Scale Weight",
            analyticsName: "ScaleWeightView",
            yAxisSuffix: " kg",
            seriesNames: ["Weight"],
            showsAddButton: true,
            sectionHeader: "Weight Entries",
            emptyStateMessage: "No weight entries",
            pageSize: 20,
            chartColor: .green
        )
    }

    func onAppear() async {
        rebuildCaches()
    }

    func onAddPressed() {
        onAddWeightPressed()
    }

    func onDeleteEntry(_ entry: BodyMeasurementEntry) async {
        let updatedEntry = entry.withCleared(.weightKg)
        try? await interactor.saveBodyMeasurement(bodyMeasurement: updatedEntry)
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
