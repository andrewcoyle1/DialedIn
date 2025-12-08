//
//  NutritionTargetChartView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import SwiftUI

struct NutritionTargetChartView: View {
    @State var presenter: NutritionTargetChartPresenter
    
    var body: some View {
        Grid(alignment: .center, horizontalSpacing: 8, verticalSpacing: 12) {
            // Metric rows
            ForEach(NutritionTargetChartPresenter.Metric.allCases, id: \.self) { metric in
                GridRow {
                    let targetValues = presenter.planDays.map { presenter.value(for: metric, day: $0) }
                    let loggedValues = presenter.loggedDays.map { presenter.value(for: metric, day: $0) }
                    let maxValue = max(targetValues.max() ?? 1, loggedValues.max() ?? 1)
                    let sumLogged = loggedValues.reduce(0, +)
                    let sumTarget = targetValues.reduce(0, +)
                    
                    // Day cells
                    ForEach(presenter.planDays.indices, id: \.self) { idx in
                        let logged = presenter.value(for: metric, day: presenter.loggedDays[idx])
                        let target = presenter.value(for: metric, day: presenter.planDays[idx])
                        TargetCellView(value: logged, targetValue: target, maxValue: maxValue, unit: presenter.unit(for: metric), tint: metric.colour)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.accentColor.opacity(idx == presenter.todayIndexMondayStart ? 0.9 : 0), lineWidth: 2)
                            )
                            .shadow(color: Color.accentColor.opacity(idx == presenter.todayIndexMondayStart ? 0.15 : 0), radius: 3, x: 0, y: 1)
                    }
                    
                    // Weekly sum cell
                    OverallTargetCellView(metricInitial: metric.initial, value: sumLogged, target: sumTarget, unit: presenter.unit(for: metric))
                        .fixedSize(horizontal: true, vertical: false)
                        .gridColumnAlignment(.leading)
                }
            }
            
            // Day labels row
            GridRow {
                ForEach(Array(presenter.dayAbbrevs.enumerated()), id: \.offset) { idx, day in
                    Text(day)
                        .font(.footnote)
                        .fontWeight(idx == presenter.todayIndexMondayStart ? .bold : .regular)
                        .foregroundStyle(idx == presenter.todayIndexMondayStart ? .accent : .secondary)
                        .padding(.horizontal, 2)
                }
                Text("Week")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .gridColumnAlignment(.leading)
            }
        }
        .task {
            await presenter.loadCurrentWeekLoggedTotals()
        }
    }
}

extension CoreBuilder {
    func nutritionTargetChartView() -> some View {
        NutritionTargetChartView(
            presenter: NutritionTargetChartPresenter(interactor: interactor)
        )
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.nutritionTargetChartView()
        .previewEnvironment()
}
