//
//  DashboardView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI

struct DashboardView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: DashboardViewModel
    @Environment(\.layoutMode) private var layoutMode
    
    var body: some View {
        Group {
            if layoutMode == .tabBar {
                NavigationStack {
                    contentView
                }
            } else {
                contentView
            }
        }
        .modifier(InspectorIfCompact(isPresented: $viewModel.isShowingInspector, inspector: { inspectorContent }, enabled: layoutMode != .splitView))
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
            DevSettingsView(
                viewModel: DevSettingsViewModel(
                    interactor: CoreInteractor(
                        container: container
                    )
                )
            )
        }
        #endif
        .sheet(isPresented: $viewModel.showNotifications) {
            NotificationsView(viewModel: NotificationsViewModel(interactor: CoreInteractor(container: container)))
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
            NutritionTargetChartView(viewModel: NutritionTargetChartViewModel(interactor: CoreInteractor(container: container)))
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
    DashboardView(viewModel: DashboardViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
        .previewEnvironment()
}
