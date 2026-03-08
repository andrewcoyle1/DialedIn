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
            default:
                EmptyView()
            }
        }
    }
    
    private var authorizedContent: some View {
        Group {
            if presenter.activityNotifications.isEmpty {
                emptyStateContent
            } else {
                activityNotificationsList
            }
        }
    }

    @ViewBuilder
    private var activityNotificationsList: some View {
        ForEach(presenter.activityNotifications) { notification in
            activityNotificationRow(notification)
                .swipeActions {
                    Button(role: .destructive) {
                        presenter.onNotificationDeleted(notification)
                    }
                }
        }
    }

    private func activityNotificationRow(_ notification: ActivityNotificationModel) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(activityNotificationTitle(notification))
                .font(.headline)
                .foregroundStyle(notification.isRead ? .secondary : .primary)

            Text(notification.dateCreated.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }

    private func activityNotificationTitle(_ notification: ActivityNotificationModel) -> String {
        switch notification.type {
        case .like:
            return "\(notification.actorName) liked your workout"
        case .comment:
            let preview = notification.commentText.map { ": \"\($0.prefix(60))\"" } ?? ""
            return "\(notification.actorName) commented\(preview)"
        }
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
