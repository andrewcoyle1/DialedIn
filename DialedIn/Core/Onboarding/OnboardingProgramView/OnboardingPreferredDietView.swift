//
//  OnboardingPreferredDietView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI

struct OnboardingPreferredDietView: View {
    @Environment(DependencyContainer.self) private var container

    @State private var selectedDiet: PreferredDiet?
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
        
    var body: some View {
        List {
            ForEach(PreferredDiet.allCases) { diet in
                Section {
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(diet.description)
                                .font(.headline)
                            Text(diet.detailedDescription)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: selectedDiet == diet ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedDiet == diet ? .accent : .secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { selectedDiet = diet }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Choose your diet")
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
        }
        #endif
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            NavigationLink {
                if let diet = selectedDiet {
                    OnboardingCalorieFloorView(preferredDiet: diet)
                }
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(selectedDiet == nil)
        }
    }
}

enum PreferredDiet: String, CaseIterable, Identifiable {
    case balanced
    case lowFat
    case lowCarb
    case keto

    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .balanced: 
            return "Balanced"
        case .lowFat:
            return "Low Fat"
        case .lowCarb:
            return "Low Carb"
        case .keto:
            return "Keto"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .balanced:
            return "Standard distribution of carbs and fat."
        case .lowFat:
            return "Fat will be reduced to prioritize carb and protein intake."
        case .lowCarb:
            return "Carbs will be reduced to prioritize fat and protein intake."
        case .keto:
            return "Carbs will be very restricted to allow for higher fat intake."
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingPreferredDietView()
    }
    .previewEnvironment()
}
