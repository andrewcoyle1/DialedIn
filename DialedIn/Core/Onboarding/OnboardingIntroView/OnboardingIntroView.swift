//
//  OnboardingIntroView.swift
//  BrainBolt
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI

struct OnboardingIntroView: View {

    @Environment(DependencyContainer.self) private var container
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif

    var body: some View {
        List {
            trainingSection
            
            nutritionSection
            
            weightTracking
           
        }
        .safeAreaInset(edge: .bottom, content: {
            buttonSection
                .padding(.horizontal)
        })
        .navigationTitle("Welcome to Dialed.")
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
            DevSettingsView(viewModel: DevSettingsViewModel(container: container))
        }
        #endif
        .screenAppearAnalytics(name: "OnboardingIntro")
    }
    
    private var trainingSection: some View {
        Section {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "dumbbell.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(.accent)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Track Your Workouts")
                        .font(.headline)
                    Text("Log your strength and cardio sessions, follow expert routines, and visualize your progress over time. Stay motivated with streaks and personal bests.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("Training")
        }
    }
    
    private var nutritionSection: some View {
        Section {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "leaf.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(.green)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Monitor Your Nutrition")
                        .font(.headline)
                    Text("Easily log meals, scan foods, and get AI-powered nutrition analysis. Set goals, track macros, and receive personalized recommendations to fuel your journey.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("Nutrition")
        }
    }
    
    private var weightTracking: some View {
        Section {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "scalemass.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(.blue)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Track Your Weight")
                        .font(.headline)
                    Text("Log your weight over time and visualize your progress with interactive charts. Set goals, monitor trends, and stay accountable on your fitness journey.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("Weight Tracking")
        }
    }
    
    private var buttonSection: some View {
        VStack(spacing: 12) {
            NavigationLink {
                AuthOptionsView(viewModel: AuthOptionsViewModel(container: container))
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
            }
            .buttonStyle(.glassProminent)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container
    NavigationStack { OnboardingIntroView() }
        .previewEnvironment()
        .environment(container)
}
