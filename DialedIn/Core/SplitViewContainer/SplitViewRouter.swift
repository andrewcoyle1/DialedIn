//
//  SplitViewRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/01/2026.
//

@MainActor
protocol SplitViewRouter: GlobalRouter { }

extension CoreRouter: SplitViewRouter { }
