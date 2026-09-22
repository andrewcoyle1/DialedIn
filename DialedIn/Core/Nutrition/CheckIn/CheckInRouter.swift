//
//  CheckInRouter.swift
//  DialedIn
//

import SwiftUI

@MainActor
protocol CheckInRouter: GlobalRouter {

}

extension CoreRouter: CheckInRouter { }
