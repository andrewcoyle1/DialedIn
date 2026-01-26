//
//  TabBarRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/01/2026.
//

@MainActor
protocol TabBarRouter: GlobalRouter { }

extension CoreRouter: TabBarRouter { }
