//
//  ProgressDashboardInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

protocol ProgressDashboardInteractor {
    func getProgressSnapshot(for period: DateInterval) async throws -> ProgressSnapshot
}

extension CoreInteractor: ProgressDashboardInteractor { }
