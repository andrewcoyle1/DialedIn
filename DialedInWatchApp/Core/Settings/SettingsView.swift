//
//  SettingsView.swift
//  DialedInWatchApp
//
//  Created by AI Assistant on 25/10/2025.
//

import SwiftUI

struct SettingsView: View {

    @State var isReachable: Bool = false
    @State var isActivated: Bool = false
    var body: some View {
        NavigationStack {
            List {
                Section("Connection") {
                    HStack {
                        Text("iPhone Status")
                        Spacer()
                        if isReachable {
                            Label("Connected", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Label("Disconnected", systemImage: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                    .onTapGesture {
                        isReachable.toggle()
                    }
                    
                    HStack {
                        Text("Session State")
                        Spacer()
                        Text(isActivated ? "Active" : "Inactive")
                            .foregroundStyle(.secondary)
                    }
                    .onTapGesture {
                        isActivated.toggle()
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}


