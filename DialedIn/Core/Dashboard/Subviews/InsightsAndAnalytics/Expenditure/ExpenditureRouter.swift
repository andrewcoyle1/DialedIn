//
//  ExpenditureRouter.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import SwiftUI

@MainActor
protocol ExpenditureRouter: GlobalRouter { }

extension CoreRouter: ExpenditureRouter { }
