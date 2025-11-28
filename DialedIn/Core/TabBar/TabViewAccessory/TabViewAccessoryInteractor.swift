//
//  TabViewAccessoryInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

protocol TabViewAccessoryInteractor {
    var activeSession: WorkoutSessionModel? { get }
    var restEndTime: Date? { get }
    func reopenActiveSession()
}

extension CoreInteractor: TabViewAccessoryInteractor { }
