//
//  GoalProgressRouter.swift
//  DialedIn
//

import SwiftUI

@MainActor
protocol GoalProgressRouter: ScaleWeightRouter { }

extension CoreRouter: GoalProgressRouter { }
