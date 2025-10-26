//
//  TrendSummarySection.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

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
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                ),
                trend: VolumeTrend.mock
            )
        )
    }
}
