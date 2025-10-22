//
//  TrendSummarySection.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

@Observable
@MainActor
class TrendSummarySectionViewModel {
    
    let trend: VolumeTrend
    
    init(
        container: DependencyContainer,
        trend: VolumeTrend
    ) {
        self.trend = trend
    }
    
    var trendIcon: String {
        switch self.trend.trendDirection {
        case .increasing: return "arrow.up.right"
        case .decreasing: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }
    
    var trendColor: Color {
        switch self.trend.trendDirection {
        case .increasing: return .green
        case .decreasing: return .red
        case .stable: return .orange
        }
    }
    
    var trendText: String {
        switch self.trend.trendDirection {
        case .increasing: return "+\(Int(abs(self.trend.percentageChange)))%"
        case .decreasing: return "-\(Int(abs(self.trend.percentageChange)))%"
        case .stable: return "Stable"
        }
    }
    
    var trendInsight: String {
        switch self.trend.trendDirection {
        case .increasing:
            return "Great progress! Your training volume has increased by \(Int(abs(self.trend.percentageChange)))%. Keep up the momentum!"
        case .decreasing:
            return "Your training volume has decreased by \(Int(abs(self.trend.percentageChange)))%. Consider if you need more recovery or to increase workout frequency."
        case .stable:
            return "Your training volume is stable. This can be good for maintenance or you might want to consider progressive overload."
        }
    }
}

struct TrendSummarySection: View {
    @State var viewModel: TrendSummarySectionViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            Text("Summary")
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Average Volume")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(Int(viewModel.trend.averageVolume)) kg")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Trend")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.trendIcon)
                            .foregroundStyle(viewModel.trendColor)
                        Text(viewModel.trendText)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(viewModel.trendColor)
                    }
                }
            }
            
            // Insights
            if abs(viewModel.trend.percentageChange) > 10 {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                    Text(viewModel.trendInsight)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.yellow.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    List {
        TrendSummarySection(
            viewModel: TrendSummarySectionViewModel(
                container: DevPreview.shared.container,
                trend: VolumeTrend.mock))
    }
}
