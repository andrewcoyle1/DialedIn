//
//  NotificationsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/10/2025.
//

import SwiftUI
import UserNotifications

struct NotificationsView: View {

    @State var presenter: NotificationsPresenter

    var body: some View {
        Group {
            if presenter.isLoading {
                ProgressView()
            } else {
                content
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
        .scrollIndicators(.hidden)
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
        }
        .onFirstTask {
            await presenter.checkPermissions()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    presenter.onDismissPressed()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
        .task {
            await presenter.loadNotifications()
        }
    }
    
    @ViewBuilder
    private var content: some View {
        List {
            switch presenter.authorizationStatus {
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
    }
    
    private var authorizedContent: some View {
        Group {
            if presenter.notifications.isEmpty {
                emptyStateContent
            } else {
                notificationsList
            }
        }
    }
    
    @ViewBuilder
    private var notificationsList: some View {
        ForEach(presenter.notifications, id: \.request.identifier) { notification in
            notificationRow(notification)
        }
        .onDelete(perform: presenter.deleteNotifications)
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
        ContentUnavailableView(
            "No Notifications",
            systemImage: "bell.slash",
            description: Text("You don't have any notifications yet. When you receive notifications, they'll appear here.")
        )
        .padding(.vertical, 40)
    }
    
    private var notDeterminedContent: some View {
        ContentUnavailableView {
            VStack {
                Image(systemName: "bell.badge")
                    .font(.system(size: 48))
                
                Text("Enable Notifications")
            }
        } description: {
            Text("Stay informed about workouts, nutrition tracking, and important updates. Enable notifications to never miss a beat.")
        } actions: {
            Button {
                presenter.onRequestNotificationsPressed()
            } label: {
                Text("Enable Notifications")
                    .padding(8)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical)
        .background(in: .containerRelative)
        .removeListRowFormatting()
    }
    
    private var deniedContent: some View {
        ContentUnavailableView {
            VStack {
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 48))
                
                Text("Notifications Disabled")
            }
        } description: {
            Text("Notifications are currently disabled. To receive updates, please enable notifications in Settings.")
        } actions: {
            Button {
                presenter.openSettings()
            } label: {
                Text("Open Settings")
                    .padding(8)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical)
        .background(in: .containerRelative)
        .removeListRowFormatting()
    }
}

extension CoreBuilder {
    func notificationsView(router: AnyRouter) -> some View {
        NotificationsView(
            presenter: NotificationsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}

extension CoreRouter {
    func showNotificationsView() {
        router.showScreen(.sheet) { router in
            builder.notificationsView(router: router)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    RouterView { router in
        builder.notificationsView(router: router)
    }
    
}
