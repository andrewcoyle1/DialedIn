//
//  OnboardingHealthData.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI
import CustomRouting

struct OnboardingHealthDataView: View {

    @State var presenter: OnboardingHealthDataPresenter

    var body: some View {
        List {
            yourHealthYourDataSection
            whatYouGetSection
            yourControlSection
        }
        .navigationTitle("Health Data")
        .screenAppearAnalytics(name: "OnboardingHealthData")
        .navigationBarTitleDisplayMode(.large)
        #if !DEBUG && !MOCK
        .navigationBarBackButtonHidden(true)
        #endif
        .toolbar {
            toolbarContent
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                presenter.onAllowAccessPressed()
            } label: {
                Text("Allow access to health data")
                    .padding(.horizontal)
            }
            .buttonStyle(.glassProminent)
        }
        ToolbarSpacer(.fixed, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                presenter.handleNavigation()
            } label: {
                Image(systemName: "chevron.right")
            }
        }
    }

    private var yourHealthYourDataSection: some View {
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
    }
    
    private var whatYouGetSection: some View {
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
    }
    
    private var yourControlSection: some View {
        Section {
            Label("Maintain full control: you can revoke access or limit permissions at any time in the Health app.", systemImage: "lock.shield")
                .font(.footnote)
                .foregroundStyle(.secondary)
        } header: {
            Text("Your Control")
        }
    }
}

#Preview("Proceed to Notifications") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingHealthDataView(router: router)
    }
    .previewEnvironment()
}
