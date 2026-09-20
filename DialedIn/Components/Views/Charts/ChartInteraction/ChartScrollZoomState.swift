import SwiftUI

@Observable
@MainActor
final class ChartScrollZoomState {
    struct Configuration {
        var secondsPerDay: Double = 86400
        var minZoomDays: Double = 3
        var maxZoomDays: Double = 180
    }

    var scrollPosition: Date
    var currentZoomDays: Double = 0
    var totalZoomDays: Double
    var onVisibleRangeChanged: (@MainActor () -> Void)?

    @ObservationIgnored private var plotWidthValue: CGFloat = 0
    private let config: Configuration

    init(
        initialVisibleDays: Double,
        initialScrollPosition: Date = Date(),
        config: Configuration = .init()
    ) {
        self.totalZoomDays = initialVisibleDays
        self.scrollPosition = initialScrollPosition
        self.config = config
    }

    var visibleDomainLength: TimeInterval {
        clampZoomDays(totalZoomDays + currentZoomDays) * config.secondsPerDay
    }

    var plotWidth: CGFloat {
        plotWidthValue
    }

    func updatePlotWidth(_ width: CGFloat) {
        guard width.isFinite, width > 0 else { return }
        if abs(plotWidthValue - width) > 0.5 {
            plotWidthValue = width
        }
    }

    func handleMagnificationChanged(_ magnification: CGFloat) {
        let scaledDays = totalZoomDays / Double(magnification)
        currentZoomDays = scaledDays - totalZoomDays
    }

    func handleMagnificationEnded() {
        totalZoomDays = clampZoomDays(totalZoomDays + currentZoomDays)
        currentZoomDays = 0
    }

    func clampZoomDays(_ value: Double) -> Double {
        min(max(value, config.minZoomDays), config.maxZoomDays)
    }

    func notifyVisibleRangeChanged() {
        onVisibleRangeChanged?()
    }
}
