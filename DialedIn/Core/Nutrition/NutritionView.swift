//
//  NutritionView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI

struct NutritionView: View {
    
    @State private var showDebugView: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Section content")
                } header: {
                    Text("Section Header")
                }
            }
            .navigationTitle("Nutrition")
            .navigationSubtitle(Date.now.formatted(date: .abbreviated, time: .omitted))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showDebugView = true
                    } label: {
                        Image(systemName: "info")
                    }
                }
            }
            .sheet(isPresented: $showDebugView) {
                DevSettingsView()
            }
        }
    }
}

#Preview {
    NutritionView()
        .previewEnvironment()
}
