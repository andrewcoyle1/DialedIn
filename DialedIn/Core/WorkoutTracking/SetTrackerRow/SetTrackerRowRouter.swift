//
//  SetTrackerRowRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol SetTrackerRowRouter: GlobalRouter {
    func showWarmupSetInfoModal(primaryButtonAction: @escaping () -> Void)
    func showRestModal(primaryButtonAction: @escaping () -> Void, secondaryButtonAction: @escaping () -> Void, minutesSelection: Binding<Int>, secondsSelection: Binding<Int>)
}

extension CoreRouter: SetTrackerRowRouter { }
