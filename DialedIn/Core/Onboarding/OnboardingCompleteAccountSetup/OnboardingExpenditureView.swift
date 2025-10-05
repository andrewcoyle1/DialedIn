//
//  OnboardingExpenditureView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct OnboardingExpenditureView: View {
    private struct Breakdown: Identifiable {
        let id = UUID()
        let name: String
        let calories: Int
        let color: Color
    }

    // Dummy data (no data layer yet)
    private let totalExpenditureKcal: Int = 2475
    private var breakdownItems: [Breakdown] {
        [
            Breakdown(name: "Basal Metabolic Rate", calories: 1450, color: .blue),
            Breakdown(name: "Daily Activity", calories: 700, color: .green),
            Breakdown(name: "Exercise", calories: 250, color: .orange),
            Breakdown(name: "Thermic Effect of Food", calories: 75, color: .pink)
        ]
    }

    @State private var displayedKcal: Int = 0
    @State private var animateBreakdown: Bool = false
    @State private var hasAnimated: Bool = false

    @State private var navigationDestination: NavigationDestination?

    enum NavigationDestination {
        case healthDisclaimer
    }
    
    var body: some View {
        List {
            overviewSection
            breakdownSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Expenditure")
        .safeAreaInset(edge: .bottom, content: {
            buttonSection
        })
        .onAppear {
            guard !hasAnimated else { return }
            hasAnimated = true
            // Animate the rolling number once on appear
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 1.6)) {
                    displayedKcal = totalExpenditureKcal
                }
            }
            // Animate the breakdown bars slightly after the number
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeOut(duration: 1.0)) {
                    animateBreakdown = true
                }
            }
        }
        .navigationDestination(isPresented: Binding(
            get: {
                if case .healthDisclaimer = navigationDestination { return true }
                return false
            },
            set: { if !$0 { navigationDestination = nil } }
        )) {
            OnboardingHealthDisclaimerView()
        }
    }
    
    private var overviewSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(displayedKcal)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .frame(minWidth: 170)
                    Text("kcal/day")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("An estimate of calories burned per day")
        } footer: {
            Text("This is your estimated total daily energy expenditure.")
        }
    }
    
    private var breakdownSection: some View {
        Section("Breakdown") {
            ForEach(breakdownItems) { item in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(item.name)
                            .font(.subheadline)
                        Spacer()
                        Text("\(item.calories) kcal")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: animateBreakdown ? progress(for: item) : 0)
                        .tint(item.color)
                        .animation(.easeOut(duration: 1.0), value: animateBreakdown)
                }
                .padding(.vertical, 6)
            }
        }
    }
    
    private var buttonSection: some View {
        Capsule()
            .frame(height: AuthConstants.buttonHeight)
            .frame(maxWidth: .infinity)
            .foregroundStyle(Color.accent)
            .padding(.horizontal)
            .overlay(alignment: .center) {
                Text("Continue")
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 32)
            }
            .anyButton(.press) {
                onContinuePressed()
            }
    }

    private func progress(for item: Breakdown) -> Double {
        guard totalExpenditureKcal > 0 else { return 0 }
        return Double(item.calories) / Double(totalExpenditureKcal)
    }
    
    private func onContinuePressed() {
        navigationDestination = .healthDisclaimer
    }
}

#Preview {
    NavigationStack {
        OnboardingExpenditureView()
    }
    .previewEnvironment()
}
