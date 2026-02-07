//
//  ExpenditureInteractor.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import SwiftUI

@MainActor
protocol ExpenditureInteractor {
    var currentUser: UserModel? { get }
    func estimateTDEE(user: UserModel?) -> Double
}

extension CoreInteractor: ExpenditureInteractor { }
