//
//  CopyWeekPickerRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/12/2025.
//

@MainActor
protocol CopyWeekPickerRouter {
    func dismissScreen()
}

extension CoreRouter: CopyWeekPickerRouter { }
