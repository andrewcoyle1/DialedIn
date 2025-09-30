//
//  DashboardView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI

struct DashboardView: View {

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
                #if DEBUG || MOCK
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showDebugView = true
                    } label: {
                        Image(systemName: "info")
                    }
                }
                #endif
            }
            #if DEBUG || MOCK
            .sheet(isPresented: $showDebugView) {
                DevSettingsView()
            }
            #endif
        }
    }
}

#Preview {
    DashboardView()
        .previewEnvironment()
}
