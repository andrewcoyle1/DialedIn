//
//  OnboardingHealthData.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

struct OnboardingHealthDataView: View {
    @State private var navigateNext: Bool = false

    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif

    var body: some View {
        List {
            Section {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "scalemass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundStyle(.blue)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Why We Request Health Data Access")
                            .font(.headline)
                        Text("Dialed needs permission to read and write your weight data in Apple Health. This allows us to automatically track your progress, update your weight logs, and provide you with accurate charts and insights.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Your Health, Your Data")
            }

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Sync your weight entries seamlessly between Dialed and Apple Health.", systemImage: "arrow.triangle.2.circlepath")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Label("See all your progress in one place, even if you use other health apps.", systemImage: "chart.line.uptrend.xyaxis")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Label("Let Dialed update your Health data when you log new weights.", systemImage: "plus.circle")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("What You Get")
            }

            Section {
                Label("Maintain full control: you can revoke access or limit permissions at any time in the Health app.", systemImage: "lock.shield")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Your Control")
            }
        }
        .navigationTitle("Health Data")
        .navigationBarTitleDisplayMode(.large)
        #if !DEBUG && !MOCK
        .navigationBarBackButtonHidden(true)
        #else
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
        #endif
        .navigationDestination(isPresented: $navigateNext) {
            OnboardingCompletedView()
        }
        .screenAppearAnalytics(name: "OnboardingNotifications")
        .safeAreaInset(edge: .bottom) {
            buttonSection
                .padding(.horizontal)
        }
    }
    
    private var buttonSection: some View {
        VStack(spacing: 12) {
            Button {  } label: {
                Text("Allow access to health data")
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
            }
            .buttonStyle(.glassProminent)

            NavigationLink { OnboardingCompletedView() } label: {
                Text("Not now")
                    .frame(maxWidth: .infinity)
            }
            .padding(.bottom)
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingHealthDataView()
    }
    .previewEnvironment()
}
