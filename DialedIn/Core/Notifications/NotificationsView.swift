//
//  NotificationsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/10/2025.
//

import SwiftUI
import UserNotifications

struct NotificationsView: View {
    @Environment(PushManager.self) private var pushManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var notifications: [UNNotification] = []
    @State private var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @State private var isLoading: Bool = true
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else {
                    content
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .scrollIndicators(.hidden)
            .screenAppearAnalytics(name: "NotificationsView")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onDismissPressed()
                    } label: {
                        Text("Done")
                    }
                }
            }
            .task {
                await loadNotifications()
            }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch authorizationStatus {
        case .authorized:
            authorizedContent
        case .notDetermined:
            notDeterminedContent
        case .denied, .provisional, .ephemeral:
            deniedContent
        @unknown default:
            deniedContent
        }
    }
    
    private var authorizedContent: some View {
        Group {
            if notifications.isEmpty {
                emptyStateContent
            } else {
                notificationsList
            }
        }
    }
    
    private var notificationsList: some View {
        List {
            ForEach(notifications, id: \.request.identifier) { notification in
                notificationRow(notification)
            }
            .onDelete(perform: deleteNotifications)
        }
    }
    
    private func notificationRow(_ notification: UNNotification) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(notification.request.content.title)
                .font(.headline)
            
            if !notification.request.content.body.isEmpty {
                Text(notification.request.content.body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Text(notification.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
    
    private var emptyStateContent: some View {
        List {
            VStack(spacing: 16) {
                Image(systemName: "bell.slash")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                
                Text("No Notifications")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("You don't have any notifications yet. When you receive notifications, they'll appear here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        }
    }
    
    private var notDeterminedContent: some View {
        List {
            VStack(spacing: 20) {
                Image(systemName: "bell.badge")
                    .font(.system(size: 48))
                    .foregroundStyle(.accent)
                
                Text("Enable Notifications")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Stay informed about workouts, nutrition tracking, and important updates. Enable notifications to never miss a beat.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button {
                    onRequestNotificationsPressed()
                } label: {
                    Text("Enable Notifications")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        }
    }
    
    private var deniedContent: some View {
        List {
            VStack(spacing: 20) {
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                
                Text("Notifications Disabled")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Notifications are currently disabled. To receive updates, please enable notifications in Settings.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button {
                    openSettings()
                } label: {
                    Text("Open Settings")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        }
    }
    
    private func loadNotifications() async {
        isLoading = true
        
        // Get authorization status
        authorizationStatus = await pushManager.getAuthorizationStatus()
        
        // Load notifications if authorized
        if authorizationStatus == .authorized {
            notifications = await pushManager.getDeliveredNotifications()
        }
        
        isLoading = false
    }
    
    private func deleteNotifications(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let notification = notifications[index]
                await pushManager.removeDeliveredNotification(identifier: notification.request.identifier)
            }
            notifications.remove(atOffsets: offsets)
        }
    }
    
    private func onRequestNotificationsPressed() {
        Task {
            do {
                _ = try await pushManager.requestAuthorisation()
                await loadNotifications()
            } catch {
                // Handle error silently or show alert
            }
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    private func onDismissPressed() {
        dismiss()
    }
}

#Preview {
    NotificationsView()
        .previewEnvironment()
}
