//
//  OnboardingGenderView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingGenderView: View {
    
    @Environment(LogManager.self) private var logManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedGender: Gender?
    
    @State private var navigationDestination: NavigationDestination?
    
    enum NavigationDestination {
        case dateOfBirth(gender: Gender)
    }
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    genderRow(.male)
                    genderRow(.female)
                }
                .removeListRowFormatting()
                .padding(.horizontal)
            } header: {
                Text("Select your gender")
            }
        }
        .navigationTitle("About You")
        .toolbar {
            toolbarContent
        }
        .navigationDestination(isPresented: Binding(
            get: {
                if case .dateOfBirth = navigationDestination { return true }
                return false
            },
            set: { if !$0 { navigationDestination = nil } }
        )) {
            if case let .dateOfBirth(gender) = navigationDestination {
                OnboardingDateOfBirthView(gender: gender)
            } else {
                EmptyView()
            }
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView()
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
                if let gender = selectedGender {
                    OnboardingDateOfBirthView(gender: gender)
                }
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(!canSubmit)
        }
    }
    
    private var canSubmit: Bool {
        selectedGender != nil
    }
    
    private func genderRow(_ gender: Gender) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(gender.description)
                    .font(.headline)
            }
            Spacer(minLength: 8)
            Image(systemName: selectedGender == gender ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(selectedGender == gender ? Color.accent : Color.secondary)
        }
        .contentShape(Rectangle())
        .anyButton(.press) {
            selectedGender = gender
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    NavigationStack {
        OnboardingGenderView()
    }
    .previewEnvironment()
}
