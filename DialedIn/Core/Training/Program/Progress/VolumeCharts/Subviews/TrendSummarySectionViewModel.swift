//
//  TrendSummarySectionViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import SwiftUI

protocol TrendSummarySectionInteractor {
    
}

extension CoreInteractor: TrendSummarySectionInteractor { }

@Observable
@MainActor
class TrendSummarySectionViewModel {
    private let interactor: TrendSummarySectionInteractor

    init(interactor: TrendSummarySectionInteractor) {
        self.interactor = interactor
    }
    
    func trendIcon(trend: VolumeTrend) -> String {
        switch trend.trendDirection {
        case .increasing: return "arrow.up.right"
        case .decreasing: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }
    
    func trendColor(trend: VolumeTrend) -> Color {
        switch trend.trendDirection {
        case .increasing: return .green
        case .decreasing: return .red
        case .stable: return .orange
        }
    }
    
    func trendText(trend: VolumeTrend) -> String {
        switch trend.trendDirection {
        case .increasing: return "+\(Int(abs(trend.percentageChange)))%"
        case .decreasing: return "-\(Int(abs(trend.percentageChange)))%"
        case .stable: return "Stable"
        }
    }
    
    func trendInsight(trend: VolumeTrend) -> String {
        switch trend.trendDirection {
        case .increasing:
            return "Great progress! Your training volume has increased by \(Int(abs(trend.percentageChange)))%. Keep up the momentum!"
        case .decreasing:
            return "Your training volume has decreased by \(Int(abs(trend.percentageChange)))%. Consider if you need more recovery or to increase workout frequency."
        case .stable:
            return "Your training volume is stable. This can be good for maintenance or you might want to consider progressive overload."
        }
    }
}
