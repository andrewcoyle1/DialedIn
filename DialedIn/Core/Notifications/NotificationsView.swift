//
//  NotificationsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/10/2025.
//

import SwiftUI

struct NotificationsView: View {
    @Environment(PushManager.self) private var pushManager
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Text("Hello, World!")
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
