//
//  DashboardView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI

struct DashboardView: View {

    @Environment(LogManager.self) private var logManager

    @State private var showNotifications: Bool = false

    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Section content")
                } header: {
                    Text("Section Header")
                }
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
        }
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

    private func onPushNotificationsPressed() {
        logManager.trackEvent(event: Event.onNotificationsPressed)
        showNotifications = true
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
            pushNotificationsButton
        }
    }

    private var pushNotificationsButton: some View {
        Button {
            onPushNotificationsPressed()
        } label: {
            Image(systemName: "bell")
        }
    }
}

#Preview {
    DashboardView()
        .previewEnvironment()
}
