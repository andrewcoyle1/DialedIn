//
//  DashboardView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI
import CustomRouting

struct DashboardView: View {
    
    @Environment(\.layoutMode) private var layoutMode

    @State var presenter: DashboardPresenter

    @ViewBuilder var nutritionTargetChartView: () -> AnyView

    var body: some View {
        List {
            carouselSection
            nutritionTargetSection
            contributionChartSection
        }
        .navigationTitle("Dashboard")
        .navigationSubtitle(Date.now.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.large)
        .scrollIndicators(.hidden)
        .toolbar {
            toolbarContent
        }
        .onOpenURL { url in
            presenter.handleDeepLink(url: url)
        }
    }
    
    private var inspectorContent: some View {
        Group {
            Text("Select an item")
                .foregroundStyle(.secondary)
                .padding()
        }
        .inspectorColumnWidth(min: 300, ideal: 400, max: 600)
    }
    
    private var carouselSection: some View {
        Section {
            
        } header: {
            
        }
    }
    
    private var nutritionTargetSection: some View {
        Section {
            nutritionTargetChartView()
        } header: {
            Text("Nutrition & Targets")
        }
    }
    
    private var contributionChartSection: some View {
        Section {
            ContributionChartView(
                data: presenter.contributionChartData,
                rows: 7,
                columns: 16,
                targetValue: 1.0,
                blockColor: .accent,
                endDate: presenter.chartEndDate
            )
            .frame(height: 220)
        } header: {
            Text("Workout Consistency")
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif

        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onPushNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.dashboardView(router: router)
    }
    .previewEnvironment()
}
