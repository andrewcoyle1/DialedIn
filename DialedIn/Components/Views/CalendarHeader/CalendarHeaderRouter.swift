import SwiftUI

@MainActor
protocol CalendarHeaderRouter {
    func showCalendarViewZoom(delegate: CalendarDelegate, onDismiss: (() -> Void)?, transitionId: String?, namespace: Namespace.ID)}

extension CoreRouter: CalendarHeaderRouter { }
