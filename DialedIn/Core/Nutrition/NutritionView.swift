//
//  NutritionView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct NutritionDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct NutritionView<CalendarHeaderView: View>: View {

    @State var presenter: NutritionPresenter
    let delegate: NutritionDelegate
    @ViewBuilder var calendarHeader: (CalendarHeaderDelegate) -> CalendarHeaderView

    @Namespace private var namespace
    
    var workingHours: [Date] {
        let calendar = Calendar.current
        // Start at 7 AM today
        let start = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!
        // End at 11 PM today (23:00)
        let end = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: Date())!
        
        var dates: [Date] = []
        var current = start
        
        // Step through hour by hour until reaching the end
        while current <= end {
            dates.append(current)
            current = calendar.date(byAdding: .hour, value: 1, to: current)!
        }
        return dates
    }

    var body: some View {
        List {
            mealLogSection
            moreSection
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Nutrition")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            toolbarContent
        }
        .toolbarRole(.browser)
        .safeAreaInset(edge: .top) {
            topSafeAreaSection
        }
    }
    
    private var topSafeAreaSection: some View {
        VStack {
            calendarHeader(
                CalendarHeaderDelegate(
                    onDatePressed: { date in
                        presenter.selectedDate = date.startOfDay
                    },
                    getForDate: { date in
                        presenter.getMealCountForDate(
                            date: date
                        )
                    }
                )
            )
            HStack {
                VStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        Image(systemName: "flame")
                            .font(.system(size: 16))
                        Text("\(Int(presenter.dailyTotals?.calories ?? 0))/\(Int(presenter.dailyTarget?.calories ?? 0))")
                            .lineLimit(1)
                            .font(.caption)
                    }
                    .frame(height: 16)
                    ProgressView(value: presenter.caloriePercentage)
                        .tint(.blue)
                }

                VStack(alignment: .leading) {
                    Text("P \(Int(presenter.dailyTotals?.proteinGrams ?? 0))/\(Int(presenter.dailyTarget?.proteinGrams ?? 0))")
                        .lineLimit(1)
                        .font(.caption)
                        .frame(height: 16)

                    ProgressView(value: presenter.carbsPercentage)
                        .tint(.red)
                }

                VStack(alignment: .leading) {
                    Text("F \(Int(presenter.dailyTotals?.fatGrams ?? 0))/\(Int(presenter.dailyTarget?.fatGrams ?? 0))")
                        .lineLimit(1)
                        .font(.caption)
                        .frame(height: 16)

                    ProgressView(value: presenter.fatPercentage)
                        .tint(.yellow)
                }
                
                VStack(alignment: .leading) {
                    Text("C \(Int(presenter.dailyTotals?.carbGrams ?? 0))/\(Int(presenter.dailyTarget?.carbGrams ?? 0))")
                        .lineLimit(1)
                        .font(.caption)
                        .frame(height: 16)

                    ProgressView(value: presenter.carbsPercentage)
                        .tint(.green)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .glassEffect()
            .padding(.horizontal)
        }
    }

    private var mealLogSection: some View {
        Section {
            ForEach(workingHours, id: \.self) { hour in
                HStack {
                    Text(hour, style: .time)
                        .lineLimit(1)
                        .padding(8)
                        .frame(width: 70)
                        .background(.secondary.opacity(0.2), in: .capsule)
                    
                    Image(systemName: "plus")
                        .padding(8)
                        .background(.secondary.opacity(0.2), in: .circle)
                        .anyButton {
                            presenter.onAddMealPressed(selectedTime: hour)
                        }
                }
                .font(.caption)
                .padding(.bottom)
            }
            .removeListRowFormatting()
            .padding(.horizontal)
        }
        .listSectionMargins(.top, 0)
        .listSectionMargins(.horizontal, 0)
        .listRowSeparator(.hidden)
    }
    
    private var moreSection: some View {
        Section {
            Group {
                Label("Nutrition Overview", systemImage: "list.bullet")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .tappableBackground()
                    .anyButton {
                        presenter.onNutritionOverviewPressed()
                    }
                Label("Customise Food Log", systemImage: "slider.horizontal.3")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .tappableBackground()
                    .anyButton {
                        presenter.onCustomiseFoodLogPressed()
                    }
            }
            .foregroundStyle(.primary)
        } header: {
            Text("More")
        }
    }
        
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
                
#if DEV || MOCK
ToolbarItem(placement: .topBarTrailing) {
    Button {
        presenter.onDevSettingsPressed()
    } label: {
        Image(systemName: "info")
    }
}
#endif

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onTimelineActionsPressed()
            } label: {
                Image(systemName: "line.3.horizontal")
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            let avatarSize: CGFloat = 44

            Button {
                presenter.onProfilePressed()
            } label: {
                ZStack {
                    Image(systemName: "person.circle")
                        .font(.system(size: 24))
                    if let urlString = presenter.userImageUrl {
                        ImageLoaderView(urlString: urlString, clipShape: AnyShape(Circle()))
                            .frame(width: avatarSize, height: avatarSize)
                            .contentShape(Circle())
                    }
                }
            }
        }
        .sharedBackgroundVisibility(.hidden)
    }
}

extension CoreBuilder {
    func nutritionView(delegate: NutritionDelegate, router: AnyRouter) -> some View {
        NutritionView(
            presenter: NutritionPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate,
            calendarHeader: { delegate in
                self.calendarHeaderView(router: router, delegate: delegate)
            }
        )
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = NutritionDelegate()
    RouterView { router in
        builder.nutritionView(delegate: delegate, router: router)
    }
    
}
