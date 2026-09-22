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
        Group {
            if let planDays = presenter.planDays {
                if let loggedDays = presenter.loggedDays {
                    grid(planDays: planDays, loggedDays: loggedDays)
                } else {
                    // The week's totals are read in `.task` below. Until they arrive there is
                    // nothing truthful to put in the logged half of each cell.
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                noPlanState
            }
        }
        .task {
            await presenter.loadCurrentWeekLoggedTotals()
        }
    }

    /// Shown when the user has no diet plan. The grid used to draw a week of `DailyMacroTarget.mock`
    /// here, which read as the user's own targets in a screen people take dietary decisions from.
    private var noPlanState: some View {
        ContentUnavailableView {
            Label("No Diet Plan", systemImage: "fork.knife")
        } description: {
            Text("Create a diet plan and your daily calorie and macro targets appear here.")
        } actions: {
            Button("Create Diet Plan") {
                presenter.onCreatePlanPressed()
            }
            .buttonStyle(.glass)
        }
    }

    private func grid(planDays: [DailyMacroTarget], loggedDays: [DailyMacroTarget]) -> some View {
        Grid(alignment: .center, horizontalSpacing: 8, verticalSpacing: 12) {
            // Metric rows
            ForEach(NutritionTargetChartPresenter.Metric.allCases, id: \.self) { metric in
                GridRow {
                    let targetValues = planDays.map { presenter.value(for: metric, day: $0) }
                    let loggedValues = loggedDays.map { presenter.value(for: metric, day: $0) }
                    let maxValue = max(targetValues.max() ?? 1, loggedValues.max() ?? 1)
                    let sumLogged = loggedValues.reduce(0, +)
                    let sumTarget = targetValues.reduce(0, +)

                    // Day cells
                    ForEach(Array(zip(loggedValues, targetValues).enumerated()), id: \.offset) { idx, values in
                        TargetCellView(value: values.0, targetValue: values.1, maxValue: maxValue, unit: presenter.unit(for: metric), tint: metric.colour)
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
    }
}

extension CoreBuilder {
    func nutritionTargetChartView(router: AnyRouter) -> some View {
        NutritionTargetChartView(
            presenter: NutritionTargetChartPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    RouterView { router in
        builder.nutritionTargetChartView(router: router)
    }
}
