//
//  EnergyBalanceInteractor.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import SwiftUI

@MainActor
protocol EnergyBalanceInteractor {
    var currentUser: UserModel? { get }
    func getDailyTotals(dayKey: String) throws -> DailyMacroTarget
    func getDailyTotals(startDayKey: String, endDayKey: String) throws -> [(dayKey: String, totals: DailyMacroTarget)]
    func estimateTDEE(user: UserModel?) -> Double
}

extension CoreInteractor: EnergyBalanceInteractor { }
