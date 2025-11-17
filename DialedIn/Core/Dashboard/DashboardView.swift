//
//  DashboardView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI

struct DashboardViewDelegate {
    var path: Binding<[TabBarPathOption]>
}

struct DashboardView: View {
    @Environment(\.layoutMode) private var layoutMode

    @State var viewModel: DashboardViewModel

    var delegate: DashboardViewDelegate

    @ViewBuilder var devSettingsView: () -> AnyView
    @ViewBuilder var notificationsView: () -> AnyView
    @ViewBuilder var nutritionTargetChartView: () -> AnyView

    var body: some View {
        Group {
            if layoutMode == .tabBar {
                NavigationStack(path: delegate.path) {
                    contentView
                }
                .navDestinationForTabBarModule(path: delegate.path)
            } else {
                contentView
            }
        }
        .inspectorIfCompact(isPresented: $viewModel.isShowingInspector, inspector: { inspectorContent }, enabled: layoutMode != .splitView)
    }
    
    private var contentView: some View {
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
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            devSettingsView()
        }
        #endif
        .sheet(isPresented: $viewModel.showNotifications) {
            notificationsView()
        }
        .onOpenURL { url in
            viewModel.handleDeepLink(url: url)
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
                data: viewModel.contributionChartData,
                rows: 7,
                columns: 16,
                targetValue: 1.0,
                blockColor: .accent,
                endDate: viewModel.chartEndDate
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
                viewModel.showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif

        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.onPushNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
        }
    }
}

#Preview {
    @Previewable @State var path: [TabBarPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.dashboardView(delegate: DashboardViewDelegate(path: $path))
    .previewEnvironment()
}
