import SwiftUI

@Observable
@MainActor
class FoodLogSettingsPresenter {

    private let interactor: FoodLogSettingsInteractor
    private let router: FoodLogSettingsRouter

    private var settings: FoodLogSettings

    var isShowingHourRangePicker: Bool = false

    var showOverages: Bool {
        get { settings.showOverages }
        set { settings.showOverages = newValue; save() }
    }

    var showsFoodTimestamps: Bool {
        get { settings.showsFoodTimestamps }
        set { settings.showsFoodTimestamps = newValue; save() }
    }

    var showHourlyMacroTotals: Bool {
        get { settings.showHourlyMacroTotals }
        set { settings.showHourlyMacroTotals = newValue; save() }
    }

    var showCalendarWeekBanner: Bool {
        get { settings.showCalendarWeekBanner }
        set { settings.showCalendarWeekBanner = newValue; save() }
    }

    var premove: Bool {
        get { settings.premove }
        set { settings.premove = newValue; save() }
    }

    var timestampSide: TimestampSide {
        get { settings.timestampSide }
        set { settings.timestampSide = newValue; save() }
    }

    var showAddFoodsButton: Bool {
        get { settings.showAddFoodsButton }
        set { settings.showAddFoodsButton = newValue; save() }
    }

    var startHour: Int {
        get { settings.startHour }
        set { settings.startHour = newValue; save() }
    }

    var endHour: Int {
        get { settings.endHour }
        set { settings.endHour = newValue; save() }
    }

    var showBrandedFoods: Bool {
        get { settings.showBrandedFoods }
        set { settings.showBrandedFoods = newValue; save() }
    }

    var showOpenFoodFactsFoods: Bool {
        get { settings.showOpenFoodFactsFoods }
        set { settings.showOpenFoodFactsFoods = newValue; save() }
    }

    var hourRangeSubtitle: String {
        "\(hourLabel(startHour)) – \(hourLabel(endHour))"
    }

    var alignmentSubtitle: String {
        timestampSide == .left ? "Left" : "Right"
    }

    private func hourLabel(_ hour: Int) -> String {
        switch hour {
        case 0: return "12 AM"
        case 12: return "12 PM"
        case 1..<12: return "\(hour) AM"
        default: return "\(hour - 12) PM"
        }
    }

    init(interactor: FoodLogSettingsInteractor, router: FoodLogSettingsRouter) {
        self.interactor = interactor
        self.router = router
        self.settings = interactor.foodLogSettings
    }

    private func save() {
        Task { try? await interactor.saveFoodLogSettings(settings) }
    }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }

    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }

    func onEditHourRangePressed() {
        isShowingHourRangePicker = true
    }

    func onEditAlignmentPressed() {
        router.showAlert(
            title: "Timestamp Side",
            subtitle: nil,
            buttons: {
                AnyView(
                    VStack {
                        Button("Left") { self.timestampSide = .left }
                        Button("Right") { self.timestampSide = .right }
                        Button("Cancel", role: .cancel) { }
                    }
                )
            }
        )
    }

    func onLoggedBannerPressed() {
        router.showLoggerBannerView(delegate: LoggerBannerDelegate())
    }

    func onTimelineFoodTilesPressed() {
        router.showTimelineFoodTilesView(delegate: TimelineFoodTilesDelegate())
    }

    func onLoggerFoodTilesPressed() {
        router.showLoggerFoodTilesView(delegate: LoggerFoodTilesDelegate())
    }

    func onTimeSelectionPressed() {
        router.showTimeSelectionView(delegate: TimeSelectionDelegate())
    }

    func onFavouriteMeasurementsPressed() {
        router.showFavouriteMeasurementsView(delegate: FavouriteMeasurementsDelegate())
    }

    func onOptimisationPressed() {
        router.showOptimisationView(delegate: OptimisationDelegate())
    }
}

extension FoodLogSettingsPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear

        var eventName: String {
            switch self {
            case .onAppear: return "FoodLogSettingsView_Appear"
            case .onDisappear: return "FoodLogSettingsView_Disappear"
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
