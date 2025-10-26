//
//  NutritionTargetChartView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import SwiftUI

struct NutritionTargetChartView: View {
    @State var viewModel: NutritionTargetChartViewModel
    
    var body: some View {
        Grid(alignment: .center, horizontalSpacing: 8, verticalSpacing: 12) {
            // Metric rows
            ForEach(NutritionTargetChartViewModel.Metric.allCases, id: \.self) { metric in
                GridRow {
                    let targetValues = viewModel.planDays.map { viewModel.value(for: metric, day: $0) }
                    let loggedValues = viewModel.loggedDays.map { viewModel.value(for: metric, day: $0) }
                    let maxValue = max(targetValues.max() ?? 1, loggedValues.max() ?? 1)
                    let sumLogged = loggedValues.reduce(0, +)
                    let sumTarget = targetValues.reduce(0, +)
                    
                    // Day cells
                    ForEach(viewModel.planDays.indices, id: \.self) { idx in
                        let logged = viewModel.value(for: metric, day: viewModel.loggedDays[idx])
                        let target = viewModel.value(for: metric, day: viewModel.planDays[idx])
                        TargetCellView(value: logged, targetValue: target, maxValue: maxValue, unit: viewModel.unit(for: metric), tint: metric.colour)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.accentColor.opacity(idx == viewModel.todayIndexMondayStart ? 0.9 : 0), lineWidth: 2)
                            )
                            .shadow(color: Color.accentColor.opacity(idx == viewModel.todayIndexMondayStart ? 0.15 : 0), radius: 3, x: 0, y: 1)
                    }
                    
                    // Weekly sum cell
                    OverallTargetCellView(metricInitial: metric.initial, value: sumLogged, target: sumTarget, unit: viewModel.unit(for: metric))
                        .fixedSize(horizontal: true, vertical: false)
                        .gridColumnAlignment(.leading)
                }
            }
            
            // Day labels row
            GridRow {
                ForEach(Array(viewModel.dayAbbrevs.enumerated()), id: \.offset) { idx, day in
                    Text(day)
                        .font(.footnote)
                        .fontWeight(idx == viewModel.todayIndexMondayStart ? .bold : .regular)
                        .foregroundStyle(idx == viewModel.todayIndexMondayStart ? .accent : .secondary)
                        .padding(.horizontal, 2)
                }
                Text("Week")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .gridColumnAlignment(.leading)
            }
        }
        .task {
            await viewModel.loadCurrentWeekLoggedTotals()
        }
    }
}

#Preview {
    NutritionTargetChartView(viewModel: NutritionTargetChartViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
        .previewEnvironment()
}
