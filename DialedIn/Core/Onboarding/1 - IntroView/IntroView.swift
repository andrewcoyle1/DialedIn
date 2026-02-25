//
//  IntroView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI

struct IntroView: View {

    @State var presenter: IntroPresenter

    var body: some View {
        List {
            trainingSection
            nutritionSection
            weightTracking
        }
        .navigationTitle("Welcome to Dialed.")
        .navigationBarTitleDisplayMode(.large)
#if DEBUG || MOCK
.toolbar {
            toolbarContent
        }
        #endif
        #if !DEBUG && !MOCK
        .navigationBarBackButtonHidden(true)
        #endif
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
        }
        .safeAreaInset(edge: .bottom) {
            CallToActionButton {
                presenter.navigateToAuth()
            } label: {
                Text("Continue")
            }
            .accessibilityIdentifier("Continue")
        }
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
                    .foregroundStyle(Color.accentColor)
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
    
#if DEBUG || MOCK
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
    }
#endif
    
}

extension CoreBuilder {
    func introView(router: AnyRouter) -> some View {
        IntroView(
            presenter: IntroPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        
    }
}

extension CoreRouter {
    func showIntroView() {
        router.showScreen(.push) { router in
            builder.introView(router: router)
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.introView(router: router)
    }
    
}
