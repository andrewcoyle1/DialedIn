//
//  TrendSummarySection.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct TrendSummarySection: View {
    
    let trend: VolumeTrend
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            Text("Summary")
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Average Volume")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(Int(trend.averageVolume)) kg")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Trend")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: trendIcon(trend.trendDirection))
                            .foregroundStyle(trendColor(trend.trendDirection))
                        Text(trendText(trend.trendDirection, trend.percentageChange))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(trendColor(trend.trendDirection))
                    }
                }
            }
            
            // Insights
            if abs(trend.percentageChange) > 10 {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                    Text(trendInsight(trend.trendDirection, trend.percentageChange))
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
    
    private func trendIcon(_ direction: VolumeTrend.TrendDirection) -> String {
        switch direction {
        case .increasing: return "arrow.up.right"
        case .decreasing: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }
    
    private func trendColor(_ direction: VolumeTrend.TrendDirection) -> Color {
        switch direction {
        case .increasing: return .green
        case .decreasing: return .red
        case .stable: return .orange
        }
    }
    
    private func trendText(_ direction: VolumeTrend.TrendDirection, _ change: Double) -> String {
        switch direction {
        case .increasing: return "+\(Int(abs(change)))%"
        case .decreasing: return "-\(Int(abs(change)))%"
        case .stable: return "Stable"
        }
    }
    
    private func trendInsight(_ direction: VolumeTrend.TrendDirection, _ change: Double) -> String {
        switch direction {
        case .increasing:
            return "Great progress! Your training volume has increased by \(Int(abs(change)))%. Keep up the momentum!"
        case .decreasing:
            return "Your training volume has decreased by \(Int(abs(change)))%. Consider if you need more recovery or to increase workout frequency."
        case .stable:
            return "Your training volume is stable. This can be good for maintenance or you might want to consider progressive overload."
        }
    }
}

#Preview {
    List {
        TrendSummarySection(trend: VolumeTrend.mock)
    }
}
