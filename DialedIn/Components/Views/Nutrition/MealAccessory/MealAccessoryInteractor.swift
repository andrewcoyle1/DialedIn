//
//  MealAccessoryInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol MealAccessoryInteractor {
    var activeSession: WorkoutSessionModel? { get }
    var restEndTime: Date? { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: MealAccessoryInteractor { }
