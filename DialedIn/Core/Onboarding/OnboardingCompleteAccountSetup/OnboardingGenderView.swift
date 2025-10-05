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
        .safeAreaInset(edge: .bottom) {
            Capsule()
                .frame(height: AuthConstants.buttonHeight)
                .frame(maxWidth: .infinity)
                .foregroundStyle(canSubmit ? Color.accent : Color.gray.opacity(0.3))
                .padding(.horizontal)
                .overlay(alignment: .center) {
                    Text("Continue")
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 32)
                    
                }
                .allowsHitTesting(canSubmit)
                .anyButton(.press) {
                    onContinue()
                }
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
    
    private func onContinue() {
        guard let selectedGender = selectedGender else { return }
        navigationDestination = .dateOfBirth(gender: selectedGender)
    }
}

#Preview {
    NavigationStack {
        OnboardingGenderView()
    }
    .previewEnvironment()
}
