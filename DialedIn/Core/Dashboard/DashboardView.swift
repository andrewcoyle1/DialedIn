//
//  DashboardView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI

struct DashboardView: View {

    @Environment(LogManager.self) private var logManager
    @Environment(NutritionManager.self) private var nutritionManager
    @State private var showNotifications: Bool = false

    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    
    @State private var contributionChartData: [Double] = []
    @State private var chartEndDate: Date = Date()
    
    var body: some View {
        NavigationStack {
            List {
                carouselSection
                nutritionTargetSection
                contributionChartSection
            }
            .navigationTitle("Dashboard")
            .navigationSubtitle(Date.now.formatted(date: .abbreviated, time: .omitted))
            .toolbar {
                toolbarContent
            }
            #if DEBUG || MOCK
            .sheet(isPresented: $showDebugView) {
                DevSettingsView()
            }
            #endif
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
            }
            .onOpenURL { url in
                handleDeepLink(url: url)
            }
        }
    }
    
    private func handleDeepLink(url: URL) {
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            // no query items
            print("NO QUERY ITEMS!")
            return
        }
        
        for queryItem in queryItems {
            print(queryItem.name)
        }
        
    }
    
    private var carouselSection: some View {
        Section {
            
        } header: {
            
        }
    }
    
    private var nutritionTargetSection: some View {
        Section {
            NutritionTargetChartView()
        } header: {
            Text("Nutrition & Targets")
        }
    }
    
    private var contributionChartSection: some View {
        Section {
            ContributionChartView(
                data: contributionChartData,
                rows: 7,
                columns: 16,
                targetValue: 1.0,
                blockColor: .accent,
                endDate: chartEndDate
            )
//            .removeListRowFormatting()
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
                showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                onPushNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
        }
    }
}

#Preview {
    DashboardView()
        .previewEnvironment()
}

extension DashboardView {
    
    private func onPushNotificationsPressed() {
        logManager.trackEvent(event: Event.onNotificationsPressed)
        showNotifications = true
    }
    
    enum Event: LoggableEvent {
        case onNotificationsPressed

        var eventName: String {
            switch self {
            case .onNotificationsPressed:   return "Dashboard_NotificationsPressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            default:
                return .analytic

            }
        }
    }
}
